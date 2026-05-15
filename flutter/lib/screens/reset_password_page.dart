import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  final String email;

  const ResetPasswordPage({Key? key, required this.email}) : super(key: key);

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  late TextEditingController _passwordController;
  late TextEditingController _repasswordController;
  bool _showPassword = false;
  bool _showRepassword = false;
  bool _isLoading = false;
  String? _error;

  // Password validation
  bool get _isMinLength => _passwordController.text.length >= 8;
  bool get _isMaxLength => _passwordController.text.length <= 15;
  bool get _hasUpperCase => _passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get _hasLowerCase => _passwordController.text.contains(RegExp(r'[a-z]'));
  bool get _hasNumber => _passwordController.text.contains(RegExp(r'[0-9]'));
  bool get _passwordsMatch =>
      _passwordController.text == _repasswordController.text &&
      _passwordController.text.isNotEmpty;

  bool get _isFormValid =>
      _isMinLength &&
      _isMaxLength &&
      _hasUpperCase &&
      _hasLowerCase &&
      _hasNumber &&
      _passwordsMatch;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _repasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _repasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_isFormValid) {
      setState(() => _error = 'Please fix all issues above');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(authProvider.notifier).resetPassword(
            widget.email,
            _passwordController.text,
            _repasswordController.text,
          );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text(
                'Your password has been reset. Please login with your new password.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', (route) => false);
                },
                child: const Text('Go to Login'),
              ),
            ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create a New Password',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a strong password with 8-15 characters, uppercase, lowercase, and numbers',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 30),
              // Password field
              TextField(
                controller: _passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _showPassword = !_showPassword);
                    },
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              // Confirm password field
              TextField(
                controller: _repasswordController,
                obscureText: !_showRepassword,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showRepassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _showRepassword = !_showRepassword);
                    },
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              // Password requirements
              _PasswordRequirementItem(
                met: _isMinLength,
                text: 'At least 8 characters',
              ),
              const SizedBox(height: 8),
              _PasswordRequirementItem(
                met: _isMaxLength,
                text: 'At most 15 characters',
              ),
              const SizedBox(height: 8),
              _PasswordRequirementItem(
                met: _hasUpperCase,
                text: 'Contains uppercase letter (A-Z)',
              ),
              const SizedBox(height: 8),
              _PasswordRequirementItem(
                met: _hasLowerCase,
                text: 'Contains lowercase letter (a-z)',
              ),
              const SizedBox(height: 8),
              _PasswordRequirementItem(
                met: _hasNumber,
                text: 'Contains number (0-9)',
              ),
              const SizedBox(height: 8),
              _PasswordRequirementItem(
                met: _passwordsMatch,
                text: 'Passwords match',
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
                  onPressed:
                      _isLoading || !_isFormValid ? null : _resetPassword,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Reset Password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordRequirementItem extends StatelessWidget {
  final bool met;
  final String text;

  const _PasswordRequirementItem({
    required this.met,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle : Icons.radio_button_unchecked,
          color: met ? Colors.green : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            color: met ? Colors.green : Colors.grey,
            decoration: met ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }
}
