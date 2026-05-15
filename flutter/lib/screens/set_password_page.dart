import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class SetPasswordPage extends ConsumerStatefulWidget {
  final String email;

  const SetPasswordPage({Key? key, required this.email}) : super(key: key);

  @override
  ConsumerState<SetPasswordPage> createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends ConsumerState<SetPasswordPage> {
  late TextEditingController _usernameController;
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
  bool get _hasUsername => _usernameController.text.trim().isNotEmpty;

  bool get _isFormValid =>
      _hasUsername &&
      _isMinLength &&
      _isMaxLength &&
      _hasUpperCase &&
      _hasLowerCase &&
      _hasNumber &&
      _passwordsMatch;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _repasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _repasswordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (!_isFormValid) {
      setState(() => _error = 'Please fix all issues above');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: Call auth_provider.register(email, password, repassword)
      final success = await ref.read(authProvider.notifier).register(
            widget.email,
            _usernameController.text.trim(),
            _passwordController.text,
            _repasswordController.text,
          );

      if (success && mounted) {
        // Navigate to home page
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
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
        title: const Text('Create Password'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create a Strong Password',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Use 8-15 characters with uppercase, lowercase, and numbers',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 30),
              // Username field
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter your display name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              // Password field
              TextField(
                controller: _passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Password',
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
                  labelText: 'Confirm Password',
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
                met: _hasUsername,
                text: 'Username provided',
              ),
              const SizedBox(height: 8),
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
                  onPressed: _isLoading || !_isFormValid ? null : _registerUser,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Create Account'),
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
