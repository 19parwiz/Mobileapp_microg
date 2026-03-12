import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input.dart';
import '../../../core/widgets/responsive_constrained.dart';
import '../../../app/router/app_router.dart';
import '../../../app/di/injector.dart';
import '../domain/usecases/register_use_case.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final registerUseCase = getIt<RegisterUseCase>();
      await registerUseCase(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      );

      if (mounted) {
        context.go(AppRouter.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.register),
      ),
      body: SafeArea(
        child: ResponsiveConstrained(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                const SizedBox(height: AppSizes.spacingL),
                AppInput(
                  label: 'Name (Optional)',
                  hint: 'Enter your name',
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  prefixIcon: Icons.person_outlined,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSizes.spacingL),
                AppInput(
                  label: AppStrings.email,
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.text,
                  validator: Validators.email,
                  prefixIcon: Icons.email_outlined,
                  textInputAction: TextInputAction.next,
                  enabled: true,
                ),
                const SizedBox(height: AppSizes.spacingL),
                AppInput(
                  label: AppStrings.password,
                  hint: 'Enter your password',
                  controller: _passwordController,
                  obscureText: true,
                  validator: Validators.password,
                  prefixIcon: Icons.lock_outlined,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSizes.spacingL),
                AppInput(
                  label: AppStrings.confirmPassword,
                  hint: 'Confirm your password',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  validator: _validateConfirmPassword,
                  prefixIcon: Icons.lock_outlined,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleRegister(),
                ),
                const SizedBox(height: AppSizes.spacingXL),
                AppButton(
                  text: AppStrings.register,
                  onPressed: _handleRegister,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: AppSizes.spacingL),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.alreadyHaveAccount,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        context.go(AppRouter.login);
                      },
                      child: const Text(AppStrings.signIn),
                    ),
                  ],
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

