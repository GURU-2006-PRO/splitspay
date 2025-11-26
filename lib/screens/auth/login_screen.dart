import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isValid = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isValid = _emailController.text.isNotEmpty && 
                 _passwordController.text.isNotEmpty;
    });
  }

  Future<void> _handleLogin() async {
    if (!_isValid) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              // Logo or Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    size: 64,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              const Text(
                'Welcome to\nDynamic Group Wallet',
                style: AppTextStyles.headline1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Center(
                child: Text(
                  'Split expenses smartly with your group',
                  style: AppTextStyles.body1,
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 48),
              
              const Text('Email', style: AppTextStyles.body2),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
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
                  hintText: 'Enter your password',
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
              
              const SizedBox(height: AppSpacing.lg),
              
              CustomButton(
                text: 'Sign In',
                onPressed: _isValid ? _handleLogin : null,
                isLoading: authProvider.isLoading,
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account? '),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
