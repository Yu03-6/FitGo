import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class RegistrationOTPPage extends ConsumerStatefulWidget {
  final String email;

  const RegistrationOTPPage({Key? key, required this.email}) : super(key: key);

  @override
  ConsumerState<RegistrationOTPPage> createState() =>
      _RegistrationOTPPageState();
}

class _RegistrationOTPPageState extends ConsumerState<RegistrationOTPPage> {
  late TextEditingController _otpController;
  bool _isLoading = false;
  String? _error;
  int _secondsLeft = 300; // 5 minutes
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _startTimer();
  }

  void _startTimer() {
    if (_isTimerRunning) return; // Prevent multiple timers

    _isTimerRunning = true;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
        return true;
      }
      _isTimerRunning = false;
      return false;
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) {
      setState(() => _error = 'OTP must be 6 digits');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // First verify the OTP
      final success = await ref
          .read(authProvider.notifier)
          .verifyOTP(widget.email, _otpController.text, 'registration');

      if (!success && mounted) {
        setState(() => _error = 'OTP verification failed');
        return;
      }

      // Get temporary registration data
      final authState = ref.read(authProvider);
      final tempUsername = authState.tempUsername;
      final tempPassword = authState.tempPassword;
      final tempRepassword = authState.tempRepassword;

      if (tempUsername == null ||
          tempPassword == null ||
          tempRepassword == null) {
        setState(
            () => _error = 'Registration data not found. Please try again.');
        return;
      }

      // Register the user with stored password
      final registerSuccess = await ref
          .read(authProvider.notifier)
          .register(widget.email, tempUsername, tempPassword, tempRepassword);

      if (registerSuccess && mounted) {
        // Clear temporary data
        ref.read(authProvider.notifier).clearTempRegistrationData();

        // Logout immediately after registration so user can login freshly
        await ref.read(authProvider.notifier).logout();

        // Navigate back to login page
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Registration successful! Please login with your account.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendOTP() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get temporary registration data to resend OTP
      final authState = ref.read(authProvider);
      final tempUsername = authState.tempUsername;
      final tempPassword = authState.tempPassword;
      final tempRepassword = authState.tempRepassword;

      if (tempUsername == null ||
          tempPassword == null ||
          tempRepassword == null) {
        setState(
            () => _error = 'Registration data expired. Please start over.');
        return;
      }

      // Resend OTP with stored registration data
      await ref.read(authProvider.notifier).sendOTP(
            widget.email,
            'registration',
            username: tempUsername,
            password: tempPassword,
            repassword: tempRepassword,
          );

      if (mounted) {
        // Reset timer
        setState(() {
          _secondsLeft = 300; // Reset to 5 minutes
          _isTimerRunning = false; // Reset flag so timer can restart
        });
        _startTimer();

        showSnackBar('Verification code sent successfully!');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Verification Code',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a 6-digit code to ${widget.email}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: '000000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  counterText: '',
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                style: const TextStyle(fontSize: 24, letterSpacing: 10),
                onChanged: (value) {
                  if (value.length == 6) {
                    _verifyOTP();
                  }
                },
              ),
              const SizedBox(height: 20),
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Verify OTP'),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Code expires in ${minutes}m ${seconds}s',
                  style: TextStyle(
                    color: _secondsLeft < 60 ? Colors.red : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: _isLoading ? null : _resendOTP,
                  child: Text(
                    'Didn\'t receive code? Resend',
                    style: TextStyle(
                      color: Colors.blue[700],
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
