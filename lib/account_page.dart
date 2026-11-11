import 'package:flutter/material.dart';

import 'cards_page.dart';
import 'login_page.dart';
import 'main.dart' show isUserLoggedInNotifier;
import 'notifications_page.dart';
import 'orders_page.dart';
import 'user_session.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  static const _green = Color(0xFF0C4B3A);
  static const _muted = Color(0xFF757575);
  static const _divider = Color(0xFFEEEEEE);

  String _country = 'السعودية 🇸🇦';

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
          titleSpacing: 0,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'حسابي',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  fontFamily: 'Cairo',
                ),
              ),
              Text(
                'إدارة حسابك وطلباتك',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
        body: ValueListenableBuilder<bool>(
          valueListenable: isUserLoggedInNotifier,
          builder: (context, isUserLoggedIn, child) {
            return ValueListenableBuilder<Map<String, dynamic>?>(
              valueListenable: currentUserNotifier,
              builder: (context, user, child) {
                final loggedIn =
                    isUserLoggedIn && user != null;

                return _accountView(
                  loggedIn,
                  user,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _accountView(
    bool isUserLoggedIn,
    Map<String, dynamic>? user,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _userCard(isUserLoggedIn, user),
          _quickCards(),
          _addressAndCards(),
          _countrySection(),
          _notifications(),
          if (isUserLoggedIn) _logoutCard(),
          _footer(),
        ],
      ),
    );
  }

  Widget _userCard(
    bool isUserLoggedIn,
    Map<String, dynamic>? user,
  ) {
    final fullName =
        user?['fullName']?.toString().trim() ?? '';
    final email = user?['email']?.toString().trim() ?? '';
    final username = user?['username']?.toString().trim() ?? '';

    final displayName = fullName.isNotEmpty
        ? fullName
        : username.isNotEmpty
            ? username
            : 'المستخدم';

    final displayEmail = email.isNotEmpty
        ? email
        : username.isNotEmpty
            ? '@$username'
            : 'بيانات الحساب غير متوفرة';

    return _card(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor:
                isUserLoggedIn ? _green : const Color(0xFFE0E0E0),
            child: isUserLoggedIn
                ? Text(
                    _getInitials(displayName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Cairo',
                    ),
                  )
                : const Icon(
                    Icons.person,
                    color: _muted,
                    size: 28,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUserLoggedIn
                      ? 'مرحباً، $displayName'
                      : 'مرحباً بك',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isUserLoggedIn
                      ? displayEmail
                      : 'سجل دخولك للاستفادة من خدماتنا',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          if (isUserLoggedIn)
            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ميزة تعديل الحساب غير متاحة حاليًا'),
                  ),
                );
              },
              icon: const Icon(
                Icons.edit,
                size: 16,
                color: _muted,
              ),
              label: const Text(
                'تعديل',
                style: TextStyle(
                  color: _muted,
                  fontSize: 12,
                  fontFamily: 'Cairo',
                ),
              ),
            )
          else
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'تسجيل الدخول',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '؟';

    if (parts.length == 1) {
      return parts.first.characters.first;
    }

    return '${parts[0].characters.first}${parts[1].characters.first}';
  }

  Widget _quickCards() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: _quickCard(
              title: 'طلباتي',
              subtitle: 'قائمة الطلبات',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OrdersPage(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _quickCard(
              title: 'قائمة رغباتي',
              subtitle: 'المنتجات المفضلة',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('المفضلة فارغة'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 100,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _quickTitle(title),
                _quickSubtitle(subtitle),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickTitle(String text) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 15,
        fontFamily: 'Cairo',
      ),
    );
  }

  Widget _quickSubtitle(String text) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: _muted,
        fontSize: 11,
        fontFamily: 'Cairo',
      ),
    );
  }

  Widget _addressAndCards() {
    return _card(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            _listRow(
              icon: Icons.location_on_outlined,
              title: 'العناوين',
              onTap: () {},
            ),
            const Divider(height: 1, color: _divider),
            _listRow(
              icon: Icons.credit_card,
              title: 'إدارة البطاقات',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CardsPage(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _countrySection() {
    return _card(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: _chooseCountry,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                Icons.public,
                color: _green,
                size: 22,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: _SettingTitle('البلد'),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3EF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _country,
                  style: const TextStyle(
                    color: _green,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_left,
                color: _muted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _chooseCountry() async {
    const countries = [
      'السعودية 🇸🇦',
      'الإمارات 🇦🇪',
      'مصر 🇪🇬',
      'الأردن 🇯🇴',
      'الكويت 🇰🇼',
    ];

    final selectedCountry = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: countries
              .map(
                (country) => ListTile(
                  leading: Icon(
                    _country == country
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: _green,
                  ),
                  title: Text(
                    country,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                    ),
                  ),
                  onTap: () => Navigator.pop(context, country),
                ),
              )
              .toList(),
        ),
      ),
    );

    if (selectedCountry != null && mounted) {
      setState(() => _country = selectedCountry);
    }
  }

  Widget _notifications() {
    return _card(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      child: _listRow(
        icon: Icons.notifications_none,
        title: 'الإشعارات',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const NotificationsPage(),
          ),
        ),
      ),
    );
  }

  Widget _listRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: _green, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: _SettingTitle(title),
            ),
            const Icon(
              Icons.chevron_left,
              color: _muted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoutCard() {
    return _card(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          clearUserSession();
          isUserLoggedInNotifier.value = false;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تسجيل الخروج بنجاح'),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                Icons.logout,
                color: Colors.red,
                size: 22,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footer() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _socialIcon(
                const Icon(
                  Icons.camera_alt_outlined,
                  color: _muted,
                ),
              ),
              const SizedBox(width: 10),
              _socialIcon(
                const Icon(
                  Icons.business_center_outlined,
                  color: _muted,
                ),
              ),
              const SizedBox(width: 10),
              _socialIcon(
                const Text(
                  'X',
                  style: TextStyle(
                    color: _muted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _socialIcon(
                const Icon(
                  Icons.facebook,
                  color: _muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '©️ 2026 وجبة الحرمين - جميع الحقوق محفوظة',
            style: TextStyle(
              color: _muted,
              fontSize: 11,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(Widget child) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: _divider,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color color = Colors.white,
    double? height,
  }) {
    return Container(
      width: double.infinity,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _SettingTitle extends StatelessWidget {
  const _SettingTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 14,
        fontFamily: 'Cairo',
      ),
    );
  }
}