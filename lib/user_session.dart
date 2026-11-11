import 'package:flutter/foundation.dart';

/// بيانات المستخدم المسجل دخوله حاليًا.
final ValueNotifier<Map<String, dynamic>?> currentUserNotifier =
    ValueNotifier<Map<String, dynamic>?>(null);

/// حفظ بيانات المستخدم بعد نجاح تسجيل الدخول.
void saveUserSession(Map<String, dynamic> user) {
  currentUserNotifier.value = Map<String, dynamic>.from(user);
}

/// مسح بيانات المستخدم عند تسجيل الخروج.
void clearUserSession() {
  currentUserNotifier.value = null;
}