import '../domain/entities/prediction_result.dart';
import '../domain/repositories/i_prediction_repository.dart';

/// Minimal placeholder implementation to preserve current UI behavior.
class PredictionRepositoryImpl implements IPredictionRepository {
  @override
  Future<PredictionResult> generatePrediction() async {
    // Keep behavior consistent with current placeholder UI.
    return const PredictionResult(message: 'AI predictions feature coming soon!');
  }
}


