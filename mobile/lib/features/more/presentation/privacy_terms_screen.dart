import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/responsive_constrained.dart';

class PrivacyTermsScreen extends StatelessWidget {
  const PrivacyTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Terms'),
      ),
      body: SafeArea(
        child: ResponsiveConstrained(
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            children: [
              Text(
                'Privacy Policy',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSizes.spacingS),
              const Text(
                'We collect only the information required to provide app features, '
                'including account data and device telemetry you choose to connect.',
              ),
              const SizedBox(height: AppSizes.spacingM),
              const Text(
                'Your data is used to display dashboards, notifications, and recommendations. '
                'We do not sell your personal data.',
              ),
              const SizedBox(height: AppSizes.spacingL),
              Text(
                'Terms of Use',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSizes.spacingS),
              const Text(
                'By using this app, you agree to use it responsibly and keep your account credentials secure. '
                'You are responsible for the devices connected to your account.',
              ),
              const SizedBox(height: AppSizes.spacingM),
              const Text(
                'Service availability and features may evolve over time as improvements are released.',
              ),
              const SizedBox(height: AppSizes.spacingXL),
              ElevatedButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
