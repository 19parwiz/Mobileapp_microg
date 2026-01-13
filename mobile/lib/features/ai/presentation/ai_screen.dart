import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../app/di/injector.dart';
import '../domain/usecases/generate_prediction_use_case.dart';

/// Placeholder AI predictions screen
class AIScreen extends StatelessWidget {
  const AIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.go(AppRouter.home),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco, color: AppColors.primary),
            SizedBox(width: AppSizes.spacingS),
            Text('AI Predictions'),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.eco,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSizes.spacingL),
              Text(
                'AI Predictions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: AppSizes.spacingM),
              Text(
                'AI-powered predictions for microgreens growth',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spacingXL),
              ElevatedButton.icon(
                onPressed: () async {
                  debugPrint('AI screen action button pressed');
                  final useCase = getIt<GeneratePredictionUseCase>();
                  final result = await useCase();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result.message)),
                    );
                  }
                },
                icon: const Icon(Icons.eco),
                label: const Text('Generate Predictions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingL,
                    vertical: AppSizes.paddingM,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

