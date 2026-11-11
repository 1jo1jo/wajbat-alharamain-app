import 'package:flutter/material.dart';

class OrganizationsPage extends StatelessWidget {
  const OrganizationsPage({super.key});

  static const _green = Color(0xFF0C4B3A);
  static const _gold = Color(0xFFC6963C);
  static const _muted = Color(0xFF73807B);
  static const _organizations = [
    (name: 'جمعية إحسان', description: 'خدمة ضيوف الرحمن وتوفير الوجبات'),
    (name: 'جمعية البر بمكة', description: 'دعم الحجاج وتوفير سلال الإفطار'),
    (name: 'مؤسسة الحرمين الخيرية', description: 'رعاية شؤون الحرمين والزوار'),
    (name: 'جمعية الرحمة', description: 'تقديم خدمات طبية وإنسانية للحجاج'),
    (name: 'جمعية كسوة', description: 'توفير احتياجات الحجاج الأساسية'),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: _green,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: IconButton(
            tooltip: 'رجوع',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الجهات المشاركة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                'شركاء الخير',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.handshake, color: _green, size: 24),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'نفخر بشراكتنا مع نخبة من الجهات الخيرية لخدمة ضيوف الرحمن.',
                              style: TextStyle(
                                color: _green,
                                fontSize: 13,
                                fontFamily: 'Cairo',
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (final organization in _organizations)
                      _organizationCard(context, organization),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _organizationCard(
    BuildContext context,
    ({String name, String description}) organization,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showOrganizationDetails(context, organization),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF4E4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.business_rounded,
                  color: _gold,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      organization.name,
                      style: const TextStyle(
                        color: _green,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      organization.description,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 12,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Icon(Icons.verified, color: _green, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'موثقة',
                          style: TextStyle(
                            color: _green,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left, color: _muted),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrganizationDetails(
    BuildContext context,
    ({String name, String description}) organization,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                organization.name,
                style: const TextStyle(
                  color: _green,
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                organization.description,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 14,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'الهاتف: +966XXXXXXXXX',
                style: TextStyle(color: _muted, fontFamily: 'Cairo'),
              ),
              const SizedBox(height: 6),
              const Text(
                'العنوان: مكة المكرمة، المملكة العربية السعودية',
                style: TextStyle(color: _muted, fontFamily: 'Cairo'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
