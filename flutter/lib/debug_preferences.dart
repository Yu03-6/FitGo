import 'package:shared_preferences/shared_preferences.dart';

/// Test script to debug and clear welcome dialog preferences
void main() async {
  final prefs = await SharedPreferences.getInstance();

  print('=== Current Preferences ===');
  final lastShownDate = prefs.getString('welcome_dialog_shown_date');
  final dontShowToday = prefs.getBool('dont_show_welcome_today');

  print('Last shown date: $lastShownDate');
  print('Don\'t show today: $dontShowToday');

  // Clear preferences for testing
  print('\n=== Clearing preferences ===');
  await prefs.remove('welcome_dialog_shown_date');
  await prefs.remove('dont_show_welcome_today');

  print('Preferences cleared!');
  print('\nRestart the app to see welcome dialog.');
}
