import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'login_page.dart';
import 'main.dart' show isUserLoggedInNotifier;
import 'user_session.dart';

class RestaurantPage extends StatefulWidget {
  const RestaurantPage({super.key});

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  static const String baseUrl = 'https://haramain-backend.onrender.com';

  static const Color darkGreen = Color(0xFF0C4B3A);
  static const Color gold = Color(0xFFC6963C);

  final List<Map<String, dynamic>> _meals = [];

  bool _loading = false;
  String? _error;

  String? get _token {
    final user = currentUserNotifier.value;

    if (user == null) return null;

    final value = user['token'] ?? user['accessToken'] ?? user['jwt'];

    if (value == null) return null;

    final token = value.toString().trim();

    return token.isEmpty ? null : token;
  }

  Map<String, String> get _authHeaders => {
        'Authorization': 'Bearer ${_token ?? ''}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_token == null) {
        throw Exception('رمز الدخول غير موجود. سجلي الدخول مرة أخرى.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/meals/my-meals'),
        headers: _authHeaders,
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception(
          'تعذر الوصول. تأكدي من تسجيل الدخول وصلاحية حساب المطعم.',
        );
      }

      if (response.statusCode != 200) {
        throw Exception('تعذر تحميل الوجبات (${response.statusCode}).');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception('صيغة بيانات الوجبات غير صحيحة.');
      }

      final meals = decoded
          .map<Map<String, dynamic>>(
            (item) => Map<String, dynamic>.from(item as Map),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        _meals
          ..clear()
          ..addAll(meals);
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: darkGreen),
    );
  }

  Future<void> _showMealForm({Map<String, dynamic>? meal}) async {
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(
      text: meal?['mealName']?.toString() ?? '',
    );

    final descriptionController = TextEditingController(
      text: meal?['description']?.toString() ?? '',
    );

    final priceController = TextEditingController(
      text: meal?['price']?.toString() ?? '',
    );

    final quantityController = TextEditingController(
      text: meal?['quantity']?.toString() ?? '',
    );

    String? imageUrl = meal?['image']?.toString();

    XFile? selectedImage;
    bool saving = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickImage() async {
              try {
                final picker = ImagePicker();

                final image = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 85,
                  maxWidth: 1600,
                );

                if (image != null) {
                  setDialogState(() {
                    selectedImage = image;
                  });
                }
              } catch (e) {
                _showMessage('تعذر اختيار الصورة.');
              }
            }

            Future<String?> uploadImage() async {
              if (selectedImage == null) return imageUrl;

              final token = _token;

              if (token == null) {
                throw Exception('رمز الدخول غير موجود.');
              }

              final uri = Uri.parse('$baseUrl/meals/upload-image');

              final request = http.MultipartRequest('POST', uri);

              request.headers['Authorization'] = 'Bearer $token';

              final bytes = await selectedImage!.readAsBytes();
              request.files.add(
                http.MultipartFile.fromBytes(
                  'file',
                  bytes,
                  filename: selectedImage!.name,
                ),
              );

              final streamedResponse = await request.send();

              final response = await http.Response.fromStream(streamedResponse);

              if (response.statusCode != 200) {
                throw Exception('فشل رفع الصورة (${response.statusCode}).');
              }

              final data = jsonDecode(response.body);

              if (data is! Map ||
                  data['imageUrl'] == null ||
                  data['imageUrl'].toString().isEmpty) {
                throw Exception('لم يرجع الباك إند رابط الصورة.');
              }

              return data['imageUrl'].toString();
            }

            Future<void> saveMeal() async {
              debugPrint('DEBUG: Starting saveMeal');
              if (saving) return;

              if (!(formKey.currentState?.validate() ?? false)) {
                return;
              }

              if (selectedImage == null &&
                  (imageUrl == null || imageUrl.isEmpty)) {
                _showMessage('اختاري صورة للوجبة أولًا.');
                return;
              }

              setDialogState(() => saving = true);

              try {
                debugPrint('DEBUG: Uploading image...');
                final uploadedImage = await uploadImage();
                debugPrint('DEBUG: Image uploaded successfully');

                if (uploadedImage == null || uploadedImage.isEmpty) {
                  throw Exception('رابط صورة الوجبة غير موجود.');
                }

                final payload = {
                  'mealName': nameController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'price': double.parse(priceController.text),
                  'quantity': int.parse(quantityController.text),
                  'image': uploadedImage,
                };

                final isEditing = meal != null;

                final uri = isEditing
                    ? Uri.parse('$baseUrl/meals/${meal['mealID']}')
                    : Uri.parse('$baseUrl/meals');

                final response = isEditing
                    ? await http.put(
                        uri,
                        headers: _authHeaders,
                        body: jsonEncode(payload),
                      )
                    : await http.post(
                        uri,
                        headers: _authHeaders,
                        body: jsonEncode(payload),
                      );

                if (response.statusCode == 200 || response.statusCode == 201) {
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }

                  _showMessage(
                    isEditing
                        ? 'تم تعديل الوجبة بنجاح.'
                        : 'تمت إضافة الوجبة بنجاح.',
                  );

                  await _loadMeals();
                } else {
                  throw Exception(
                    'تعذر حفظ الوجبة (${response.statusCode}): '
                    '${response.body}',
                  );
                }
              } catch (e) {
                debugPrint('DEBUG ERROR: $e');
                _showMessage(e.toString().replaceFirst('Exception: ', ''));

                setDialogState(() => saving = false);
              }
            }

            Widget buildField({
              required TextEditingController controller,
              required String label,
              required String hint,
              required IconData icon,
              int maxLines = 1,
              TextInputType? keyboardType,
              List<TextInputFormatter>? inputFormatters,
              String? Function(String?)? validator,
            }) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: darkGreen,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(icon, color: const Color(0xFFC6963C), size: 18),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TextFormField(
                      controller: controller,
                      textAlign: TextAlign.right,
                      maxLines: maxLines,
                      keyboardType: keyboardType,
                      inputFormatters: inputFormatters,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: hint,
                        hintStyle: const TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.grey,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      validator: validator,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }

            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                        Text(
                          meal == null ? 'إضافة وجبة' : 'تعديل الوجبة',
                          style: const TextStyle(
                            color: darkGreen,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 1.5,
                              color: const Color(0xFFC6963C),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.restaurant_menu,
                              color: Color(0xFFC6963C),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 60,
                              height: 1.5,
                              color: const Color(0xFFC6963C),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        buildField(
                          controller: nameController,
                          label: 'اسم الوجبة',
                          hint: 'اسم الوجبة',
                          icon: Icons.fastfood,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'أدخلي اسم الوجبة.';
                            }

                            if (value.trim().length > 100) {
                              return 'الاسم يجب ألا يتجاوز 100 حرف.';
                            }

                            return null;
                          },
                        ),
                        buildField(
                          controller: descriptionController,
                          label: 'وصف الوجبة',
                          hint: 'وصف الوجبة',
                          icon: Icons.description,
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'أدخلي وصف الوجبة.';
                            }

                            return null;
                          },
                        ),
                        buildField(
                          controller: priceController,
                          label: 'السعر',
                          hint: 'السعر',
                          icon: Icons.attach_money,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]'),
                            ),
                          ],
                          validator: (value) {
                            final price = double.tryParse(value ?? '');

                            if (price == null ||
                                !price.isFinite ||
                                price <= 0) {
                              return 'أدخلي سعرًا صحيحًا أكبر من صفر.';
                            }

                            return null;
                          },
                        ),
                        buildField(
                          controller: quantityController,
                          label: 'الكمية المتاحة',
                          hint: 'الكمية المتاحة',
                          icon: Icons.inventory_2,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            final quantity = int.tryParse(value ?? '');

                            if (quantity == null || quantity < 0) {
                              return 'أدخلي كمية صحيحة.';
                            }

                            return null;
                          },
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'الصورة الحالية',
                                      style: TextStyle(
                                        color: darkGreen,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Cairo',
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    OutlinedButton.icon(
                                      onPressed: saving ? null : pickImage,
                                      icon: const Icon(
                                        Icons.photo_library_outlined,
                                        color: darkGreen,
                                      ),
                                      label: const Text(
                                        'اختيار صورة',
                                        style: TextStyle(
                                          color: darkGreen,
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: darkGreen,
                                        side: const BorderSide(
                                          color: Color(0xFFC6963C),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (selectedImage != null)
                                FutureBuilder<Uint8List>(
                                  future: selectedImage!.readAsBytes(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }

                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.memory(
                                        snapshot.data!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  },
                                )
                              else if (imageUrl != null && imageUrl.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    imageUrl,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: Center(
                                        child: Icon(Icons.broken_image_outlined),
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton.icon(
                              onPressed: saving
                                  ? null
                                  : () => Navigator.of(dialogContext).pop(),
                              icon: const Icon(Icons.close, size: 18),
                              label: const Text('إلغاء'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: darkGreen,
                                side: const BorderSide(color: Color(0xFFC6963C)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                minimumSize: const Size(140, 50),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: saving ? null : saveMeal,
                              icon: const Icon(Icons.save_outlined, size: 18),
                              label: const Text('حفظ'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: darkGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                minimumSize: const Size(140, 50),
                              ),
                            ),
                          ],
                        ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    descriptionController.dispose();
    quantityController.dispose();
    priceController.dispose();
  }

  Future<void> _deleteMeal(Map<String, dynamic> meal) async {
    final mealId = meal['mealID'];

    if (mealId == null) {
      _showMessage('رقم الوجبة غير موجود.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف الوجبة'),
        content: Text(
          'هل أنتِ متأكدة من حذف "${meal['mealName'] ?? 'الوجبة'}"؟',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      if (_token == null) {
        throw Exception('رمز الدخول غير موجود.');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/meals/$mealId'),
        headers: _authHeaders,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _showMessage('تم حذف الوجبة.');
        await _loadMeals();
      } else {
        throw Exception('تعذر حذف الوجبة (${response.statusCode}).');
      }
    } catch (e) {
      debugPrint('DEBUG ERROR: $e');
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Widget _buildMealCard(Map<String, dynamic> meal) {
    final image = meal['image']?.toString() ?? '';
    final name = meal['mealName']?.toString() ?? 'وجبة';
    final description = meal['description']?.toString() ?? '';
    final price = meal['price'] ?? 0;
    final quantity = meal['quantity'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (image.isNotEmpty)
            Image.network(
              image,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 120,
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image_outlined, size: 48),
              ),
            )
          else
            Container(
              height: 120,
              color: Colors.grey.shade200,
              child: const Icon(Icons.restaurant, size: 48),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  name,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                  ),
                ),
                const SizedBox(height: 6),
                Text(description, textAlign: TextAlign.right),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('الكمية: $quantity'),
                    Text(
                      '$price ر.س',
                      style: const TextStyle(
                        color: darkGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showMealForm(meal: meal),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('تعديل'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: darkGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteMeal(meal),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('حذف'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8F6),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'إدارة الوجبات',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: darkGreen,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: _loading ? null : _loadMeals,
              tooltip: 'تحديث',
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              onPressed: () {
                clearUserSession();
                isUserLoggedInNotifier.value = false;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
              tooltip: 'تسجيل الخروج',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showMealForm(),
          backgroundColor: gold,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('إضافة وجبة'),
        ),
        body: RefreshIndicator(
          onRefresh: _loadMeals,
          child: _loading && _meals.isEmpty
              ? const Center(child: CircularProgressIndicator(color: darkGreen))
              : _error != null && _meals.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: [
                    const SizedBox(height: 100),
                    const Icon(
                      Icons.error_outline,
                      size: 54,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    Center(
                      child: FilledButton(
                        onPressed: _loadMeals,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ),
                  ],
                )
              : _meals.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: const [
                    SizedBox(height: 100),
                    Icon(Icons.restaurant_menu, size: 64, color: darkGreen),
                    SizedBox(height: 16),
                    Text(
                      'ما فيه وجبات مضافة حتى الآن',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'اضغطي على زر إضافة وجبة لبدء القائمة.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: _meals.length,
                  itemBuilder: (context, index) =>
                      _buildMealCard(_meals[index]),
                ),
        ),
      ),
    );
  }
}


