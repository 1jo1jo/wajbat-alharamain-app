import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'login_page.dart';
import 'user_session.dart';
import 'main.dart' show isUserLoggedInNotifier;

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  static const String _baseUrl = 'https://haramain-backend.onrender.com';

  static const Color _green = Color(0xFF0B4F34);
  static const Color _gold = Color(0xFFC6963C);

  int _selectedTab = 0;
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _donations = [];
  List<Map<String, dynamic>> _payments = [];
  List<Map<String, dynamic>> _meals = [];
  List<Map<String, dynamic>> _organisations = [];

  DateTime? _reportStartDate;
  DateTime? _reportEndDate;

  List<Map<String, dynamic>> get _restaurants =>
      _users.where((user) => user['role'] == 'restaurant').toList();

  List<Map<String, dynamic>> get _couriers =>
      _users.where((user) => user['role'] == 'courier').toList();

  List<Map<String, dynamic>> get _customers =>
      _users.where((user) => user['role'] == 'user').toList();

  String get _token {
    final user = currentUserNotifier.value;
    return (user?['token'] ?? '').toString();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (_token.isEmpty) {
      setState(() {
        _errorMessage = 'انتهت الجلسة أو لم يتم العثور على رمز الدخول.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final responses = await Future.wait([
        http.get(
          Uri.parse('$_baseUrl/admin/orders'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        ).timeout(const Duration(seconds: 30)),
        http.get(
          Uri.parse('$_baseUrl/admin/users'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        ).timeout(const Duration(seconds: 30)),
        http.get(
          Uri.parse('$_baseUrl/donations'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        ).timeout(const Duration(seconds: 30)),
        http.get(
          Uri.parse('$_baseUrl/payments'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        ).timeout(const Duration(seconds: 30)),
        http.get(
          Uri.parse('$_baseUrl/meals'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        ).timeout(const Duration(seconds: 30)),
        http.get(
          Uri.parse('$_baseUrl/organisations'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        ).timeout(const Duration(seconds: 30)),
      ]);

      if (!mounted) return;

      final ordersResponse = responses[0];
      final usersResponse = responses[1];

      if (ordersResponse.statusCode == 200) {
        final decoded = jsonDecode(ordersResponse.body);

        if (decoded is List) {
          _orders = decoded
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }

      if (usersResponse.statusCode == 200) {
        final decoded = jsonDecode(usersResponse.body);

        if (decoded is List) {
          _users = decoded
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }

      List<Map<String, dynamic>> parseList(http.Response response) {
        if (response.statusCode != 200) return [];
        final decoded = jsonDecode(response.body);
        if (decoded is! List) return [];
        return decoded
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      _donations = parseList(responses[2]);
      _payments = parseList(responses[3]);
      _meals = parseList(responses[4]);
      _organisations = parseList(responses[5]);

      if (ordersResponse.statusCode == 401 ||
          ordersResponse.statusCode == 403 ||
          usersResponse.statusCode == 401 ||
          usersResponse.statusCode == 403) {
        _errorMessage =
            'لا يمكن الوصول إلى البيانات. تأكدي من صلاحيات حساب الأدمن.';
      } else if (ordersResponse.statusCode != 200 &&
          usersResponse.statusCode != 200) {
        _errorMessage = 'تعذر تحميل البيانات من الخادم.';
      }
    } catch (_) {
      if (!mounted) return;
      _errorMessage = 'تعذر الاتصال بالخادم. حاولي مرة أخرى.';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> updateOrderStatus(Map<String, dynamic> order) async {
    final id = order['requestId'] ?? order['id'];
    if (id == null) {
      _showMessage('لم يتم العثور على رقم الطلب.');
      return;
    }

    const statuses = ['pending', 'confirmed', 'preparing', 'ready', 'delivered'];
    final currentStatus = (order['status'] ?? 'pending').toString().toLowerCase();
    var selectedStatus = statuses.contains(currentStatus) ? currentStatus : 'pending';

    final newStatus = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Text('تحديث حالة الطلب', textAlign: TextAlign.center, style: TextStyle(color: _green, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                content: DropdownButtonFormField<String>(
                  value: selectedStatus,
                  isExpanded: true,
                  decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  items: const [
                    DropdownMenuItem(value: 'pending', child: Text('قيد الانتظار')),
                    DropdownMenuItem(value: 'confirmed', child: Text('تم القبول')),
                    DropdownMenuItem(value: 'preparing', child: Text('قيد التجهيز')),
                    DropdownMenuItem(value: 'ready', child: Text('جاهز للتوصيل')),
                    DropdownMenuItem(value: 'delivered', child: Text('تم التوصيل')),
                  ],
                  onChanged: (value) { if (value != null) setDialogState(() => selectedStatus = value); },
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white),
                    onPressed: () => Navigator.pop(dialogContext, selectedStatus),
                    child: const Text('حفظ'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (newStatus == null) return;

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/admin/orders/$id/status'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode({'status': newStatus}),
      ).timeout(const Duration(seconds: 30));

      if (!mounted) return;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _showMessage('تم تحديث حالة الطلب بنجاح.');
        await _loadData();
      } else {
        _showMessage('تعذر تحديث الحالة. رمز الاستجابة: ${response.statusCode}');
      }
    } catch (_) {
      if (!mounted) return;
      _showMessage('تعذر الاتصال بالخادم.');
    }
  }

  void _logout() {
    clearUserSession();
    isUserLoggedInNotifier.value = false;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _pickReportDate(bool isStart) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: (isStart ? _reportStartDate : _reportEndDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: isStart ? 'اختاري تاريخ البداية' : 'اختاري تاريخ النهاية',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
    );
    if (selected == null) return;
    setState(() {
      if (isStart) {
        _reportStartDate = selected;
      } else {
        _reportEndDate = selected;
      }
    });
  }

  bool _isWithinReportDateRange(dynamic value) {
    if (_reportStartDate == null && _reportEndDate == null) return true;
    if (value == null) return false;
    final date = DateTime.tryParse(value.toString());
    if (date == null) return false;
    final day = DateTime(date.year, date.month, date.day);
    if (_reportStartDate != null) {
      final start = DateTime(_reportStartDate!.year, _reportStartDate!.month, _reportStartDate!.day);
      if (day.isBefore(start)) return false;
    }
    if (_reportEndDate != null) {
      final end = DateTime(_reportEndDate!.year, _reportEndDate!.month, _reportEndDate!.day);
      if (day.isAfter(end)) return false;
    }
    return true;
  }

  Future<void> _generatePdfReport({
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
  }) async {
    try {
      final fontData = await rootBundle.load('assets/fonts/Cairo.ttf');
      final arabicFont = pw.Font.ttf(fontData);
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFont),
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Text(
                    'وجبة الحرمين',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    title,
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(fontSize: 17),
                  ),
                  pw.SizedBox(height: 20),
                  pw.TableHelper.fromTextArray(
                    headers: headers,
                    data: rows,
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                    cellStyle: const pw.TextStyle(fontSize: 9),
                    headerDecoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFFC6963C)),
                    cellAlignment: pw.Alignment.center,
                    headerAlignment: pw.Alignment.center,
                    border: pw.TableBorder.all(color: PdfColors.grey400),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر إنشاء التقرير: $e'),
        ),
      );
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, textDirection: TextDirection.rtl),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Widget _buildTabButton(String title, int index) {
    final selected = _selectedTab == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ElevatedButton(
        onPressed: () {
          setState(() => _selectedTab = index);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: selected ? _green : Colors.white,
          foregroundColor: selected ? Colors.white : _green,
          elevation: selected ? 2 : 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: _green),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildOrders() {
    if (_orders.isEmpty) {
      return const Center(child: Text('لا توجد طلبات لعرضها.', style: TextStyle(fontFamily: 'Cairo')));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        final id = order['requestId'] ?? order['id'] ?? '-';
        final userId = order['userId'] ?? '-';
        final date = order['requestDate'] ?? '-';
        final status = order['status'] ?? 'غير محدد';

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('الطلب رقم $id', textDirection: TextDirection.rtl, style: const TextStyle(color: _green, fontWeight: FontWeight.bold, fontSize: 17, fontFamily: 'Cairo'))),
                    const Icon(Icons.receipt_long, color: _gold),
                  ],
                ),
                const Divider(height: 24),
                Text('رقم المستخدم: $userId', textDirection: TextDirection.rtl),
                const SizedBox(height: 8),
                Text('تاريخ الطلب: $date', textDirection: TextDirection.rtl),
                const SizedBox(height: 8),
                Text('الحالة: ${_translateStatus(status)}', textDirection: TextDirection.rtl, style: const TextStyle(color: _green, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                const SizedBox(height: 8),
                Text('المطعم المسؤول: ${order['restaurantId'] ?? 'غير محدد'}', textDirection: TextDirection.rtl),
                const SizedBox(height: 8),
                Text('المندوب المسؤول: ${order['courierId'] ?? 'غير محدد'}', textDirection: TextDirection.rtl),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => updateOrderStatus(order),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('تحديث حالة الطلب', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _translateStatus(Object? status) {
    switch (status.toString().trim().toLowerCase()) {
      case 'pending':
        return 'قيد الانتظار';
      case 'confirmed':
        return 'تم القبول';
      case 'preparing':
        return 'قيد التجهيز';
      case 'ready':
        return 'جاهز للتوصيل';
      case 'delivered':
        return 'تم التوصيل';
      default:
        return status.toString();
    }
  }

  int get _totalOrders => _orders.length;
  int get _totalUsers => _users.length;
  int get _completedOrders => _orders.where((order) => (order['status'] ?? '').toString().toLowerCase() == 'delivered').length;

  String _translateRole(Object? role) {
    switch (role.toString().trim().toLowerCase()) {
      case 'user':
        return 'مستفيد';
      case 'restaurant':
        return 'صاحب مطعم';
      case 'courier':
        return 'مندوب توصيل';
      case 'admin':
        return 'مدير التطبيق';
      default:
        return role.toString();
    }
  }

  Future<void> _showAccountDetails(Map<String, dynamic> user) async {
    var isActive = user['isActive'] is bool ? user['isActive'] as bool : true;
    final fullName = (user['fullName'] ?? 'بدون اسم').toString().trim();
    final initial = fullName.isNotEmpty ? fullName.substring(0, 1) : '?';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: _green,
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          fullName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: _green,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _translateRole(user['role']),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: _gold,
                            fontSize: 13,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              _accountDetailRow(
                                Icons.email_outlined,
                                'الإيميل',
                                user['email'] ?? 'غير متوفر',
                              ),
                              const SizedBox(height: 12),
                              _accountDetailRow(
                                Icons.phone_outlined,
                                'الجوال',
                                user['phone'] ?? 'غير متوفر',
                              ),
                              const SizedBox(height: 12),
                              _accountDetailRow(
                                Icons.location_on_outlined,
                                'العنوان',
                                user['address'] ?? 'غير متوفر',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text(
                              'حالة الحساب',
                              style: TextStyle(
                                color: _green,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            const Spacer(),
                            Switch(
                              value: isActive,
                              activeColor: _green,
                              onChanged: (value) {
                                setDialogState(() => isActive = value);
                                final userIndex = _users.indexWhere(
                                  (item) => item['email'] == user['email'],
                                );
                                if (userIndex != -1) {
                                  setState(() {
                                    _users[userIndex]['isActive'] = value;
                                  });
                                }
                                _showMessage('تم تحديث حالة الحساب');
                              },
                            ),
                            Text(
                              isActive ? 'مفعل' : 'غير مفعل',
                              style: TextStyle(
                                color: isActive ? _green : Colors.red,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'إغلاق',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _accountDetailRow(IconData icon, String label, Object? value) {
    return Row(
      children: [
        Icon(icon, color: _gold, size: 20),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontFamily: 'Cairo',
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value?.toString() ?? 'غير متوفر',
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsers(List<Map<String, dynamic>> users) {
    if (users.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد حسابات لعرضها.',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];

        final id = user['userId'] ?? '-';
        final name = user['fullName'] ?? 'بدون اسم';
        final email = user['email'] ?? '-';
        final role = user['role'] ?? 'user';
        final isActive = user['isActive'] ?? true;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            onTap: () => _showAccountDetails(user),
            leading: CircleAvatar(
              backgroundColor: _green,
              child: Text(
                name.toString().isNotEmpty ? name.toString()[0] : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              name.toString(),
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$email\nالدور: ${_translateRole(role)}', textDirection: TextDirection.rtl),
                const SizedBox(height: 4),
                Text(
                  isActive == true ? 'مفعل' : 'غير مفعل',
                  style: TextStyle(
                    color: isActive == true ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => _showAccountDetails(user),
                  child: const Text(
                    'عرض',
                    style: TextStyle(
                      color: _gold,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '#$id',
                  style: const TextStyle(
                    color: _green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Future<void> _showAddUserDialog() async {
    final fullNameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final phoneController = TextEditingController();
    var selectedRole = 'user';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        var isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            Widget inputField({
              required TextEditingController controller,
              required String hint,
              required IconData icon,
              TextInputType? keyboardType,
              bool obscureText = false,
              TextDirection textDirection = TextDirection.rtl,
            }) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: keyboardType,
                        obscureText: obscureText,
                        textDirection: textDirection,
                        style: const TextStyle(fontFamily: 'Cairo'),
                        decoration: InputDecoration(
                          hintText: hint,
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontFamily: 'Cairo',
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Icon(icon, color: _gold, size: 21),
                  ],
                ),
              );
            }

            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.85,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'إضافة مستخدم جديد',
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: _green,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'أدخل بيانات المستخدم الجديد',
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 20),
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              inputField(
                                controller: fullNameController,
                                hint: 'الاسم الكامل',
                                icon: Icons.person_outline,
                              ),
                              inputField(
                                controller: emailController,
                                hint: 'البريد الإلكتروني',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                textDirection: TextDirection.ltr,
                              ),
                              inputField(
                                controller: passwordController,
                                hint: 'كلمة المرور',
                                icon: Icons.lock_outline,
                                obscureText: true,
                              ),
                              inputField(
                                controller: phoneController,
                                hint: 'رقم الجوال (اختياري)',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButton<String>(
                                        value: selectedRole,
                                        isExpanded: true,
                                        underline: const SizedBox.shrink(),
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontFamily: 'Cairo',
                                          fontSize: 13,
                                        ),
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'user',
                                            child: Text('مستفيد (طالب وجبة)'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'restaurant',
                                            child: Text('صاحب مطعم'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'courier',
                                            child: Text('مندوب توصيل'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'admin',
                                            child: Text('مدير التطبيق'),
                                          ),
                                        ],
                                        onChanged: isSubmitting
                                            ? null
                                            : (value) {
                                                if (value != null) {
                                                  setDialogState(
                                                    () => selectedRole = value,
                                                  );
                                                }
                                              },
                                      ),
                                    ),
                                    const Icon(
                                      Icons.badge_outlined,
                                      color: _gold,
                                      size: 21,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: isSubmitting
                                ? null
                                : () => Navigator.pop(dialogContext),
                            child: const Text(
                              'إلغاء',
                              style: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 120,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      final fullName = fullNameController.text
                                          .trim();
                                      final email = emailController.text.trim();
                                      final password = passwordController.text;

                                      if (fullName.isEmpty ||
                                          email.isEmpty ||
                                          password.isEmpty) {
                                        _showMessage(
                                          'يرجى إدخال الاسم الكامل والبريد الإلكتروني '
                                          'وكلمة المرور.',
                                        );
                                        return;
                                      }

                                      setDialogState(() => isSubmitting = true);

                                      try {
                                        final response = await http
                                            .post(
                                              Uri.parse(
                                                '$_baseUrl/admin/users',
                                              ),
                                              headers: {
                                                'Authorization':
                                                    'Bearer $_token',
                                                'Content-Type':
                                                    'application/json',
                                              },
                                              body: jsonEncode({
                                                'fullName': fullName,
                                                'username': email
                                                    .split('@')
                                                    .first,
                                                'email': email,
                                                'phone':
                                                    phoneController.text
                                                        .trim()
                                                        .isEmpty
                                                    ? null
                                                    : phoneController.text
                                                          .trim(),
                                                'password': password,
                                                'role': selectedRole,
                                              }),
                                            )
                                            .timeout(
                                              const Duration(seconds: 30),
                                            );

                                        if (!mounted) return;

                                        if (response.statusCode == 200 ||
                                            response.statusCode == 201) {
                                          if (dialogContext.mounted) {
                                            Navigator.pop(dialogContext);
                                          }
                                          _showMessage(
                                            'تم إضافة المستخدم بنجاح',
                                          );
                                          await _loadData();
                                        } else {
                                          var errorMessage =
                                              'تعذر إضافة المستخدم. رمز الاستجابة: '
                                              '${response.statusCode}';
                                          try {
                                            final decoded = jsonDecode(
                                              response.body,
                                            );
                                            if (decoded is Map) {
                                              final serverMessage =
                                                  decoded['message'] ??
                                                  decoded['error'];
                                              if (serverMessage != null &&
                                                  serverMessage
                                                      .toString()
                                                      .isNotEmpty) {
                                                errorMessage = serverMessage
                                                    .toString();
                                              }
                                            }
                                          } on FormatException {
                                            if (response.body
                                                .trim()
                                                .isNotEmpty) {
                                              errorMessage = response.body
                                                  .trim();
                                            }
                                          }

                                          _showMessage(errorMessage);
                                          if (dialogContext.mounted) {
                                            setDialogState(
                                              () => isSubmitting = false,
                                            );
                                          }
                                        }
                                      } catch (error) {
                                        if (!mounted) return;
                                        _showMessage(
                                          'تعذر الاتصال بالخادم: $error',
                                        );
                                        if (dialogContext.mounted) {
                                          setDialogState(
                                            () => isSubmitting = false,
                                          );
                                        }
                                      }
                                    },
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'حفظ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
  }

  Widget _buildReports() {
    final filteredOrders = _orders.where((item) {
      return _isWithinReportDateRange(
        item['requestDate'] ?? item['orderDate'] ?? item['createdAt'],
      );
    }).toList();

    final filteredDonations = _donations.where((item) {
      return _isWithinReportDateRange(item['donationDate']);
    }).toList();

    final filteredPayments = _payments.where((item) {
      return _isWithinReportDateRange(item['paymentDate']);
    }).toList();

    final reports = [
      {
        'title': 'تقرير الطلبات',
        'description': 'عرض الطلبات وحالاتها',
        'icon': Icons.shopping_bag_outlined,
        'headers': ['رقم الطلب', 'اسم العميل', 'الحالة', 'الإجمالي'],
        'rows': filteredOrders.map((order) => [
          (order['requestId'] ?? order['id'] ?? '').toString(),
          (order['fullName'] ?? order['customerName'] ?? '').toString(),
          (order['status'] ?? '').toString(),
          (order['totalAmount'] ?? order['total'] ?? '').toString(),
        ]).toList(),
      },
      {
        'title': 'تقرير التبرعات',
        'description': 'عرض التبرعات والمبالغ',
        'icon': Icons.volunteer_activism_outlined,
        'headers': ['رقم التبرع', 'المبلغ', 'التاريخ'],
        'rows': filteredDonations.map((item) => [
          (item['donationId'] ?? item['id'] ?? '').toString(),
          (item['amount'] ?? '').toString(),
          (item['donationDate'] ?? '').toString(),
        ]).toList(),
      },
      {
        'title': 'تقرير المدفوعات',
        'description': 'عرض عمليات الدفع',
        'icon': Icons.payment_outlined,
        'headers': ['رقم الدفع', 'المبلغ', 'التاريخ'],
        'rows': filteredPayments.map((item) => [
          (item['paymentId'] ?? item['id'] ?? '').toString(),
          (item['amount'] ?? '').toString(),
          (item['paymentDate'] ?? '').toString(),
        ]).toList(),
      },
      {
        'title': 'تقرير الوجبات',
        'description': 'عرض الوجبات وأسعارها وكمياتها',
        'icon': Icons.restaurant_outlined,
        'headers': ['اسم الوجبة', 'السعر', 'الكمية'],
        'rows': _meals.map((item) => [
          (item['mealName'] ?? item['name'] ?? '').toString(),
          (item['price'] ?? '').toString(),
          (item['quantity'] ?? '').toString(),
        ]).toList(),
      },
      {
        'title': 'تقرير الجهات المشاركة',
        'description': 'عرض بيانات الجهات المسجلة',
        'icon': Icons.business_outlined,
        'headers': ['اسم الجهة', 'رقم الهاتف', 'العنوان'],
        'rows': _organisations.map((item) => [
          (item['organisationName'] ?? item['name'] ?? '').toString(),
          (item['phone'] ?? '').toString(),
          (item['address'] ?? '').toString(),
        ]).toList(),
      },
    ];

    String formatDate(DateTime? date) {
      if (date == null) return 'غير محدد';
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'التقارير والإحصائيات',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _green,
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'حددي الفترة الزمنية للتقارير ثم اختاري التقرير المطلوب.',
          style: TextStyle(
            color: Colors.grey,
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickReportDate(true),
                      icon: const Icon(Icons.calendar_month),
                      label: Text(
                        'من: ${formatDate(_reportStartDate)}',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickReportDate(false),
                      icon: const Icon(Icons.calendar_month),
                      label: Text(
                        'إلى: ${formatDate(_reportEndDate)}',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _reportStartDate = null;
                    _reportEndDate = null;
                  });
                },
                icon: const Icon(Icons.restart_alt),
                label: const Text(
                  'مسح تحديد التاريخ',
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ...reports.map((report) {
          final rows = report['rows'] as List<List<String>>;
          final headers = report['headers'] as List<String>;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: Icon(
                report['icon'] as IconData,
                color: _gold,
                size: 30,
              ),
              title: Text(
                report['title'] as String,
                style: const TextStyle(
                  color: _green,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              subtitle: Text(
                '${report['description']} • عدد السجلات: ${rows.length}',
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.picture_as_pdf,
                  color: _green,
                ),
                onPressed: () {
                  if (_reportStartDate != null &&
                      _reportEndDate != null &&
                      _reportEndDate!.isBefore(_reportStartDate!)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تاريخ النهاية يجب أن يكون بعد تاريخ البداية'),
                      ),
                    );
                    return;
                  }

                  if (rows.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('لا توجد بيانات لإنشاء التقرير'),
                      ),
                    );
                    return;
                  }

                  _generatePdfReport(
                    title: report['title'] as String,
                    headers: headers,
                    rows: rows,
                  );
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminName = currentUserNotifier.value?['fullName'] ?? 'المدير';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F5),
        floatingActionButton: _selectedTab <= 2
            ? FloatingActionButton.extended(
                onPressed: _showAddUserDialog,
                backgroundColor: _green,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add),
                label: const Text(
                  'إضافة مستخدم',
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
              )
            : null,
        appBar: AppBar(
          backgroundColor: _green,
          foregroundColor: Colors.white,
          title: const Text(
            'لوحة تحكم المدير',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              tooltip: 'تحديث البيانات',
              onPressed: _isLoading ? null : _loadData,
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              tooltip: 'تسجيل الخروج',
              onPressed: _logout,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: _green,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'مرحباً بك',
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    adminName.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildSummaryCard(
                        'المطاعم',
                        _restaurants.length.toString(),
                        Icons.restaurant_outlined,
                      ),
                      const SizedBox(width: 12),
                      _buildSummaryCard(
                        'المندوبون',
                        _couriers.length.toString(),
                        Icons.delivery_dining,
                      ),
                      const SizedBox(width: 12),
                      _buildSummaryCard(
                        'المستخدمون',
                        _customers.length.toString(),
                        Icons.people_outline,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _buildTabButton('المستخدمون', 0),
                  _buildTabButton('المطاعم', 1),
                  _buildTabButton('المندوبون', 2),
                  _buildTabButton('الطلبات', 3),
                  _buildTabButton('التقارير', 4),
                ],
              ),
            ),
            if (_isLoading) const ConstPaddingPlaceholder(),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Expanded(
              child: switch (_selectedTab) {
                0 => _buildUsers(_customers),
                1 => _buildUsers(_restaurants),
                2 => _buildUsers(_couriers),
                3 => _buildOrders(),
                4 => _buildReports(),
                _ => _buildUsers(_customers),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: _gold, size: 26),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConstPaddingPlaceholder extends StatelessWidget {
  const ConstPaddingPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: CircularProgressIndicator(color: Color(0xFF0B4F34)),
    );
  }
}