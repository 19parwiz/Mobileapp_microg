import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/responsive_constrained.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About App'),
      ),
      body: SafeArea(
        child: ResponsiveConstrained(
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            children: [
              Text(
                'Microgreens Assistant',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSizes.spacingS),
              Text(
                'Version 1.0.0',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSizes.spacingL),
              Text(
                'Microgreens Assistant helps you monitor and manage your growing environment. '
                'Use the app to view sensors, track your plants, manage IoT devices, and get AI guidance.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSizes.spacingL),
              Text(
                'Main features:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppSizes.spacingS),
              const Text('- Live sensor monitoring'),
              const Text('- Plant tracking and management'),
              const Text('- Device management'),
              const Text('- AI assistant support'),
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
