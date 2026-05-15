import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/preference_service.dart';

/// Debug page to help troubleshoot welcome dialog issues
class DebugWelcomePage extends ConsumerWidget {
  const DebugWelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferenceService = PreferenceService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Welcome Dialog'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome Dialog Debug',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  final shouldShow =
                      await preferenceService.shouldShowWelcomeDialog();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Should show welcome: $shouldShow'),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                },
                child: const Text('Check if should show'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await preferenceService.clearWelcomeDialogPreferences();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Welcome preferences cleared! Please restart app.'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Clear Welcome Preferences'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
