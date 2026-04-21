import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/responsive_constrained.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium'),
      ),
      body: SafeArea(
        child: ResponsiveConstrained(
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grow smarter with Premium',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: AppSizes.spacingS),
                    Text(
                      'Get more detailed detection insights, extended history, and priority support.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spacingL),
              const _FeatureTile(
                icon: Icons.biotech,
                title: 'Advanced Detection',
                subtitle: 'Richer disease and growth analysis with confidence details.',
              ),
              const _FeatureTile(
                icon: Icons.history,
                title: 'Longer History',
                subtitle: 'Keep more snapshots and prediction records over time.',
              ),
              const _FeatureTile(
                icon: Icons.support_agent,
                title: 'Priority Support',
                subtitle: 'Faster response and guided troubleshooting help.',
              ),
              const SizedBox(height: AppSizes.spacingL),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plans',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: AppSizes.spacingS),
                      const Text('Monthly: 4.99 USD'),
                      const Text('Yearly: 39.99 USD'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spacingL),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Premium checkout will be connected soon.'),
                    ),
                  );
                },
                icon: const Icon(Icons.workspace_premium),
                label: const Text('Continue to Premium'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
