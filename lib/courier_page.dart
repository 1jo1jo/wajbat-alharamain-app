import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'login_page.dart';
import 'main.dart' show isUserLoggedInNotifier;
import 'user_session.dart';

class CourierPage extends StatefulWidget {
  const CourierPage({super.key});

  @override
  State<CourierPage> createState() => _CourierPageState();
}

class _CourierPageState extends State<CourierPage> {
  static const String apiUrl =
      'https://haramain-backend.onrender.com';

  static const Color green = Color(0xFF0C4D3A);
  static const Color gold = Color(0xFFC4963A);
  static const Color background = Color(0xFFF7F8F7);

  List<dynamic> orders = [];

  bool isLoading = true;
  String? errorMessage;

  String get token {
    return currentUserNotifier.value?['token']?.toString() ?? '';
  }

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  // جلب الطلبات المسندة للمندوب
  Future<void> loadOrders() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (token.isEmpty) {
        throw Exception('انتهت جلسة تسجيل الدخول، سجلي الدخول مرة أخرى');
      }

      final response = await http.get(
        Uri.parse('$apiUrl/distributions/my'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'تعذر تحميل الطلبات (${response.statusCode})',
        );
      }

      final data = jsonDecode(response.body);

      if (data is! List) {
        throw Exception('صيغة البيانات المستلمة غير صحيحة');
      }

      if (!mounted) return;

      setState(() {
        orders = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  // تحديث حالة التوزيع
  Future<void> updateStatus(
    int distributionId,
    String status,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد تحديث الحالة'),
        content: const Text('هل تريدين تحديث حالة مهمة التوزيع؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              foregroundColor: Colors.white,
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await http.put(
        Uri.parse('$apiUrl/distributions/$distributionId/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'distributionStatus': status,
        }),
      );

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);

        throw Exception(
          data['message'] ?? 'تعذر تحديث الحالة',
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث حالة التوزيع بنجاح'),
          backgroundColor: green,
        ),
      );

      await loadOrders();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'ASSIGNED':
        return 'تم إسناد المهمة';
      case 'PICKED_UP':
        return 'تم الاستلام من المطعم';
      case 'IN_TRANSIT':
        return 'قيد النقل';
      case 'DELIVERED':
        return 'تم التسليم لنقطة التوزيع';
      case 'PENDING':
        return 'بانتظار المندوب';
      case 'COMPLETED':
        return 'مكتمل';
      default:
        return status;
    }
  }

  Color statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'DELIVERED':
      case 'COMPLETED':
        return Colors.green;
      case 'IN_TRANSIT':
        return Colors.orange;
      case 'PICKED_UP':
        return Colors.blue;
      default:
        return gold;
    }
  }

  // إحصائيات المندوب
  int get totalOrders => orders.length;

  int get activeOrders {
    return orders.where((order) {
      final status =
          order['distributionStatus'].toString().toUpperCase();

      return status != 'DELIVERED' && status != 'COMPLETED';
    }).length;
  }

  int get deliveredOrders {
    return orders.where((order) {
      final status =
          order['distributionStatus'].toString().toUpperCase();

      return status == 'DELIVERED' || status == 'COMPLETED';
    }).length;
  }

  // زر الإجراء حسب حالة المهمة
  Widget buildActionButton(Map<String, dynamic> order) {
    final int id = order['distributionID'];
    final status =
        order['distributionStatus'].toString().toUpperCase();

    if (status == 'ASSIGNED') {
      return actionButton(
        'تأكيد استلام الوجبات من المطعم',
        Icons.restaurant,
        () => updateStatus(id, 'PICKED_UP'),
      );
    }

    if (status == 'PICKED_UP') {
      return actionButton(
        'بدء النقل إلى نقطة التوزيع',
        Icons.local_shipping,
        () => updateStatus(id, 'IN_TRANSIT'),
      );
    }

    if (status == 'IN_TRANSIT') {
      return actionButton(
        'تأكيد التسليم لنقطة التوزيع',
        Icons.check_circle,
        () => updateStatus(id, 'DELIVERED'),
      );
    }

    if (status == 'DELIVERED' || status == 'COMPLETED') {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text(
              'تم تسليم المهمة',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget actionButton(
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  // بطاقة إحصائية
  Widget statCard(String title, int value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: gold, size: 27),
            const SizedBox(height: 9),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              '$value',
              style: const TextStyle(
                color: green,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بطاقة التوزيع
  Widget orderCard(Map<String, dynamic> order) {
    final status = order['distributionStatus']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'توزيع رقم #${order['distributionID']}',
                style: const TextStyle(
                  color: green,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel(status),
                  style: TextStyle(
                    color: statusColor(status),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 25),

          infoRow(
            Icons.inventory_2_outlined,
            'الكمية',
            '${order['distributionQuantity']} وجبة',
          ),

          infoRow(
            Icons.location_on_outlined,
            'نقطة التوزيع',
            '${order['distributionLocation']}',
          ),

          infoRow(
            Icons.calendar_today_outlined,
            'التاريخ',
            '${order['distributionDate']}',
          ),

          infoRow(
            Icons.confirmation_number_outlined,
            'رقم الطلب',
            '#${order['requestId']}',
          ),

          const SizedBox(height: 15),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Text(
              'مسار التوصيل: المطعم ← المندوب ← نقطة التوزيع',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: green,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 15),

          buildActionButton(order),
        ],
      ),
    );
  }

  Widget infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: gold, size: 20),
          const SizedBox(width: 9),
          Text(
            '$title: ',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
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
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: green,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'لوحة المندوب',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: loadOrders,
              icon: const Icon(Icons.refresh),
              tooltip: 'تحديث الطلبات',
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
        body: RefreshIndicator(
          onRefresh: loadOrders,
          color: green,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'مرحباً بك في لوحة المندوب',
                style: TextStyle(
                  color: green,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'متابعة طلبات التوصيل إلى نقاط التوزيع',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  statCard(
                    'إجمالي طلباتي',
                    totalOrders,
                    Icons.assignment_outlined,
                  ),
                  const SizedBox(width: 9),
                  statCard(
                    'قيد التوصيل',
                    activeOrders,
                    Icons.local_shipping_outlined,
                  ),
                  const SizedBox(width: 9),
                  statCard(
                    'تم تسليمها',
                    deliveredOrders,
                    Icons.check_circle_outline,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'طلباتي المسندة',
                    style: TextStyle(
                      color: green,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: loadOrders,
                    child: const Text(
                      'تحديث الطلبات',
                      style: TextStyle(color: green),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(35),
                  child: Center(
                    child: CircularProgressIndicator(color: green),
                  ),
                )
              else if (errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 35,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: loadOrders,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              else if (orders.isEmpty)
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        color: Colors.grey,
                        size: 45,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'لا توجد طلبات مسندة إليك حاليًا.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              else
                ...orders.map(
                  (order) => orderCard(
                    Map<String, dynamic>.from(order),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}