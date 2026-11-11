import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const _green = Color(0xFF0C4B3A);
  static const _gold = Color(0xFFC6963C);
  static const _lightGreen = Color(0xFFEAF3EF);
  static const _grey = Color(0xFF73807B);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          backgroundColor: _green,
          centerTitle: true,
          title: const Text(
            'عن التطبيق',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
              letterSpacing: 0.2,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _heroBanner(),
              const SizedBox(height: 20),
              _sectionTitle('عن التطبيق'),
              _aboutSection(),
              const SizedBox(height: 20),
              _sectionTitle('ما الذي نقدمه؟'),
              _featuresSection(),
              const SizedBox(height: 20),
              _sectionTitle('لماذا نحن؟'),
              _whySection(),
              const SizedBox(height: 20),
              _statsSection(),
              const SizedBox(height: 30),
              _footer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroBanner() {
    return SizedBox(
      height: 320,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/about_hero.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: _green),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x220C4B3A), Color(0x000C4B3A)],
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 30,
            bottom: 30,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: _gold.withValues(alpha: 0.5),
                          blurRadius: 25,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'وجبة الحرمين',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Cairo',
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(width: 30, height: 1.5, color: _gold),
                      const SizedBox(width: 8),
                      const Text(
                        'غذاء .. وطمأنينة',
                        style: TextStyle(
                          color: _gold,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Cairo',
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(width: 30, height: 1.5, color: _gold),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(width: 50, height: 4, color: _gold),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: _green,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              fontFamily: 'Cairo',
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _aboutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(
            flex: 3,
            child: Text(
              'تطبيق وجبة الحرمين هو مبادرة إنسانية تهدف إلى توفير الوجبات وسلال الإفطار والمياه للحجاج والمعتمرين، بما يساهم في تلبية احتياجاتهم وتخفيف عنائهم، وتعزيز قيم التكافل والعطاء في أطهر بقاع الأرض.',
              style: TextStyle(
                color: Color(0xFF0C4B3A),
                fontSize: 16,
                fontFamily: 'Cairo',
                height: 2.2,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Container(
            width: 200,
            height: 280,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(100),
                topRight: Radius.circular(100),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: _gold, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(94),
                topRight: Radius.circular(94),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              child: Image.asset(
                'assets/about_about.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: _lightGreen),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featuresSection() {
    final features = [
      {'icon': Icons.volunteer_activism, 'label': 'الصدقة العامة'},
      {'icon': Icons.restaurant, 'label': 'الوجبات'},
      {'icon': Icons.breakfast_dining, 'label': 'سلال الإفطار'},
      {'icon': Icons.water_drop, 'label': 'المياه'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: features.map((f) {
          return Expanded(
            child: Container(
              height: 140,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E0E0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: _lightGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(f['icon'] as IconData, color: _green, size: 30),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    f['label'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _green,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Cairo',
                      height: 1.3,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _whySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Image.asset(
              'assets/about_why.jpg',
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(height: 180, color: _green),
            ),
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [_green.withValues(alpha: 0.85), Colors.transparent],
                ),
              ),
            ),
            const Positioned.fill(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(top: 20, right: 20),
                  child: SizedBox(
                    width: 240,
                    child: Text(
                      'لأننا نؤمن أن العطاء في هذه البقاع المباركة ليس مجرد تبرع .. بل هو أثر يبقى وراحة قلب وشعور بالطمأنينة.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Cairo',
                        height: 2.1,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
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

  Widget _statsSection() {
    final stats = [
      {
        'icon': Icons.location_on,
        'label': 'مناطق التوزيع',
        'value': 'مكة - المدينة',
      },
      {'icon': Icons.calendar_today, 'label': 'بداية التطبيق', 'value': '2026'},
      {'icon': Icons.verified_user, 'label': 'موثوقية', 'value': '100%'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: stats.map((s) {
          return Expanded(
            child: Container(
              height: 120,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(s['icon'] as IconData, color: _gold, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    s['label'] as String,
                    style: const TextStyle(
                      color: _green,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Cairo',
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    s['value'] as String,
                    style: const TextStyle(
                      color: _gold,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Cairo',
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _footer() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Text(
            '© 2026 وجبة الحرمين - جميع الحقوق محفوظة',
            style: TextStyle(
              color: _grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Cairo',
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'مشروع تخرج',
            style: TextStyle(
              color: _grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Cairo',
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
