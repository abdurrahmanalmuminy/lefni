import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _prefix = 'lefni_onboarding_completed_';

  static String _key({
    required String onboardingId,
    required String roleId,
    required String uid,
  }) {
    return '$_prefix${onboardingId}_$roleId\_$uid';
  }

  static Future<bool> isCompleted({
    required String onboardingId,
    required String roleId,
    required String uid,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(onboardingId: onboardingId, roleId: roleId, uid: uid)) ??
        false;
  }

  static Future<void> markCompleted({
    required String onboardingId,
    required String roleId,
    required String uid,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      _key(onboardingId: onboardingId, roleId: roleId, uid: uid),
      true,
    );
  }

  static Future<void> clear({
    required String onboardingId,
    required String roleId,
    required String uid,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(
      _key(onboardingId: onboardingId, roleId: roleId, uid: uid),
    );
  }
}

