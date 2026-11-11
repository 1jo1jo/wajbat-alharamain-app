import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'main.dart' show HomePage, isUserLoggedInNotifier;
import 'user_session.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  static const _green = Color(0xFF0B4F34);
  static const _gold = Color(0xFFC6963C);
  static const _usersApiUrl =
      'https://haramain-backend.onrender.com/users';

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  bool _acceptedTerms = false;
  bool _isRegistering = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmation = _confirmationController.text;

    if (fullName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmation.isEmpty) {
      _showMessage('فضلاً عبّي جميع الحقول');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _showMessage('تأكدي من صحة البريد الإلكتروني');
      return;
    }

    if (password != confirmation) {
      _showMessage('كلمتا المرور غير متطابقتين');
      return;
    }

    if (!_acceptedTerms) {
      _showMessage('لازم توافقين على الشروط والأحكام');
      return;
    }

    setState(() => _isRegistering = true);

    try {
      final username = email.split('@').first;

      final response = await http
          .post(
            Uri.parse(_usersApiUrl),
            headers: const {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'fullName': fullName,
              'username': username,
              'email': email,
              'phone': phone,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (!mounted) return;

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final decodedResponse = jsonDecode(response.body);

        if (decodedResponse is! Map<String, dynamic>) {
          _showMessage(
            'تم إرسال الطلب، لكن بيانات المستخدم المستلمة غير صحيحة',
          );
          return;
        }

        final responseData =
            Map<String, dynamic>.from(decodedResponse);

        if (responseData['userId'] == null) {
          _showMessage(
            'لم يتم استلام رقم المستخدم من السيرفر',
          );
          return;
        }

        saveUserSession(responseData);
        isUserLoggedInNotifier.value = true;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء الحساب بنجاح'),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomePage(),
          ),
        );
      } else {
        _showMessage(
          'تعذر إنشاء الحساب (رمز ${response.statusCode}). '
          'تأكدي أن البريد واسم المستخدم غير مستخدمين من قبل.',
        );
      }
    } on FormatException {
      if (!mounted) return;
      _showMessage(
        'استجابة السيرفر غير صالحة، حاولي مرة أخرى',
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage(
        'تعذر الاتصال بالخادم، حاولي مرة أخرى',
      );
    } finally {
      if (mounted) {
        setState(() => _isRegistering = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
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
                errorBuilder: (_, __, ___) =>
                    Container(
                  color: const Color(0xFF0C4B3A),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.25),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 460,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              'assets/logo.png',
                              width: 110,
                              height: 110,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'إنشاء حساب جديد',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _green,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'انضم إلينا لخدمة ضيوف الرحمن',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _green.withValues(alpha: 0.7),
                              fontSize: 13,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 30),

                          _inputField(
                            controller: _fullNameController,
                            hint: 'الاسم الكامل',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 12),

                          _inputField(
                            controller: _emailController,
                            hint: 'البريد الإلكتروني',
                            icon: Icons.email_outlined,
                            keyboardType:
                                TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),

                          _inputField(
                            controller: _phoneController,
                            hint: 'رقم الجوال',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),

                          _inputField(
                            controller: _passwordController,
                            hint: 'كلمة المرور',
                            icon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            suffix: IconButton(
                              onPressed: () => setState(
                                () => _obscurePassword =
                                    !_obscurePassword,
                              ),
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

                          _inputField(
                            controller: _confirmationController,
                            hint: 'تأكيد كلمة المرور',
                            icon: Icons.lock_outline,
                            obscureText: _obscureConfirmation,
                            suffix: IconButton(
                              onPressed: () => setState(
                                () => _obscureConfirmation =
                                    !_obscureConfirmation,
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

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Checkbox(
                                value: _acceptedTerms,
                                activeColor: _green,
                                onChanged: (value) => setState(
                                  () => _acceptedTerms =
                                      value ?? false,
                                ),
                              ),
                              const Expanded(
                                child: Text(
                                  'أوافق على الشروط والأحكام',
                                  style: TextStyle(
                                    color: _green,
                                    fontSize: 12,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: Material(
                              color: _green,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(30),
                                side: const BorderSide(
                                  color: _gold,
                                  width: 1.5,
                                ),
                              ),
                              child: InkWell(
                                onTap: _isRegistering
                                    ? null
                                    : _registerUser,
                                borderRadius:
                                    BorderRadius.circular(30),
                                child: Center(
                                  child: _isRegistering
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child:
                                              CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text(
                                          'إنشاء الحساب',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight:
                                                FontWeight.bold,
                                            fontSize: 17,
                                            fontFamily: 'Cairo',
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              const Text(
                                'لديك حساب بالفعل؟',
                                style: TextStyle(
                                  color: _green,
                                  fontSize: 13,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context),
                                child: const Text(
                                  'تسجيل الدخول',
                                  style: TextStyle(
                                    color: _gold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ),
                            ],
                          ),

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

            Positioned(
              top: 40,
              right: 20,
              child: Material(
                color: Colors.white.withValues(alpha: 0.25),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomePage(),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.home_rounded,
                      color: Color(0xFF0B4F34),
                      size: 26,
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

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _gold,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Icon(
              icon,
              color: _gold,
              size: 22,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
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
          if (suffix != null) suffix,
        ],
      ),
    );
  }
}