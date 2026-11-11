import 'package:flutter/material.dart';

class DistributionPage extends StatelessWidget {
  const DistributionPage({super.key});

  static const _green = Color(0xFF0B4F34);
  static const _gold = Color(0xFFC6963C);
  static const _makkahLocations = [
    _DistributionLocation(
      name: 'المسجد الحرام - باب الملك فهد',
      address: 'مكة المكرمة - الحرم المكي',
      time: '6:00 ص - 10:00 م',
      status: 'متاح',
    ),
    _DistributionLocation(
      name: 'مخيم منى - المنطقة 3',
      address: 'منى - قرب جسر الجمرات',
      time: '7:00 ص - 6:00 م',
      status: 'مزدحم',
    ),
    _DistributionLocation(
      name: 'مخيم عرفات - الجبل',
      address: 'عرفات - قرب جبل الرحمة',
      time: '8:00 ص - 4:00 م',
      status: 'متاح',
    ),
    _DistributionLocation(
      name: 'منطقة العزيزية',
      address: 'مكة - شارع العزيزية العام',
      time: '5:00 ص - 11:00 م',
      status: 'متاح',
    ),
    _DistributionLocation(
      name: 'منطقة الششة',
      address: 'مكة - حي الششة',
      time: '6:00 ص - 9:00 م',
      status: 'مزدحم',
    ),
  ];
  static const _madinahLocations = [
    _DistributionLocation(
      name: 'المسجد النبوي - باب السلام',
      address: 'المدينة المنورة - الحرم النبوي',
      time: '5:30 ص - 11:00 م',
      status: 'متاح',
    ),
    _DistributionLocation(
      name: 'منطقة قباء',
      address: 'المدينة - قرب مسجد قباء',
      time: '6:00 ص - 9:00 م',
      status: 'متاح',
    ),
    _DistributionLocation(
      name: 'منطقة العوالي',
      address: 'المدينة - حي العوالي',
      time: '7:00 ص - 8:00 م',
      status: 'متاح',
    ),
    _DistributionLocation(
      name: 'منطقة قربان',
      address: 'المدينة - حي قربان',
      time: '6:00 ص - 10:00 م',
      status: 'مزدحم',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0C4B3A),
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            leading: IconButton(
              tooltip: 'رجوع',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
              ),
            ),
            titleSpacing: 0,
            title: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مواقع التوزيع',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  'مكة المكرمة والمدينة المنورة',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
            bottom: const TabBar(
              indicatorColor: _gold,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              tabs: [
                Tab(text: 'مكة المكرمة'),
                Tab(text: 'المدينة المنورة'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _locationList(_makkahLocations),
              _locationList(_madinahLocations),
            ],
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'جاري تحديد موقعك...',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.my_location),
                  label: const Text(
                    'تحديد موقعي الحالي',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _locationList(List<_DistributionLocation> locations) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: ListView.builder(
          itemCount: locations.length,
          itemBuilder: (context, index) => _locationCard(locations[index]),
        ),
      ),
    );
  }

  Widget _locationCard(_DistributionLocation location) {
    final isAvailable = location.status == 'متاح';
    final statusColor = isAvailable ? _green : const Color(0xFFC77719);
    final statusBackground = isAvailable
        ? const Color(0xFFEAF3EF)
        : const Color(0xFFFBF4E4);

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFBF4E4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: _gold,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.name,
                  style: const TextStyle(
                    color: _green,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location.address,
                  style: const TextStyle(
                    color: Color(0xFF73807B),
                    fontSize: 12,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: _gold, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      location.time,
                      style: const TextStyle(
                        color: _gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              location.status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DistributionLocation {
  const _DistributionLocation({
    required this.name,
    required this.address,
    required this.time,
    required this.status,
  });

  final String name;
  final String address;
  final String time;
  final String status;
}
