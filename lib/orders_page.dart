import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' hide TextDirection;

import 'cart_data.dart';
import 'user_session.dart';
import 'main.dart'
    show notificationsNotifier, orderPlaced, selectedDistributionLocation;
import 'rating_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  static const String _baseUrl = 'https://haramain-backend.onrender.com';
  static const _green = Color(0xFF0C4B3A);
  static const _gold = Color(0xFFC6963C);
  static const _lightGreen = Color(0xFFEAF3EF);
  static const _muted = Color(0xFF73807B);

  int? _createdRequestId;
  final _discountController = TextEditingController();
  int _selectedPaymentIndex = 0;
  bool _isProcessing = false;
  bool _showDetails = false;
  bool _discountApplied = false;
  bool _invalidDiscount = false;

  int get _subtotal => CartData.grandTotal;
  double get _discountAmount => _discountApplied ? _subtotal * 0.1 : 0;
  double get _finalTotal => _subtotal - _discountAmount;
  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCFCFA),
        appBar: AppBar(
          backgroundColor: _green,
          centerTitle: true,
          title: const Column(
            children: [
              Text(
                'طلباتي',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'راجعي طلبك قبل إتمام العملية',
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Cairo',
                  fontSize: 12,
                ),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _isProcessing
            ? _loadingScreen()
            : orderPlaced
            ? _ordersBody()
            : CartData.items.isEmpty
            ? const Center(
                child: Text(
                  'السلة فارغة',
                  style: TextStyle(
                    color: _muted,
                    fontFamily: 'Cairo',
                    fontSize: 16,
                  ),
                ),
              )
            : _ordersBody(),
      ),
    );
  }

  Widget _loadingScreen() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(color: _green, strokeWidth: 4),
            ),
            const SizedBox(height: 24),
            const Text(
              'جاري تنفيذ طلبك...',
              style: TextStyle(
                color: _green,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'يرجى الانتظار قليلاً',
              style: TextStyle(
                color: _muted,
                fontFamily: 'Cairo',
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ordersBody() {
    final today = DateFormat('d MMMM yyyy', 'ar').format(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (orderPlaced) ...[
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: _green,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.check, color: Colors.white, size: 55),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'تم تنفيذ طلبك بنجاح',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _green,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'رقم الطلب: #${_createdRequestId ?? '---'}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _muted,
                fontSize: 14,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 30),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: _orderStatusSection(),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: _orderDetailsCard(),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RatingPage()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _gold,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'قيّم وجبتك',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'العودة إلى السلة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            ...CartData.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x10000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _itemImage(item.imageUrl),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _green,
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints.tightFor(
                                  width: 26,
                                  height: 28,
                                ),
                                onPressed: item.quantity > 1
                                    ? () => _setItemQuantity(
                                        index,
                                        item.quantity - 1,
                                      )
                                    : null,
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  size: 24,
                                ),
                                color: _green,
                              ),
                              Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints.tightFor(
                                  width: 26,
                                  height: 28,
                                ),
                                onPressed: () =>
                                    _setItemQuantity(index, item.quantity + 1),
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  size: 24,
                                ),
                                color: _green,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.total} ر.س',
                      style: const TextStyle(
                        color: _gold,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      tooltip: 'حذف',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 28,
                        height: 32,
                      ),
                      onPressed: () => setState(() => CartData.remove(index)),
                      icon: const Icon(Icons.close, color: _muted, size: 18),
                    ),
                  ],
                ),
              );
            }),
            _sectionTitle('وقت التوصيل المتوقع'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: _green, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'اليوم، $today',
                          style: const TextStyle(
                            color: Color(0xFF202620),
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _sectionTitle('كود خصم'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _discountController,
                    textDirection: TextDirection.ltr,
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (_) => setState(() {
                      _discountApplied = false;
                      _invalidDiscount = false;
                    }),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'كود خصم',
                      hintStyle: const TextStyle(
                        fontFamily: 'Cairo',
                        color: _muted,
                      ),
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _applyDiscount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'تطبيق',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (_invalidDiscount) ...[
              const SizedBox(height: 4),
              const Text(
                'كود غير صحيح',
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'Cairo',
                  fontSize: 12,
                ),
              ),
            ],
            if (_discountApplied) ...[
              const SizedBox(height: 4),
              const Text(
                'تم تطبيق الخصم',
                style: TextStyle(
                  color: _green,
                  fontFamily: 'Cairo',
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'طريقة الدفع:',
                style: TextStyle(
                  color: _green,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _paymentOption(
                    index: 0,
                    label: 'دفع إلكتروني (مدى / فيزا)',
                    logo: const Icon(
                      Icons.credit_card,
                      color: _green,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _paymentOption(
                    index: 1,
                    label: 'الدفع عند الاستلام',
                    logo: const Icon(Icons.payments, color: _muted, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _paymentOption(
                    index: 2,
                    label: 'Apple Pay',
                    logo: const Icon(
                      Icons.apple,
                      color: Colors.black,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _paymentOption(
                    index: 3,
                    label: 'Tabby',
                    logo: Image.asset(
                      'assets/tabby.png',
                      height: 22,
                      errorBuilder: (context, error, stackTrace) => const Text(
                        'tabby',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _paymentOption(
                    index: 4,
                    label: 'Tamara',
                    logo: Image.asset(
                      'assets/tamara.png',
                      height: 22,
                      errorBuilder: (context, error, stackTrace) => const Text(
                        'tamara',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _paymentOption(
                    index: 5,
                    label: 'مدى',
                    logo: const Icon(
                      Icons.credit_card,
                      color: _green,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            if (_selectedPaymentIndex == 0 || _selectedPaymentIndex == 5)
              _cardFormSection(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Column(
                children: [
                  _summaryRow('المجموع', '$_subtotal ر.س'),
                  if (_discountApplied)
                    _summaryRow(
                      'الخصم',
                      '-${_formatAmount(_discountAmount)} ر.س',
                      valueColor: _green,
                    ),
                  const Divider(height: 20, color: Color(0xFFE0E0E0)),
                  _summaryRow(
                    'الإجمالي النهائي',
                    '${_formatAmount(_finalTotal)} ر.س',
                    valueColor: _gold,
                    bold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: _CheckoutPressScale(
                child: ElevatedButton(
                  onPressed: _selectedPaymentIndex == 2
                      ? _showApplePaySheet
                      : _completeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'تأكيد الطلب والدفع',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _itemImage(String? imageUrl, {double size = 70}) {
    Widget placeholder() => Container(
      width: size,
      height: size,
      color: _lightGreen,
      alignment: Alignment.center,
      child: const Icon(
        Icons.rice_bowl_rounded,
        color: _green,
        size: 26,
      ),
    );

    if (imageUrl == null || imageUrl.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: placeholder(),
      );
    }

    final image = imageUrl.startsWith('http')
        ? Image.network(
            imageUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => placeholder(),
          )
        : Image.asset(
            imageUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => placeholder(),
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: image,
    );
  }

  Widget _paymentOption({
    required int index,
    required String label,
    required Widget logo,
  }) {
    final selected = _selectedPaymentIndex == index;
    final color = selected ? _green : _muted;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() => _selectedPaymentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? _green : const Color(0xFFE0E0E0),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 6),
            logo,
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.black : _muted,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardFormSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'بيانات البطاقة',
            style: TextStyle(
              color: _green,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Column(
              children: [
                TextField(
                  keyboardType: TextInputType.number,
                  maxLength: 19,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  decoration: _cardFieldDecoration(
                    label: 'رقم البطاقة',
                    hint: '0000 0000 0000 0000',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        decoration: _cardFieldDecoration(
                          label: 'تاريخ الانتهاء',
                          hint: 'MM/YY',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        obscureText: true,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        decoration: _cardFieldDecoration(
                          label: 'CVV',
                          hint: '123',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  decoration: _cardFieldDecoration(
                    label: 'اسم حامل البطاقة',
                    hint: 'الاسم كما هو على البطاقة',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _cardFieldDecoration({
    required String label,
    required String hint,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
    );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(fontFamily: 'Cairo', color: _muted),
      hintStyle: const TextStyle(fontFamily: 'Cairo', color: _muted),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: border,
      enabledBorder: border,
      focusedBorder: border,
    );
  }

  Future<void> _showApplePaySheet() {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1C1C1E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.apple, color: Colors.white, size: 26),
                      const SizedBox(width: 6),
                      const Text(
                        'Pay',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white70,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.blue[800],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(
                            child: Text(
                              'mada',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Classic Debit Card (mada)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '••••  1234',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.check_circle,
                          color: Colors.blue,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'Change Payment Method',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        Spacer(),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.white54,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Pay ${CartData.grandTotal} SAR',
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  Text(
                    'SAR ${CartData.grandTotal}.00',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue, width: 3),
                      ),
                      child: const Icon(
                        Icons.touch_app,
                        color: Colors.blue,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'Processing',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _completeOrder();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.touch_app, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Confirm with Face ID',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'Apple Pay • Secure',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _orderDetailsCard() {
    final now = DateTime.now();
    final today = DateFormat('d MMMM yyyy', 'ar').format(now);
    final currentTime = DateFormat('hh:mm a', 'ar').format(now);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _showDetails = !_showDetails),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'تفاصيل الطلب',
                    style: TextStyle(
                      color: _green,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(
                  _showDetails
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: _muted,
                ),
              ],
            ),
          ),
          if (_showDetails) ...[
            const SizedBox(height: 10),
            _orderInfoBlock(today: today, currentTime: currentTime),
            const Divider(height: 24),
            const SizedBox(height: 14),
            const Text(
              'الوجبات المختارة',
              style: TextStyle(
                color: _green,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            ...CartData.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              color: _muted,
                              fontFamily: 'Cairo',
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          'x${item.quantity}',
                          style: const TextStyle(
                            color: _muted,
                            fontFamily: 'Cairo',
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${item.total} ر.س',
                          style: const TextStyle(
                            color: _gold,
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < CartData.items.length - 1)
                    const Divider(height: 1, color: Color(0xFFE8E8E8)),
                ],
              );
            }),
            const Divider(height: 24),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'الإجمالي النهائي',
                  style: TextStyle(
                    color: _green,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${_formatAmount(_finalTotal)} ر.س',
                  style: const TextStyle(
                    color: _gold,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _orderStatusSection() {
    const activeIndex = 0;
    const statuses = [
      (label: 'قيد الانتظار', icon: Icons.schedule),
      (label: 'تم القبول', icon: Icons.check_circle_outline),
      (label: 'قيد التجهيز', icon: Icons.restaurant),
      (label: 'جاهز للتوصيل', icon: Icons.delivery_dining),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'حالة الطلب',
          style: TextStyle(
            color: _green,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Row(
            children: List.generate(statuses.length, (index) {
              final reached = index <= activeIndex;
              final color = reached ? _green : _muted;
              return Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        if (index > 0)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: index <= activeIndex
                                  ? _green
                                  : const Color(0xFFE0E0E0),
                            ),
                          ),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: reached ? _lightGreen : Colors.white,
                            border: Border.all(color: color, width: 1.5),
                          ),
                          child: Icon(
                            statuses[index].icon,
                            color: color,
                            size: 17,
                          ),
                        ),
                        if (index < statuses.length - 1)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: index < activeIndex
                                  ? _green
                                  : const Color(0xFFE0E0E0),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      statuses[index].label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: color,
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        fontWeight: reached
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _orderInfoBlock({required String today, required String currentTime}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _detailInfoRow('رقم الطلب', '#${_createdRequestId ?? '---'}'),
          _detailInfoRow('تاريخ الطلب', today),
          _detailInfoRow('وقت الطلب', currentTime),
          _detailInfoRow('حالة الطلب', 'قيد الانتظار', valueColor: _green),
          _detailInfoRow('مكان الاستلام', selectedDistributionLocation),
        ],
      ),
    );
  }

  Widget _detailInfoRow(
    String label,
    String value, {
    Color valueColor = Colors.black,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontFamily: 'Cairo',
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: _green,
        fontFamily: 'Cairo',
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    Color valueColor = _muted,
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: bold ? _green : _muted,
              fontFamily: 'Cairo',
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 16 : 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontFamily: 'Cairo',
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              fontSize: bold ? 18 : 13,
            ),
          ),
        ],
      ),
    );
  }

  void _setItemQuantity(int index, int quantity) {
    setState(() => CartData.setQuantity(index, quantity));
  }

  void _applyDiscount() {
    setState(() {
      _discountApplied =
          _discountController.text.trim().toUpperCase() == 'HAJJ10';
      _invalidDiscount = !_discountApplied;
    });
  }

  String _formatAmount(double amount) {
    return amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
  }

  Future<void> _completeOrder() async {
    if (CartData.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('السلة فارغة')),
      );
      return;
    }

    final user = currentUserNotifier.value;
    final token = user?['token']?.toString() ?? '';

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطأ: التوكن غير موجود، يرجى تسجيل الدخول'),
        ),
      );
      return;
    }

    final userId = int.tryParse('${user?['userId'] ?? ''}');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تسجيل الدخول قبل إتمام الطلب'),
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _showDetails = false;
    });

    try {
      // 1. إنشاء الطلب
      debugPrint('Token: $token');

      final requestResponse = await http.post(
        Uri.parse('$_baseUrl/meal-requests'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId,
          'requestDate': DateTime.now().toIso8601String(),
          'status': 'Pending',
          'deliveryMethod': 'restaurant',
        }),
      );

      if (requestResponse.statusCode < 200 ||
          requestResponse.statusCode >= 300) {
        throw Exception(
          'فشل إنشاء الطلب (${requestResponse.statusCode})',
        );
      }

      final requestData =
          jsonDecode(requestResponse.body) as Map<String, dynamic>;

      final requestId = int.tryParse(
        '${requestData['requestId'] ?? ''}',
      );

      if (requestId == null) {
        throw Exception('لم يستلم التطبيق رقم الطلب من الباك إند');
      }

      // 2. حفظ تفاصيل كل وجبة
      for (final item in CartData.items) {
        final detailResponse = await http.post(
          Uri.parse('$_baseUrl/request-details'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'requestId': requestId,
            'mealId': item.mealId,
            'quantity': item.quantity,
            'unitPrice': item.price,
            'totalAmount': item.total,
          }),
        );

        if (detailResponse.statusCode < 200 ||
            detailResponse.statusCode >= 300) {
          throw Exception(
            'فشل حفظ تفاصيل الوجبة ${item.name} '
            '(${detailResponse.statusCode})',
          );
        }
      }

      // 3. تحديد طريقة الدفع
      const paymentMethods = {
        0: 'card',
        1: 'cash_on_delivery',
        2: 'apple_pay',
        3: 'tabby',
        4: 'tamara',
        5: 'mada',
      };

      final paymentMethod =
          paymentMethods[_selectedPaymentIndex] ?? 'card';

      // 4. حفظ سجل الدفع المرتبط بالطلب
      final paymentResponse = await http.post(
        Uri.parse('$_baseUrl/payments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'requestId': requestId,
          'amount': _finalTotal,
          'paymentMethod': paymentMethod,
          'paymentDate': DateTime.now().toIso8601String(),
          'paymentStatus': 'Pending',
        }),
      );

      if (paymentResponse.statusCode < 200 ||
          paymentResponse.statusCode >= 300) {
        throw Exception(
          'فشل حفظ عملية الدفع (${paymentResponse.statusCode})',
        );
      }

      if (!mounted) return;

      // 5. تحديث واجهة التطبيق بعد نجاح الطلب
      setState(() {
        _createdRequestId = requestId;
        orderPlaced = true;
        _isProcessing = false;
      });

      notificationsNotifier.value = [
        ...notificationsNotifier.value,
        {
          'title': 'تم تنفيذ طلبك',
          'message': 'طلبك رقم #$requestId قيد المعالجة',
          'time': 'الآن',
        },
      ];

      Future<void>.delayed(const Duration(seconds: 5), () {
        if (!mounted || !orderPlaced) return;

        notificationsNotifier.value = [
          ...notificationsNotifier.value,
          {
            'title': 'طلبك قيد التجهيز',
            'message': 'طلبك رقم #$requestId قيد التجهيز',
            'time': 'الآن',
          },
        ];
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذّر إكمال الطلب: $e'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}

class _CheckoutPressScale extends StatefulWidget {
  const _CheckoutPressScale({required this.child});

  final Widget child;

  @override
  State<_CheckoutPressScale> createState() => _CheckoutPressScaleState();
}

class _CheckoutPressScaleState extends State<_CheckoutPressScale> {
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




