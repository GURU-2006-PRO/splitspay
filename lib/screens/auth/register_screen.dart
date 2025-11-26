import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isValid = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isValid = _nameController.text.isNotEmpty &&
                 _emailController.text.isNotEmpty &&
                 _passwordController.text.length >= 6 &&
                 _passwordController.text == _confirmPasswordController.text;
    });
  }

  Future<void> _handleRegister() async {
    if (!_isValid) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      Helpers.showErrorSnackBar(context, 'Passwords do not match');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );
      // Navigation handled by AuthWrapper
    } catch (e) {
      if (!mounted) return;
      Helpers.showErrorSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Account',
                style: AppTextStyles.headline1,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Sign up to get started',
                style: AppTextStyles.body1,
              ),
              
              const SizedBox(height: 40),
              
              const Text('Full Name', style: AppTextStyles.body2),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Enter your full name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              const Text('Email', style: AppTextStyles.body2),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              const Text('Password', style: AppTextStyles.body2),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'At least 6 characters',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              const Text('Confirm Password', style: AppTextStyles.body2),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  hintText: 'Re-enter your password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              CustomButton(
                text: 'Create Account',
                onPressed: _isValid ? _handleRegister : null,
                isLoading: authProvider.isLoading,
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? '),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Sign In'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
