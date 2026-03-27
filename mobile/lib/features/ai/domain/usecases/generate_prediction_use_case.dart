import '../entities/prediction_result.dart';
import '../repositories/i_prediction_repository.dart';

/// One action: generate a prediction.
class GeneratePredictionUseCase {
  final IPredictionRepository _predictionRepository;

  GeneratePredictionUseCase({required IPredictionRepository predictionRepository})
      : _predictionRepository = predictionRepository;

  Future<PredictionResult> call(String imagePath) =>
      _predictionRepository.generatePrediction(imagePath);
}


