import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/di/injector.dart';
import '../../../app/router/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/responsive_constrained.dart';
import '../domain/repositories/i_auth_repository.dart';

/// Shown after registration (no JWT) or when login is blocked until email is verified.
class EmailVerificationPendingScreen extends StatefulWidget {
  final String email;

  const EmailVerificationPendingScreen({super.key, required this.email});

  @override
  State<EmailVerificationPendingScreen> createState() =>
      _EmailVerificationPendingScreenState();
}

class _EmailVerificationPendingScreenState
    extends State<EmailVerificationPendingScreen> {
  bool _sending = false;

  Future<void> _resend() async {
    if (widget.email.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add your email on the registration screen.')),
      );
      return;
    }
    setState(() => _sending = true);
    try {
      await getIt<IAuthRepository>().resendVerification(widget.email.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('If the account is pending, a new email was sent.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Verify your email')),
      body: ResponsiveConstrained(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          children: [
            Icon(Icons.mark_email_unread_outlined,
                size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: AppSizes.spacingL),
            Text(
              'Check your inbox',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSizes.spacingM),
            Text(
              'We sent a verification link${widget.email.isNotEmpty ? ' to ${widget.email}' : ''}. '
              'Open the link, then return here and sign in.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSizes.spacingXL),
            FilledButton(
              onPressed: _sending ? null : _resend,
              child: _sending
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Resend verification email'),
            ),
            const SizedBox(height: AppSizes.spacingM),
            TextButton(
              onPressed: () => context.go(AppRouter.login),
              child: const Text('Back to sign in', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}
