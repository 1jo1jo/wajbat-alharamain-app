import 'package:flutter/material.dart';

import 'login_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  static const _green = Color(0xFF0B4F34);
  static const _gold = Color(0xFFC6963C);

  int _step = 1;
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  int _passwordStrength(String password) {
    if (password.isEmpty) return 0;
    if (password.length < 6) return 1;
    if (password.length <= 9) return 2;
    if (RegExp(r'\d').hasMatch(password)) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/login.jpg',
                fit: BoxFit.cover,
                alignment: const Alignment(0.0, 0.6),
                errorBuilder: (_, _, _) =>
                    Container(color: const Color(0xFF0C4B3A)),
              ),
            ),
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.25)),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              'assets/logo.png',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (_step == 1) ..._emailStepWidgets()
                          else ..._passwordStepWidgets(),
                          const SizedBox(height: 30),
                          Text(
                            '©️ 2026 وجبة الحرمين',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _green.withValues(alpha: 0.5),
                              fontSize: 11,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _emailStepWidgets() {
    return [
      const Icon(Icons.lock_reset, color: _gold, size: 60),
      const SizedBox(height: 16),
      const Text(
        'نسيت كلمة المرور؟',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _green,
          fontWeight: FontWeight.bold,
          fontSize: 26,
          fontFamily: 'Cairo',
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'أدخل بريدك الإلكتروني للمتابعة',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _green.withValues(alpha: 0.75),
          fontSize: 13,
          fontFamily: 'Cairo',
        ),
      ),
      const SizedBox(height: 30),
      _inputField(
        hint: 'البريد الإلكتروني',
        icon: Icons.email_outlined,
        keyboardType: TextInputType.emailAddress,
        controller: _emailController,
      ),
      const SizedBox(height: 24),
      _actionButton(
        label: 'متابعة',
        icon: Icons.arrow_forward_rounded,
        onTap: () => setState(() => _step = 2),
      ),
      const SizedBox(height: 20),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text(
          'العودة لتسجيل الدخول',
          style: TextStyle(
            color: _green,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    ];
  }

  List<Widget> _passwordStepWidgets() {
    final password = _passwordController.text;
    final confirmation = _confirmationController.text;

    return [
      const Icon(Icons.password, color: _gold, size: 60),
      const SizedBox(height: 16),
      const Text(
        'كلمة مرور جديدة',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _green,
          fontWeight: FontWeight.bold,
          fontSize: 26,
          fontFamily: 'Cairo',
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'اختر كلمة مرور قوية لحماية حسابك',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _green.withValues(alpha: 0.75),
          fontSize: 13,
          fontFamily: 'Cairo',
        ),
      ),
      const SizedBox(height: 30),
      _inputField(
        hint: 'كلمة المرور الجديدة',
        icon: Icons.lock_outline,
        controller: _passwordController,
        obscureText: _obscurePassword,
        onChanged: (_) => setState(() {}),
        suffix: IconButton(
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: _gold,
            size: 22,
          ),
        ),
      ),
      const SizedBox(height: 12),
      _passwordStrengthIndicator(_passwordStrength(password)),
      const SizedBox(height: 12),
      _inputField(
        hint: 'تأكيد كلمة المرور',
        icon: Icons.lock_outline,
        controller: _confirmationController,
        obscureText: _obscureConfirmation,
        onChanged: (_) => setState(() {}),
        suffix: IconButton(
          onPressed: () => setState(
            () => _obscureConfirmation = !_obscureConfirmation,
          ),
          icon: Icon(
            _obscureConfirmation
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: _gold,
            size: 22,
          ),
        ),
      ),
      const SizedBox(height: 8),
      if (confirmation.isNotEmpty && confirmation != password)
        const Text(
          'كلمتا المرور غير متطابقتين',
          style: TextStyle(
            color: Colors.red,
            fontSize: 12,
            fontFamily: 'Cairo',
          ),
        ),
      const SizedBox(height: 24),
      _actionButton(
        label: 'تعيين كلمة المرور',
        onTap: _setPassword,
      ),
      const SizedBox(height: 20),
      TextButton(
        onPressed: () => setState(() => _step = 1),
        child: const Text(
          'رجوع',
          style: TextStyle(
            color: _green,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    ];
  }

  Widget _passwordStrengthIndicator(int strength) {
    final color = switch (strength) {
      1 => Colors.red,
      2 => Colors.orange,
      3 => Colors.green,
      _ => Colors.grey,
    };
    final label = switch (strength) {
      1 => 'ضعيفة',
      2 => 'متوسطة',
      3 => 'قوية',
      _ => '',
    };

    return Column(
      children: [
        Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Container(
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: index < strength ? color : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }

  Widget _inputField({
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextEditingController? controller,
    bool obscureText = false,
    Widget? suffix,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _gold, width: 1.2),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Icon(icon, color: _gold, size: 22),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              onChanged: onChanged,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _green,
                fontSize: 14,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: _green.withValues(alpha: 0.85),
                  fontSize: 14,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
              ),
            ),
          ),
          ?suffix,
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: Material(
        color: _green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: _gold, width: 1.5),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setPassword() {
    final password = _passwordController.text;
    if (password.isEmpty || password != _confirmationController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى التحقق من البيانات')),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );

    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (!messenger.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'تم تعيين كلمة المرور بنجاح',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0C4B3A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }
}