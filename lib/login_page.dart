import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'admin_page.dart';
import 'courier_page.dart';
import 'forgot_password_page.dart';
import 'main.dart' show HomePage, isUserLoggedInNotifier;
import 'restaurant_page.dart';
import 'signup_page.dart';
import 'user_session.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const _green = Color(0xFF0B4F34);
  static const _gold = Color(0xFFC6963C);

  // عنوان الباكند المنشور.
  static const String _baseUrl =
      'https://haramain-backend.onrender.com';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final identifier = _emailController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      _showMessage('فضلاً أدخلي البريد الإلكتروني وكلمة المرور');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'identifier': identifier,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30));

      Map<String, dynamic> responseData = {};

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          responseData = decoded;
        }
      } catch (_) {
        responseData = {};
      }

      if (!mounted) return;

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          responseData['userId'] != null) {
        final role = (responseData['role'] ?? '').toString().toLowerCase();

        final sessionData = <String, dynamic>{
          ...responseData,
          'role': role,
        };

        saveUserSession(sessionData);
        isUserLoggedInNotifier.value = true;

        if (!mounted) return;

        if (role == 'courier') {
          isUserLoggedInNotifier.value = true;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const CourierPage(),
            ),
          );
          return;
        }

        if (role == 'admin') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute<void>(builder: (_) => const AdminPage()),
            (route) => false,
          );
        } else if (role == 'restaurant') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute<void>(builder: (_) => const RestaurantPage()),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute<void>(builder: (_) => const HomePage()),
            (route) => false,
          );
        }
      } else {
        final serverMessage = responseData['message']?.toString();

        _showMessage(
          serverMessage != null && serverMessage.isNotEmpty
              ? serverMessage
              : 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'تعذر الاتصال بالخادم. تأكدي من اتصال الإنترنت وحاولي مرة أخرى.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          behavior: SnackBarBehavior.floating,
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
                'assets/login2.jpg',
                fit: BoxFit.cover,
                alignment: const Alignment(0.0, 0.6),
                filterQuality: FilterQuality.high,
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFF0C4B3A)),
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
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 12),
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
                            'وجبة الحرمين',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _green,
                              fontWeight: FontWeight.bold,
                              fontSize: 34,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 40,
                                height: 1.2,
                                color: _gold,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'معك في كل خطوة',
                                style: TextStyle(
                                  color: _gold,
                                  fontSize: 15,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 40,
                                height: 1.2,
                                color: _gold,
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          const Text(
                            'مرحباً بك',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _green,
                              fontWeight: FontWeight.bold,
                              fontSize: 26,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'تسجيل الدخول للمتابعة',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _green.withValues(alpha: 0.75),
                              fontSize: 14,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 30),

                          // البريد الإلكتروني
                          _inputField(
                            controller: _emailController,
                            hint: 'البريد الإلكتروني',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 14),

                          // كلمة المرور
                          _inputField(
                            controller: _passwordController,
                            hint: 'كلمة المرور',
                            icon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            suffix: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: _gold,
                                size: 22,
                              ),
                            ),
                            onSubmitted: (_) => _login(),
                          ),

                          const SizedBox(height: 26),

                          // زر تسجيل الدخول
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: Material(
                              color: _green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                                side: const BorderSide(
                                  color: _gold,
                                  width: 1.5,
                                ),
                              ),
                              child: InkWell(
                                onTap: _isLoading ? null : _login,
                                borderRadius: BorderRadius.circular(30),
                                child: Center(
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              'تسجيل الدخول',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
                                                fontFamily: 'Cairo',
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      const ForgotPasswordPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'نسيت كلمة المرور؟',
                              style: TextStyle(
                                color: _green,
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: _green.withValues(alpha: 0.3),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'أو',
                                style: TextStyle(
                                  color: _green,
                                  fontSize: 13,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Divider(
                                  color: _green.withValues(alpha: 0.3),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          // Apple
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: Material(
                              color: _green,
                              borderRadius: BorderRadius.circular(30),
                              child: InkWell(
                                onTap: () {
                                  _showMessage(
                                    'تسجيل الدخول باستخدام Apple غير متاح حاليًا',
                                  );
                                },
                                borderRadius: BorderRadius.circular(30),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.apple,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'تسجيل الدخول باستخدام Apple',
                                      style: TextStyle(
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
                          ),

                          const SizedBox(height: 14),

                          // Google
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: OutlinedButton(
                              onPressed: () {
                                _showMessage(
                                  'تسجيل الدخول باستخدام Google غير متاح حاليًا',
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: _green,
                                foregroundColor: Colors.white,
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'G',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'Arial',
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'تسجيل الدخول باستخدام Google',
                                    style: TextStyle(
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

                          const SizedBox(height: 26),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'ليس لديك حساب؟ ',
                                style: TextStyle(
                                  color: _green,
                                  fontSize: 14,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (_) => const SignUpPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'إنشاء حساب جديد',
                                  style: TextStyle(
                                    color: _gold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          Text(
                            '© 2026 وجبة الحرمين',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _green.withValues(alpha: 0.5),
                              fontSize: 11,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // زر العودة للرئيسية
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
                      MaterialPageRoute<void>(
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
    ValueChanged<String>? onSubmitted,
  }) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(30),
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
              textAlign: TextAlign.right,
              textInputAction: onSubmitted == null
                  ? TextInputAction.next
                  : TextInputAction.done,
              onSubmitted: onSubmitted,
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