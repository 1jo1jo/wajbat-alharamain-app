import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';

import 'cart_data.dart';
import 'all_meals_page.dart';
import 'orders_page.dart';
import 'donation_page.dart';
import 'account_page.dart';
import 'distribution_page.dart';
import 'notifications_page.dart';
import 'organizations_page.dart';
import 'report_page.dart';
import 'about_page.dart';
import 'splash_page.dart';

final ValueNotifier<bool> isUserLoggedInNotifier = ValueNotifier(false);
bool orderPlaced = false;
String selectedDistributionLocation = 'المسجد الحرام - باب الملك فهد';
final ValueNotifier<List<Map<String, String>>> notificationsNotifier =
    ValueNotifier([]);

const _makkahDistributionLocations = [
  'المسجد الحرام - باب الملك فهد',
  'مخيم منى - المنطقة 3',
  'مخيم عرفات - الجبل',
  'منطقة العزيزية',
  'منطقة الششة',
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);
  runApp(const MyApp());
}

Route _slideRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween(
        begin: const Offset(-1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      final fade = Tween(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn));
      return SlideTransition(
        position: slide,
        child: FadeTransition(opacity: fade, child: child),
      );
    },
  );
}

class AnimatedButton extends StatefulWidget {
  const AnimatedButton({super.key, required this.child});

  final Widget child;

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'وجبة الحرمين',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: _Colors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: _Colors.green),
        fontFamily: 'Arial',
      ),
      home: const SplashPage(),
    );
  }
}

class _Colors {
  static const green = Color(0xFF0C4B3A);
  static const gold = Color(0xFFC6963C);
  static const goldLight = Color(0xFFFBF4E4);
  static const background = Color(0xFFFCFCFA);
  static const ink = Color(0xFF1B2C27);
  static const muted = Color(0xFF73807B);
}

class _HomeMeal {
  final int id;
  final String name;
  final String description;
  final String image;
  final int price;
  final int quantity;
  final String restaurantName;
  final String city;

  _HomeMeal({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.quantity,
    required this.restaurantName,
    required this.city,
  });

  factory _HomeMeal.fromJson(Map<String, dynamic> json) {
    return _HomeMeal(
      id: int.tryParse('${json['mealID']}') ?? 0,
      name: (json['mealName'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      price: (double.tryParse('${json['price']}') ?? 0).round(),
      quantity: int.tryParse('${json['quantity']}') ?? 0,
      restaurantName: (json['organisationName'] ?? 'مطعم غير محدد').toString(),
      city: (json['city'] ?? 'مدينة غير محددة').toString(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _welcomeAnimation;
  late final Animation<double> _mealsAnimation;
  late final Animation<double> _tipAnimation;

  List<_HomeMeal> _homeMeals = [];
  bool _isLoadingMeals = true;
  String? _mealsError;

  static const String _mealsApiUrl =
      'https://haramain-backend.onrender.com/meals';

  Future<void> _loadHomeMeals() async {
    try {
      final response = await http.get(Uri.parse(_mealsApiUrl));

      if (response.statusCode != 200) {
        throw Exception('فشل تحميل الوجبات');
      }

      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

      final allMeals = data
          .map((item) => _HomeMeal.fromJson(item))
          .where((meal) => meal.id > 0 && meal.name.isNotEmpty)
          .where((meal) => meal.quantity > 0)
          .toList();

      // Filter for exactly the two meals requested
      final meals = allMeals.where((meal) =>
        meal.name.contains('شكشوكة') || meal.name.contains('مندي'),
      ).toList();

      // If found, use them. Otherwise fallback to first two.
      final displayMeals = meals.isNotEmpty ? meals : allMeals;

      if (!mounted) return;

      setState(() {
        _homeMeals = displayMeals.take(2).toList();
        _isLoadingMeals = false;
        _mealsError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingMeals = false;
        _mealsError = 'تعذر تحميل الوجبات، حاولي مرة أخرى';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadHomeMeals();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _welcomeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0, 0.7, curve: Curves.easeOutCubic),
    );
    _mealsAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.125, 0.825, curve: Curves.easeOutCubic),
    );
    _tipAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.25, 1, curve: Curves.easeOutCubic),
    );
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        drawer: Drawer(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0C4B3A), Color(0xFF1A6B50)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFC6963C)
                                    .withValues(alpha: 0.5),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'وجبة الحرمين',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Row(
                          children: [
                            SizedBox(
                              width: 30,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Color(0xFFC6963C),
                                ),
                                child: SizedBox(height: 2),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'معك في كل خطوة',
                              style: TextStyle(
                                color: Color(0xFFC6963C),
                                fontSize: 13,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      children: [
                        _drawerItem(Icons.home_rounded, 'الرئيسية', () {
                          Navigator.pop(context);
                        }),
                        _drawerItem(
                          Icons.volunteer_activism_rounded,
                          'تبرع',
                          () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const DonationPage(),
                              ),
                            );
                          },
                        ),
                        _drawerItem(Icons.shopping_bag_outlined, 'طلباتي', () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const OrdersPage(),
                            ),
                          );
                        }),
                        _drawerItem(Icons.person_outline, 'حسابي', () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const AccountPage(),
                            ),
                          );
                        }),
                        _drawerItem(
                          Icons.location_on_outlined,
                          'مواقع التوزيع',
                          () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const DistributionPage(),
                              ),
                            );
                          },
                        ),
                        _drawerItem(Icons.notifications_none, 'الإشعارات', () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const NotificationsPage(),
                            ),
                          );
                        }),
                        _drawerItem(
                          Icons.report_gmailerrorred,
                          'الإبلاغ عن مشكلة',
                          () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const ReportPage(),
                              ),
                            );
                          },
                        ),
                        _drawerItem(Icons.business, 'الجهات المشاركة', () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const OrganizationsPage(),
                            ),
                          );
                        }),
                        _drawerItem(Icons.info_outline, 'عن التطبيق', () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const AboutPage(),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF0C4B3A).withValues(alpha: 0.15),
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      leading: const Icon(
                        Icons.logout,
                        color: Color(0xFF0C4B3A),
                        size: 22,
                      ),
                      title: const Text(
                        'تسجيل الخروج',
                        style: TextStyle(
                          color: Color(0xFF0C4B3A),
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      onTap: () {
                        isUserLoggedInNotifier.value = false;
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final padding = constraints.maxWidth > 600 ? 48.0 : 20.0;
              return CustomScrollView(
                slivers: [
                  _section(
                    padding,
                    18,
                    0,
                    Builder(builder: (context) => _header(context)),
                  ),
                  _section(
                    padding,
                    24,
                    0,
                    _entrance(_welcomeAnimation, _welcome(context)),
                  ),
                  _section(
                    padding,
                    30,
                    0,
                    _entrance(_mealsAnimation, _meals(context)),
                  ),
                  _section(padding, 12, 0, _distributionService(context)),
                  _section(padding, 22, 32, _entrance(_tipAnimation, _tip())),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: _bottomNavigation(context),
      ),
    );
  }

  Widget _entrance(Animation<double> animation, Widget child) {
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(animation);
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(position: slide, child: child),
    );
  }

  SliverPadding _section(
    double horizontal,
    double top,
    double bottom,
    Widget child,
  ) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom),
      sliver: SliverToBoxAdapter(child: child),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3EF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF0C4B3A), size: 22),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Color(0xFF1B2C27),
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _Colors.green,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 25),
            tooltip: 'القائمة',
          ),
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Image.asset(
                'assets/logo.png',
                width: 55,
                height: 55,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'وجبة الحرمين',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              Text(
                'طريقك إلى الطمأنينة',
                style: TextStyle(color: Color(0xFFDDEBE5), fontSize: 11),
              ),
            ],
          ),
          const Spacer(),
          ValueListenableBuilder<List<Map<String, String>>>(
            valueListenable: notificationsNotifier,
            builder: (context, notifications, _) {
              final count = notifications
                  .where(
                    (notification) =>
                        notification['read'] != 'true' &&
                        notification['unread'] != 'false',
                  )
                  .length;
              return Stack(
                children: [
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const NotificationsPage(),
                      ),
                    ),
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
                    tooltip: 'التنبيهات',
                  ),
                  if (count > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$count',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _welcome(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _Colors.green,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x180C4B3A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'السلام عليكم،',
                  style: TextStyle(color: Color(0xFFDDEBE5), fontSize: 14),
                ),
                const SizedBox(height: 5),
                const Text(
                  'رحلتك المباركة تبدأ هنا',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 21,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    _slideRoute(const DonationPage()),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: _Colors.gold,
                    padding: EdgeInsets.zero,
                  ),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const AnimatedButton(
                    child: Text(
                      'تبرع الآن',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.mosque_outlined, color: Color(0x55FFFFFF), size: 88),
        ],
      ),
    );
  }

  Widget _meals(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'وجبات الحجاج',
              style: TextStyle(
                color: _Colors.ink,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                _slideRoute(const AllMealsPage()),
              ),
              child: const Text(
                'عرض الكل',
                style: TextStyle(
                  color: _Colors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const Text(
          'وجبات طازجة تصل إليك في الوقت المناسب',
          style: TextStyle(color: _Colors.muted, fontSize: 13),
        ),
        const SizedBox(height: 14),

        if (_isLoadingMeals)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(25),
              child: CircularProgressIndicator(
                color: _Colors.green,
              ),
            ),
          )
        else if (_mealsError != null)
          Center(
            child: Column(
              children: [
                Text(
                  _mealsError!,
                  style: const TextStyle(color: _Colors.muted),
                ),
                TextButton(
                  onPressed: _loadHomeMeals,
                  child: const Text(
                    'إعادة المحاولة',
                    style: TextStyle(color: _Colors.green),
                  ),
                ),
              ],
            ),
          )
        else if (_homeMeals.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'لا توجد وجبات متاحة حاليًا',
                style: TextStyle(color: _Colors.muted),
              ),
            ),
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_homeMeals.isNotEmpty)
                Expanded(
                  child: _MealCard(
                    title: _homeMeals[0].name,
                    subtitle: _homeMeals[0].description,
                    price: '${_homeMeals[0].price} رس',
                    basePrice: _homeMeals[0].price,
                    imagePath: _homeMeals[0].image,
                    onTap: (basePrice, imageUrl) =>
                        _showMealSheet(context, _homeMeals[0]),
                  ),
                ),
              if (_homeMeals.length > 1) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _MealCard(
                    title: _homeMeals[1].name,
                    subtitle: _homeMeals[1].description,
                    price: '${_homeMeals[1].price} رس',
                    basePrice: _homeMeals[1].price,
                    imagePath: _homeMeals[1].image,
                    onTap: (basePrice, imageUrl) =>
                        _showMealSheet(context, _homeMeals[1]),
                  ),
                ),
              ]
            ],
          ),
      ],
    );
  }

  Widget _distributionService(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DistributionPage()),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _Colors.goldLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: _Colors.gold,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مواقع التوزيع',
                      style: TextStyle(
                        color: _Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    Text(
                      'تعرف على أماكن استلام الوجبات',
                      style: TextStyle(
                        color: _Colors.muted,
                        fontSize: 12,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left, color: _Colors.muted, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMealSheet(
    BuildContext pageContext,
    _HomeMeal meal,
  ) async {
    var quantity = 1;
    var sheetStep = 1;
    var selectedLocationIndex = -1;
    await showModalBottomSheet<void>(
      context: pageContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetStateContext, setSheetState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(sheetStateContext).height * 0.9,
                ),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                    if (sheetStep == 1) ...[
                      Text(
                        meal.name,
                        style: const TextStyle(
                          color: _Colors.ink,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meal.description,
                        style: const TextStyle(
                          color: _Colors.muted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'السعر الأساسي: ${meal.price} ر.س',
                        style: const TextStyle(
                          color: _Colors.ink,
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
                            color: _Colors.green,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Text(
                              '$quantity',
                              style: const TextStyle(
                                color: _Colors.ink,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => setSheetState(() => quantity++),
                            icon: const Icon(Icons.add),
                            color: _Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'الإجمالي',
                            style: TextStyle(
                              color: _Colors.ink,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${meal.price * quantity} ر.س',
                            style: const TextStyle(
                              color: _Colors.gold,
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
                          onPressed: () => setSheetState(() => sheetStep = 2),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'أضف إلى الطلبات',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'اختر موقع الاستلام',
                        style: TextStyle(
                          color: _Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'حدد المكان الأنسب لك لاستلام طلبك',
                        style: TextStyle(
                          color: _Colors.muted,
                          fontSize: 12,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            children: List.generate(
                              _makkahDistributionLocations.length,
                              (index) {
                                final isSelected =
                                    selectedLocationIndex == index;
                                return InkWell(
                                  onTap: () => setSheetState(
                                    () => selectedLocationIndex = index,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFEAF3EF)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? _Colors.green
                                            : const Color(0xFFE0E0E0),
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: isSelected
                                              ? _Colors.green
                                              : _Colors.muted,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            _makkahDistributionLocations[index],
                                            style: TextStyle(
                                              color: isSelected
                                                  ? _Colors.green
                                                  : Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              fontFamily: 'Cairo',
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(
                                            Icons.check_circle,
                                            color: _Colors.green,
                                            size: 22,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: selectedLocationIndex == -1
                              ? null
                              : () {
                                  selectedDistributionLocation =
                                      _makkahDistributionLocations[selectedLocationIndex];
                                  CartData.addOrUpdate(
                                    CartItem(
                                      mealId: meal.id,
                                      name: meal.name,
                                      price: meal.price,
                                      imageUrl: meal.image,
                                      restaurantName: meal.restaurantName,
                                      city: meal.city,
                                      distributionLocation:
                                          selectedDistributionLocation,
                                      quantity: quantity,
                                    ),
                                  );
                                  Navigator.pop(sheetContext);
                                  ScaffoldMessenger.of(pageContext)
                                      .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'تم الطلب - سيتم الاستلام من: '
                                            '$selectedDistributionLocation',
                                            style: const TextStyle(
                                              fontFamily: 'Cairo',
                                            ),
                                          ),
                                        ),
                                      );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _Colors.green,
                            disabledBackgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'تأكيد الطلب',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () => setSheetState(() => sheetStep = 1),
                          child: const Text(
                            'رجوع',
                            style: TextStyle(
                              color: _Colors.green,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _tip() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _Colors.goldLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: _Colors.gold, size: 30),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'نصيحة اليوم\nأكثر من التلبية بقلب حاضر وروح مطمئنة.',
              style: TextStyle(
                color: _Colors.ink,
                height: 1.6,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(Icons.chevron_left_rounded, color: _Colors.gold),
        ],
      ),
    );
  }

  Widget _bottomNavigation(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        if (index == 1) {
          Navigator.push(context, _slideRoute(const DonationPage()));
        } else if (index == 2) {
          Navigator.push(context, _slideRoute(const OrdersPage()));
        } else if (index == 3) {
          Navigator.push(context, _slideRoute(const AccountPage()));
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: _Colors.green,
      unselectedItemColor: _Colors.muted,
      backgroundColor: Colors.white,
      elevation: 12,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 11,
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.volunteer_activism_rounded),
          label: 'تبرع',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          label: 'طلباتي',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          label: 'حسابي',
        ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.price,
    required this.basePrice,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String imagePath;
  final String price;
  final int basePrice;
  final Function(int basePrice, String imagePath)? onTap;

  Widget _buildImage(String imagePath) {
    if (imagePath.isEmpty) {
      return Container(
        width: 150,
        height: 170,
        color: const Color(0xFFEAF3EF),
        child: const Icon(Icons.restaurant, color: _Colors.green, size: 40),
      );
    }

    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: 150,
        height: 170,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 150,
          height: 170,
          color: const Color(0xFFEAF3EF),
          child: const Icon(Icons.restaurant, color: _Colors.green, size: 40),
        ),
      );
    }

    return Image.asset(
      imagePath,
      width: 150,
      height: 170,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: 150,
        height: 170,
        color: const Color(0xFFEAF3EF),
        child: const Icon(Icons.restaurant, color: _Colors.green, size: 40),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0E5CD)),
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
                child: _buildImage(imagePath),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _Colors.green,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'متاح للطلب',
                    style: TextStyle(
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
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: _Colors.green,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: _Colors.muted,
                    fontFamily: 'Cairo',
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        color: _Colors.gold,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    AnimatedButton(
                      child: ElevatedButton(
                        onPressed: () => onTap?.call(basePrice, imagePath),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC6963C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 12,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'اطلب',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
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
    );
  }
}
