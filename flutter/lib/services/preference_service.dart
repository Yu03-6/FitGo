import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app preferences and settings
class PreferenceService {
  static const String _welcomeDialogShownKey = 'welcome_dialog_shown_date';
  static const String _dontShowTodayKey = 'dont_show_welcome_today';

  /// Check if welcome dialog should be shown
  /// Returns true unless user opted out for today
  Future<bool> shouldShowWelcomeDialog() async {
    final prefs = await SharedPreferences.getInstance();

    // Get today's date
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month}-${today.day}';
    print('PreferenceService: Checking welcome dialog for date: $todayString');

    // Check when the dialog was last shown
    final lastShownDate = prefs.getString(_welcomeDialogShownKey);
    print('PreferenceService: Last shown date: $lastShownDate');

    // If it's a different day, clear the "don't show today" preference
    if (lastShownDate != todayString) {
      await prefs.setBool(_dontShowTodayKey, false);
      print('PreferenceService: Different day or first time, returning true');
      return true; // New day, always show
    }

    // Same day - check if user opted out
    final dontShowToday = prefs.getBool(_dontShowTodayKey) ?? false;
    print('PreferenceService: Same day, dontShowToday: $dontShowToday');
    return !dontShowToday; // Show unless user opted out for today
  }

  /// Mark welcome dialog as shown for today
  Future<void> markWelcomeDialogShown({required bool dontShowToday}) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month}-${today.day}';

    await prefs.setString(_welcomeDialogShownKey, todayString);
    await prefs.setBool(_dontShowTodayKey, dontShowToday);
  }

  /// Clear welcome dialog preferences (useful for testing)
  Future<void> clearWelcomeDialogPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_welcomeDialogShownKey);
    await prefs.remove(_dontShowTodayKey);
  }
}
