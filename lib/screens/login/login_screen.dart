import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_routes.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Hero(
                    tag: 'appLogo',
                     child: Container(
                       padding: const EdgeInsets.all(14),
                       decoration: BoxDecoration(
                         color: Theme.of(context).colorScheme.surfaceContainerHighest,
                         borderRadius: BorderRadius.circular(18),
                       ),
                      child: const Icon(
                        Icons.directions_bus_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.home);
                    },
                    child: const Text('Continue as Guest'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Login to continue tracking live buses in Vizag.',
                style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 28),
              AuthTextField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 18),
              AuthTextField(
                label: 'Password',
                controller: _passwordController,
                obscureText: authProvider.isPasswordHidden,
                prefixIcon: Icons.lock_outline,
                suffixIcon: authProvider.isPasswordHidden
                    ? Icons.visibility_off
                    : Icons.visibility,
                onSuffixTap: authProvider.togglePasswordVisibility,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: authProvider.isRememberMe,
                        onChanged: (value) {
                          if (value != null) {
                            authProvider.toggleRememberMe(value);
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        fillColor: WidgetStateProperty.all(AppColors.primary),
                      ),
                      Text(
                        'Remember Me',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () async {
                          if (_emailController.text.trim().isEmpty) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter your email to reset password.')),
                              );
                            }
                            return;
                          }
                          await authProvider.sendPasswordResetEmail(_emailController.text.trim());
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(authProvider.errorMessage ?? 'Password reset email sent.')),
                            );
                          }
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                   ),
                  ],
                ),
                const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : () async {
                          final email = _emailController.text.trim();
                          final password = _passwordController.text;
                          if (email.isEmpty || password.isEmpty) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter email and password.')),
                              );
                            }
                            return;
                          }
                          final success = await authProvider.signInWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                          if (success && mounted) {
                            Navigator.pushReplacementNamed(context, AppRoutes.home);
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(authProvider.errorMessage ?? 'Login failed.')),
                            );
                          }
                        },
                  child: authProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Login'),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  'or continue with',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Google sign-in'),
                            content: const Text(
                              'Google sign-in requires additional Firebase configuration. It will be available in a future update.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.g_mobiledata,
                        color: AppColors.primary,
                      ),
                      label: const Text('Google'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.onSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        side: BorderSide(color: Theme.of(context).colorScheme.outline),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'New to Bus Tracking? ',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.register);
                    },
                    child: const Text('Create account'),
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
