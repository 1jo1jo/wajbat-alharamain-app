import 'package:flutter/material.dart';

import 'donation_success_page.dart';

const _green = Color(0xFF0C4B3A);
const _gold = Color(0xFFC6963C);
const _cream = Color(0xFFEAF3EF);
const _grey = Color(0xFF73807B);
const _border = Color(0xFFE0E0E0);

class DonationPage extends StatefulWidget {
  const DonationPage({super.key});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  int _selectedAmount = -1;
  int _selectedType = -1;
  int _selectedFrequency = -1;
  int _selectedPayment = -1;
  bool _isProcessing = false;
  final _customAmountController = TextEditingController();

  static const _amounts = [10, 25, 50, 100];
  static const _donationTypes = [
    (name: 'وجبات للحجاج', icon: Icons.restaurant),
    (name: 'سلال إفطار', icon: Icons.breakfast_dining),
    (name: 'ماء', icon: Icons.water_drop_outlined),
    (name: 'صدقة عامة', icon: Icons.volunteer_activism),
  ];

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: _isProcessing
          ? _buildLoadingScreen()
          : Scaffold(
              backgroundColor: const Color(0xFFF5F5F5),
              appBar: AppBar(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                centerTitle: true,
                title: const Text(
                  'التبرع',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                leading: const SizedBox.shrink(),
                actions: [
                  IconButton(
                    tooltip: 'رجوع',
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeroBanner(),
                    _buildAmountSection(),
                    _buildDonationTypeSection(),
                    _buildFrequencySection(),
                    _buildPaymentSection(),
                    const SizedBox(height: 24),
                    _buildDonateButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: _green),
            SizedBox(height: 20),
            Text(
              'جاري معالجة تبرعك...',
              style: TextStyle(
                color: _green,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'يرجى الانتظار قليلاً',
              style: TextStyle(color: _grey, fontFamily: 'Cairo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return SizedBox(
      width: double.infinity,
      height: 180,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/donation_hero.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: 180,
            errorBuilder: (_, _, _) =>
                Container(color: const Color(0xFF0C4B3A)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'بالعطاء..',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                const Text(
                  'نصنع أثراً في رحلتهم',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'تبرع اليوم .. يساهم في توفير الوجبات والخدمات الأساسية لضيوف الرحمن.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.6,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 8),
                Container(width: 30, height: 2, color: _gold),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection() {
    return _SectionCard(
      margin: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(
            icon: Icons.account_balance_wallet_outlined,
            title: 'مبلغ التبرع',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var index = 0; index < _amounts.length; index++) ...[
                if (index > 0) const SizedBox(width: 8),
                Expanded(
                  child: _AmountButton(
                    amount: _amounts[index],
                    selected: _selectedAmount == _amounts[index],
                    onTap: () => setState(() {
                      _selectedAmount = _selectedAmount == _amounts[index]
                          ? -1
                          : _amounts[index];
                    }),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'أدخل المبلغ المخصص',
            textAlign: TextAlign.right,
            style: TextStyle(color: _grey, fontSize: 13, fontFamily: 'Cairo'),
          ),
          const SizedBox(height: 6),
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _border, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customAmountController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      hintText: 'أدخل المبلغ المخصص',
                      hintStyle: TextStyle(
                        color: _grey,
                        fontSize: 13,
                        fontFamily: 'Cairo',
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'ر.س',
                  style: TextStyle(
                    color: _grey,
                    fontSize: 13,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationTypeSection() {
    return _SectionCard(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(icon: Icons.favorite_border, title: 'نوع التبرع'),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var index = 0; index < _donationTypes.length; index++) ...[
                if (index > 0) const SizedBox(width: 8),
                Expanded(
                  child: _DonationTypeButton(
                    name: _donationTypes[index].name,
                    icon: _donationTypes[index].icon,
                    selected: _selectedType == index,
                    onTap: () => setState(() => _selectedType = index),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencySection() {
    return _SectionCard(
      margin: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle(
            icon: Icons.calendar_today_outlined,
            title: 'تكرار التبرع',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _FrequencyButton(
                  label: 'مرة واحدة',
                  selected: _selectedFrequency == 0,
                  onTap: () => setState(() => _selectedFrequency = 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FrequencyButton(
                  label: 'شهرياً',
                  selected: _selectedFrequency == 1,
                  onTap: () => setState(() => _selectedFrequency = 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    final payments = [
      _PaymentOption(
        name: 'مدى',
        selectedContent: _MadaMark(color: _green),
        unselectedContent: const _MadaMark(color: _green),
      ),
      const _PaymentOption(
        name: 'فيزا',
        selectedContent: Text(
          'VISA',
          style: TextStyle(
            color: Color(0xFF1A1F71),
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        unselectedContent: Text(
          'VISA',
          style: TextStyle(
            color: Color(0xFF1A1F71),
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      const _PaymentOption(
        name: 'أبل بي',
        selectedContent: Icon(Icons.apple, size: 23, color: Colors.black),
        unselectedContent: Icon(Icons.apple, size: 23, color: Colors.black),
        sublabel: 'Pay',
      ),
      const _PaymentOption(
        name: 'تابي',
        selectedContent: _TabbyMark(),
        unselectedContent: _TabbyMark(),
      ),
      const _PaymentOption(
        name: 'تمارا',
        selectedContent: _TamaraMark(),
        unselectedContent: _TamaraMark(),
      ),
    ];

    return Column(
      children: [
        _SectionCard(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionTitle(
                icon: Icons.credit_card,
                title: 'طريقة الدفع',
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var index = 0; index < payments.length; index++) ...[
                      if (index > 0) const SizedBox(width: 8),
                      _PaymentButton(
                        option: payments[index],
                        selected: _selectedPayment == index,
                        onTap: () {
                          setState(() => _selectedPayment = index);
                          if (index == 2) _showApplePayDialog();
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildPaymentDetails(),
      ],
    );
  }

  Widget _buildPaymentDetails() {
    switch (_selectedPayment) {
      case 0:
      case 1:
        return _SectionCard(
          margin: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _PaymentDetailsTitle(title: 'بيانات البطاقة'),
              const SizedBox(height: 14),
              const _PaymentTextField(
                label: 'رقم البطاقة',
                hint: '0000 0000 0000 0000',
                maxLength: 19,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(
                    child: _PaymentTextField(
                      label: 'تاريخ الانتهاء',
                      hint: 'MM/YY',
                      maxLength: 5,
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _PaymentTextField(
                      label: 'CVV',
                      hint: '123',
                      maxLength: 4,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const _PaymentTextField(
                label: 'اسم حامل البطاقة',
                hint: 'الاسم كما هو على البطاقة',
              ),
            ],
          ),
        );
      case 2:
        return _SectionCard(
          margin: const EdgeInsets.all(12),
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _showApplePayDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.apple, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Apple Pay',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      case 3:
        return _InstallmentDetails(
          message: 'سيتم تحويلك إلى تابي لإتمام الدفع',
          terms: 'التقسيط على 4 دفعات بدون فوائد',
          logo: const _TabbyMark(),
          buttonLabel: 'متابعة مع تابي',
          buttonColor: const Color(0xFF4CB8A5),
        );
      case 4:
        return _InstallmentDetails(
          message: 'سيتم تحويلك إلى تمارا لإتمام الدفع',
          terms: 'قسّم مشترياتك على 3 أو 4 دفعات',
          logo: const _TamaraMark(),
          buttonLabel: 'متابعة مع تمارا',
          buttonColor: const Color(0xFF843B80),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _showApplePayDialog() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
                                '•••• 1234',
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
                    'Pay ${_getTotalAmount()} SAR',
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  Text(
                    'SAR ${_getTotalAmount()}.00',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
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
                        _completeDonation();
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
                              fontFamily: 'Cairo',
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

  int _getTotalAmount() {
    final customAmount = _customAmountController.text.trim();
    if (customAmount.isNotEmpty) return int.tryParse(customAmount) ?? 0;
    if (_selectedAmount != -1) return _selectedAmount;
    return 0;
  }

  void _showValidationMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _completeDonation() async {
    setState(() => _isProcessing = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() => _isProcessing = false);
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const DonationSuccessPage(),
      ),
    );
  }

  Widget _buildDonateButton() {
    return InkWell(
      onTap: _selectedPayment == 2 ? _showApplePayDialog : _processDonation,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 56,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _green,
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'تبرع الآن',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processDonation() async {
    final hasCustomAmount = _customAmountController.text.trim().isNotEmpty;
    if (_selectedAmount == -1 && !hasCustomAmount) {
      _showValidationMessage('يرجى اختيار مبلغ التبرع');
      return;
    }
    if (_selectedType == -1) {
      _showValidationMessage('يرجى اختيار نوع التبرع');
      return;
    }
    if (_selectedFrequency == -1) {
      _showValidationMessage('يرجى اختيار تكرار التبرع');
      return;
    }
    if (_selectedPayment == -1) {
      _showValidationMessage('يرجى اختيار طريقة الدفع');
      return;
    }

    await _completeDonation();
  }
}

class _PaymentDetailsTitle extends StatelessWidget {
  const _PaymentDetailsTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.credit_card, color: _green, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: _green,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }
}

class _PaymentTextField extends StatelessWidget {
  const _PaymentTextField({
    required this.label,
    required this.hint,
    this.maxLength,
    this.keyboardType,
    this.obscureText = false,
  });

  final String label;
  final String hint;
  final int? maxLength;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: _grey,
            fontSize: 12,
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _border, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: TextField(
            textAlign: TextAlign.right,
            keyboardType: keyboardType,
            maxLength: maxLength,
            obscureText: obscureText,
            style: const TextStyle(
              color: _green,
              fontSize: 14,
              fontFamily: 'Cairo',
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: _grey,
                fontSize: 13,
                fontFamily: 'Cairo',
              ),
              border: InputBorder.none,
              counterText: '',
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}

class _InstallmentDetails extends StatelessWidget {
  const _InstallmentDetails({
    required this.message,
    required this.terms,
    required this.logo,
    required this.buttonLabel,
    required this.buttonColor,
  });

  final String message;
  final String terms;
  final Widget logo;
  final String buttonLabel;
  final Color buttonColor;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      margin: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: logo),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _green,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            terms,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _grey,
              fontSize: 13,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'سيتم تحويلك إلى ${buttonLabel.split(' ').last}',
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.margin, required this.child});

  final EdgeInsets margin;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _green, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: _green,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }
}

class _AmountButton extends StatelessWidget {
  const _AmountButton({
    required this.amount,
    required this.selected,
    required this.onTap,
  });

  final int amount;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: selected ? _green : Colors.white,
          border: Border.all(color: _green, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$amount',
              style: TextStyle(
                color: selected ? Colors.white : _green,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            Text(
              'ر.س',
              style: TextStyle(
                color: selected ? Colors.white70 : _grey,
                fontSize: 11,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonationTypeButton extends StatelessWidget {
  const _DonationTypeButton({
    required this.name,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 90,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? _green : Colors.white,
          border: Border.all(color: selected ? _green : _border, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: selected ? Colors.white : _green),
            const SizedBox(height: 6),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : _green,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FrequencyButton extends StatelessWidget {
  const _FrequencyButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _green : Colors.white,
          border: Border.all(color: selected ? _green : _border, width: 1.5),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : _green,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }
}

class _PaymentOption {
  const _PaymentOption({
    required this.name,
    required this.selectedContent,
    required this.unselectedContent,
    this.sublabel,
  });

  final String name;
  final Widget selectedContent;
  final Widget unselectedContent;
  final String? sublabel;
}

class _PaymentButton extends StatelessWidget {
  const _PaymentButton({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _PaymentOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 65,
        height: 75,
        decoration: BoxDecoration(
          color: selected ? _cream : Colors.white,
          border: Border.all(color: selected ? _green : _border, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            option.selectedContent,
            if (option.sublabel != null)
              Text(
                option.sublabel!,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 9,
                  height: 0.9,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              option.name,
              style: const TextStyle(
                color: _green,
                fontSize: 10,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MadaMark extends StatelessWidget {
  const _MadaMark({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF1B74BB),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 3),
          Container(
            width: 30,
            height: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 3),
          Container(
            width: 20,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF55A9D8),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabbyMark extends StatelessWidget {
  const _TabbyMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: _cream,
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Text(
        'tabby',
        style: TextStyle(
          color: _green,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _TamaraMark extends StatelessWidget {
  const _TamaraMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF9E4F0), Color(0xFFEADCF8)],
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Text(
        'تمارا',
        style: TextStyle(
          color: Color(0xFF843B80),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}
