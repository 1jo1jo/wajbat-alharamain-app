import 'package:flutter/material.dart';

const _green = Color(0xFF0C4B3A);
const _gold = Color(0xFFC6963C);
const _cream = Color(0xFFEAF3EF);
const _grey = Color(0xFF73807B);

class DonationSuccessPage extends StatelessWidget {
  const DonationSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 220,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      _cream.withValues(alpha: 0.8),
                      _cream.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: _cream,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: _green, size: 55),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'شكراً لتبرعك',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _green,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'جعل الله عطائك في ميزان حسناتك',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _grey,
                          fontSize: 14,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(width: 40, height: 2, color: _gold),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          final navigator = Navigator.of(context);
                          navigator.pop();
                          navigator.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'العودة للرئيسية',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
