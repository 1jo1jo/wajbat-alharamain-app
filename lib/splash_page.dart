import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  static const _green = Color(0xFF0C4B3A);
  static const _gold = Color(0xFFC6963C);
  static const _duration = Duration(milliseconds: 4500);

  late final AnimationController _controller;
  late final AnimationController _particleController;
  late final Animation<double> _backgroundScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _taglineFade;
  late final Animation<double> _dividerWidth;
  late final Animation<double> _loadingFade;
  late final Animation<double> _footerFade;

  static const _particles = [
    _Particle(0.08, 0.13, 3, 0.1),
    _Particle(0.24, 0.08, 5, 1.4),
    _Particle(0.41, 0.17, 2, 2.2),
    _Particle(0.59, 0.10, 4, 0.8),
    _Particle(0.77, 0.19, 6, 2.8),
    _Particle(0.92, 0.12, 3, 1.9),
    _Particle(0.14, 0.34, 4, 2.5),
    _Particle(0.33, 0.41, 2, 0.5),
    _Particle(0.68, 0.37, 5, 1.1),
    _Particle(0.86, 0.47, 3, 2.1),
    _Particle(0.06, 0.63, 6, 0.9),
    _Particle(0.27, 0.76, 3, 1.7),
    _Particle(0.51, 0.68, 4, 2.7),
    _Particle(0.73, 0.83, 2, 0.3),
    _Particle(0.94, 0.72, 5, 1.3),
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: _duration)
      ..addStatusListener(_onAnimationStatusChanged);
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _backgroundScale = Tween<double>(begin: 1, end: 1.15).animate(_controller);
    _logoFade = _interval(300, 1900);
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 80,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.1,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
    ]).animate(_interval(300, 1900));
    _titleFade = _interval(1300, 2200);
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 40 / 100),
      end: Offset.zero,
    ).animate(_interval(1300, 2200, curve: Curves.easeOutCubic));
    _taglineFade = _interval(1900, 2700);
    _dividerWidth = Tween<double>(
      begin: 0,
      end: 200,
    ).animate(_interval(2200, 3200, curve: Curves.easeOut));
    _loadingFade = _interval(2700, 3500);
    _footerFade = _interval(3200, 4000);

    _controller.forward();
  }

  Animation<double> _interval(
    int startMilliseconds,
    int endMilliseconds, {
    Curve curve = Curves.easeIn,
  }) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(
        startMilliseconds / _duration.inMilliseconds,
        endMilliseconds / _duration.inMilliseconds,
        curve: curve,
      ),
    );
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder<LoginPage>(
          transitionDuration: const Duration(milliseconds: 1200),
          pageBuilder: (_, _, _) => const LoginPage(),
          transitionsBuilder: (_, animation, _, child) {
            final scale = Tween<double>(begin: 0.9, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: scale, child: child),
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_onAnimationStatusChanged)
      ..dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: _backgroundScale,
              builder: (context, child) =>
                  Transform.scale(scale: _backgroundScale.value, child: child),
              child: Image.asset(
                'assets/login2.jpg',
                fit: BoxFit.cover,
                alignment: const Alignment(0.0, 0.6),
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) =>
                    _fallbackBackground(),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xAA0C4B3A), Color(0xDD0C4B3A)],
                ),
              ),
            ),
            _buildParticles(),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FadeTransition(
                        opacity: _logoFade,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: Container(
                            width: 160,
                            height: 160,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFC6963C)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: Image.asset(
                                'assets/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      FadeTransition(
                        opacity: _titleFade,
                        child: SlideTransition(
                          position: _titleSlide,
                          child: const Text(
                            'وجبة الحرمين',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 40,
                              letterSpacing: 1.8,
                              fontFamily: 'Cairo',
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      FadeTransition(
                        opacity: _taglineFade,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 60, height: 2, color: _gold),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14),
                              child: Text(
                                'معك في كل خطوة',
                                style: TextStyle(
                                  color: _gold,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                            Container(width: 60, height: 2, color: _gold),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedBuilder(
                        animation: _dividerWidth,
                        builder: (context, child) => Container(
                          width: _dividerWidth.value,
                          height: 3,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                _gold,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      FadeTransition(
                        opacity: _loadingFade,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                color: _gold,
                                strokeWidth: 2.5,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'جاري التحضير...',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _footerFade,
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'وجبة الحرمين',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '© 2026 - جميع الحقوق محفوظة',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticles() {
    return LayoutBuilder(
      builder: (context, constraints) => AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) => Stack(
          children: [
            for (final particle in _particles)
              Positioned(
                left: particle.x * constraints.maxWidth,
                top:
                    particle.y * constraints.maxHeight +
                    math.sin(
                          _particleController.value * 2 * math.pi +
                              particle.phase,
                        ) *
                        12,
                child: Container(
                  width: particle.size,
                  height: particle.size,
                  decoration: BoxDecoration(
                    color: _gold.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackBackground() {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_green, Color(0xFF1A6B50)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

class _Particle {
  const _Particle(this.x, this.y, this.size, this.phase);

  final double x;
  final double y;
  final double size;
  final double phase;
}
