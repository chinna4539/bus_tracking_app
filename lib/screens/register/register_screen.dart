import 'package:flutter/material.dart';

import '../../core/app_routes.dart';
import '../../widgets/auth_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordHidden = true;
  bool _isConfirmHidden = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              const SizedBox(height: 14),
              Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Sign up and get instant access to live bus routes and arrival alerts.',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 26),
              AuthTextField(
                label: 'Full Name',
                controller: _nameController,
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                label: 'Phone Number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_android,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                label: 'Password',
                controller: _passwordController,
                obscureText: _isPasswordHidden,
                prefixIcon: Icons.lock_outline,
                suffixIcon: _isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                onSuffixTap: () {
                  setState(() => _isPasswordHidden = !_isPasswordHidden);
                },
              ),
              const SizedBox(height: 16),
              AuthTextField(
                label: 'Confirm Password',
                controller: _confirmPasswordController,
                obscureText: _isConfirmHidden,
                prefixIcon: Icons.lock_outline,
                suffixIcon: _isConfirmHidden ? Icons.visibility_off : Icons.visibility,
                onSuffixTap: () {
                  setState(() => _isConfirmHidden = !_isConfirmHidden);
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  4,
                   (index) => Container(
                     height: 58,
                     width: 58,
                     decoration: BoxDecoration(
                       color: Theme.of(context).colorScheme.surfaceContainerHighest,
                       borderRadius: BorderRadius.circular(16),
                     ),
                     child: Center(
                       child: Text(
                         '•',
                         style: TextStyle(fontSize: 28, color: Theme.of(context).colorScheme.onSurface),
                       ),
                     ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'OTP verification will be available after account creation.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                  child: const Text('Create Account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
