import 'package:flutter/material.dart';

class RatingPage extends StatefulWidget {
  const RatingPage({super.key});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  static const _green = Color(0xFF0C4B3A);
  static const _gold = Color(0xFFC6963C);

  int _rating = 0;

  String get _ratingLabel => const [
    'اختر تقييمك',
    'سيء جداً 😞',
    'سيء 😕',
    'جيد 🙂',
    'جيد جداً 😊',
    'ممتاز 🤩',
  ][_rating];

  Color get _ratingColor => switch (_rating) {
    1 => Colors.red,
    2 => Colors.orange,
    3 => _gold,
    4 || 5 => _green,
    _ => const Color(0xFF757575),
  };

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_green, Color(0xFF1A6B50)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.restaurant_menu,
                            color: _green,
                            size: 70,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'قيّم وجبتك',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const Text(
                          'رأيك يهمنا لتقديم الأفضل',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'كيف كانت وجبتك؟',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            5,
                            (index) => GestureDetector(
                              onTap: () => setState(() => _rating = index + 1),
                              child: AnimatedScale(
                                scale: _rating == index + 1 ? 1.2 : 1,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  Icons.star,
                                  size: 45,
                                  color: index < _rating
                                      ? _gold
                                      : const Color(0xFFE0E0E0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _ratingLabel,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _ratingColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          maxLines: 3,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontFamily: 'Cairo'),
                          decoration: InputDecoration(
                            hintText: 'اكتب تعليقك (اختياري)...',
                            hintStyle: const TextStyle(
                              color: Color(0xFF757575),
                              fontFamily: 'Cairo',
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _rating == 0
                                ? null
                                : () => _showThankYouDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _green,
                              disabledBackgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'إرسال التقييم',
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
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      '© 2026 وجبة الحرمين',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontFamily: 'Cairo',
                      ),
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

  Future<void> _showThankYouDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: _green, size: 80),
            const SizedBox(height: 12),
            const Text(
              'شكراً لتقييمك!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _green,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'نسعد بخدمتك دائماً',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF757575),
                fontSize: 14,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text(
              'حسناً',
              style: TextStyle(
                color: _green,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
