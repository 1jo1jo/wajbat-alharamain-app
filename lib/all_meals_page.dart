import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'cart_data.dart';

const String mealsApiUrl =
    'https://haramain-backend.onrender.com/meals';

class _Meal {
  final int id;
  final String name;
  final String subtitle;
  final String description;
  final String image;
  final int price;
  final int quantity;
  final String restaurantName;
  final String city;

  const _Meal({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.image,
    required this.price,
    required this.quantity,
    required this.restaurantName,
    required this.city,
  });

  factory _Meal.fromJson(Map<String, dynamic> json) {
    final imageValue = (json['image'] ?? '').toString();

    final String imagePath;

    if (imageValue.startsWith('http://') ||
        imageValue.startsWith('https://')) {
      imagePath = imageValue;
    } else if (imageValue.toLowerCase().contains('basket')) {
      imagePath = 'assets/meal1.jpg';
    } else {
      imagePath = 'assets/meal2.jpg';
    }

    return _Meal(
      id: int.tryParse('${json['mealID']}') ?? 0,
      name: (json['mealName'] ?? '').toString(),
      subtitle: (json['description'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      image: imagePath,
      price: (double.tryParse('${json['price']}') ?? 0).round(),
      quantity: int.tryParse('${json['quantity']}') ?? 0,
      restaurantName:
          (json['organisationName'] ?? 'مطعم غير محدد').toString(),
      city: (json['city'] ?? 'مدينة غير محددة').toString(),
    );
  }
}

class AllMealsPage extends StatefulWidget {
  const AllMealsPage({super.key});

  @override
  State<AllMealsPage> createState() => _AllMealsPageState();
}

class _AllMealsPageState extends State<AllMealsPage> {
  static const _green = Color(0xFF0C4B3A);
  static const _gold = Color(0xFFC6963C);
  static const _muted = Color(0xFF73807B);
  static const _goldLight = Color(0xFFFBF4E4);

  List<_Meal> _meals = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final response = await http
          .get(Uri.parse(mealsApiUrl))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final decoded = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      if (decoded is! List) {
        throw const FormatException(
          'تنسيق بيانات الوجبات غير صحيح',
        );
      }

      final loadedMeals = decoded
          .whereType<Map<String, dynamic>>()
          .map(_Meal.fromJson)
          .where((meal) => meal.id > 0 && meal.name.isNotEmpty)
          .toList();

      if (!mounted) return;

      setState(() {
        _meals = loadedMeals;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error =
            'تعذر تحميل الوجبات. تحققي من الاتصال بالإنترنت وحاولي مجددًا.';
      });

      debugPrint('Meals API error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCFCFA),
        appBar: AppBar(
          backgroundColor: _green,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'جميع الوجبات',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                'اختر وجبتك المفضلة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Color(0xFFDDEBE5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          leading: IconButton(
            tooltip: 'رجوع',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  // عرض الوجبات حسب المدينة ثم المطعم
  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: _green),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                color: _muted,
                size: 45,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: _muted,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadMeals,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    if (_meals.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد وجبات متاحة حاليًا',
          style: TextStyle(
            fontFamily: 'Cairo',
            color: _muted,
          ),
        ),
      );
    }

    // تجميع الوجبات حسب المدينة والمطعم
    final Map<String, Map<String, List<_Meal>>> groupedMeals = {};

    for (final meal in _meals) {
      final city = meal.city.trim().isEmpty
          ? 'مدينة غير محددة'
          : meal.city.trim();

      final restaurant = meal.restaurantName.trim().isEmpty
          ? 'مطعم غير محدد'
          : meal.restaurantName.trim();

      groupedMeals.putIfAbsent(city, () => {});

      groupedMeals[city]!.putIfAbsent(restaurant, () => []);

      groupedMeals[city]![restaurant]!.add(meal);
    }

    // مكة أولًا ثم المدينة
    final cities = groupedMeals.keys.toList();

    const cityOrder = {
      'مكة المكرمة': 0,
      'المدينة المنورة': 1,
    };

    cities.sort((a, b) {
      final orderA = cityOrder[a] ?? 2;
      final orderB = cityOrder[b] ?? 2;

      if (orderA != orderB) {
        return orderA.compareTo(orderB);
      }

      return a.compareTo(b);
    });

    return RefreshIndicator(
      color: _green,
      onRefresh: _loadMeals,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          for (final city in cities)
            _buildCitySection(
              city,
              groupedMeals[city]!,
            ),
        ],
      ),
    );
  }

  // قسم المدينة
  Widget _buildCitySection(
    String city,
    Map<String, List<_Meal>> restaurants,
  ) {
    final restaurantNames = restaurants.keys.toList()..sort();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: _green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: _gold,
                  size: 23,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    city,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          for (final restaurant in restaurantNames)
            _buildRestaurantSection(
              restaurant,
              restaurants[restaurant]!,
            ),
        ],
      ),
    );
  }

  // قسم المطعم ووجباته
  Widget _buildRestaurantSection(
    String restaurant,
    List<_Meal> meals,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                const Icon(
                  Icons.restaurant_rounded,
                  color: _gold,
                  size: 21,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    restaurant,
                    style: const TextStyle(
                      color: _green,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  '${meals.length} وجبات',
                  style: const TextStyle(
                    color: _muted,
                    fontFamily: 'Cairo',
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          for (int i = 0; i < meals.length; i++) ...[
            _mealCard(meals[i]),
            if (i != meals.length - 1)
              const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  // بطاقة الوجبة
  Widget _mealCard(_Meal meal) {
    final available = meal.quantity > 0;

    return _PressScale(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFF0E5CD),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _mealImage(
                    meal,
                    width: 150,
                    height: 165,
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: available ? _green : Colors.grey,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      available ? 'متاح للطلب' : 'نفدت الكمية',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    meal.name,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: _green,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meal.subtitle,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: _muted,
                      fontFamily: 'Cairo',
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meal.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: _muted,
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'الكمية المتوفرة: ${meal.quantity}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: _muted,
                      fontFamily: 'Cairo',
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: _gold,
                        size: 15,
                      ),
                      Icon(
                        Icons.star_rounded,
                        color: _gold,
                        size: 15,
                      ),
                      Icon(
                        Icons.star_rounded,
                        color: _gold,
                        size: 15,
                      ),
                      Icon(
                        Icons.star_rounded,
                        color: _gold,
                        size: 15,
                      ),
                      Icon(
                        Icons.star_rounded,
                        color: _gold,
                        size: 15,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '(5.0)',
                        style: TextStyle(
                          color: _muted,
                          fontFamily: 'Cairo',
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${meal.price} رس',
                        style: const TextStyle(
                          color: _gold,
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: available
                            ? () => _showMealSheet(meal)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _gold,
                          disabledBackgroundColor:
                              Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          tapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'اطلب الآن',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // صورة الوجبة
  Widget _mealImage(
    _Meal meal, {
    required double width,
    required double height,
  }) {
    final fallback = Container(
      width: width,
      height: height,
      color: _goldLight,
      alignment: Alignment.center,
      child: const Icon(
        Icons.rice_bowl_rounded,
        color: _gold,
        size: 42,
      ),
    );

    if (meal.image.startsWith('http://') ||
        meal.image.startsWith('https://')) {
      return Image.network(
        meal.image,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    return Image.asset(
      meal.image,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
    );
  }

  // نافذة اختيار كمية الوجبة وإضافتها للسلة
  Future<void> _showMealSheet(_Meal meal) async {
    var quantity = 1;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  meal.name,
                  style: const TextStyle(
                    color: Color(0xFF1B2C27),
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meal.subtitle,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'السعر الأساسي: ${meal.price} ر.س',
                  style: const TextStyle(
                    color: Color(0xFF1B2C27),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: quantity > 1
                          ? () => setSheetState(() => quantity--)
                          : null,
                      icon: const Icon(Icons.remove),
                      color: _green,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                      ),
                      child: Text(
                        '$quantity',
                        style: const TextStyle(
                          color: Color(0xFF1B2C27),
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: quantity < meal.quantity
                          ? () => setSheetState(() => quantity++)
                          : null,
                      icon: const Icon(Icons.add),
                      color: _green,
                    ),
                  ],
                ),
                if (meal.quantity < 5)
                  Text(
                    'المتوفر حاليًا: ${meal.quantity} وجبات',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 12,
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'الإجمالي',
                      style: TextStyle(
                        color: Color(0xFF1B2C27),
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${meal.price * quantity} ر.س',
                      style: const TextStyle(
                        color: _gold,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: meal.quantity <= 0
                        ? null
                        : () {
                            CartData.addOrUpdate(
                              CartItem(
                                mealId: meal.id,
                                name: meal.name,
                                price: meal.price,
                                imageUrl: meal.image,
                                restaurantName: meal.restaurantName,
                                city: meal.city,
                                quantity: quantity,
                              ),
                            );

                            Navigator.pop(sheetContext);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'تمت إضافة الوجبة إلى طلباتك',
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'أضف إلى الطلبات',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PressScale extends StatefulWidget {
  const _PressScale({required this.child});

  final Widget child;

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 150),
        child: widget.child,
      ),
    );
  }
}