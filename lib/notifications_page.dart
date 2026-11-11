import 'package:flutter/material.dart';

import 'main.dart' show notificationsNotifier;

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static const _green = Color(0xFF0C4B3A);
  static const _gold = Color(0xFFC6963C);
  static const _muted = Color(0xFF73807B);

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
          title: const Text(
            'الإشعارات',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: ValueListenableBuilder<List<Map<String, String>>>(
          valueListenable: notificationsNotifier,
          builder: (context, notifications, _) {
            if (notifications.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 80,
                      color: _muted,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'لا توجد إشعارات حالياً',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 15,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'سنعلمك عند وصول أي تحديث',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 12,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification =
                          notifications[notifications.length - 1 - index];
                      return _notificationCard(notification);
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => notificationsNotifier.value = [],
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'تعليم الكل كمقروء',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _notificationCard(Map<String, String> notification) {
    final title = notification['title'] ?? '';
    final type = notification['type']?.toLowerCase() ?? '';
    final isDelivery =
        type.contains('delivery') ||
        type.contains('توصيل') ||
        title.contains('توصيل') ||
        title.contains('التوصيل') ||
        title.contains('التجهيز');
    final isPromo =
        type.contains('promo') ||
        type.contains('offer') ||
        type.contains('عرض') ||
        title.contains('عرض');
    final icon = isDelivery
        ? Icons.local_shipping
        : isPromo
        ? Icons.local_offer
        : Icons.receipt_long;
    final iconColor = isDelivery
        ? _gold
        : isPromo
        ? Colors.red
        : _green;
    final iconBackground = isDelivery
        ? const Color(0xFFFBF4E4)
        : isPromo
        ? const Color(0xFFFBE4E4)
        : const Color(0xFFEAF3EF);
    final unread =
        notification['read'] != 'true' && notification['unread'] != 'false';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: _green,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      notification['time'] ?? '',
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 11,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification['message'] ?? '',
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
          if (unread) ...[
            const SizedBox(width: 10),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
