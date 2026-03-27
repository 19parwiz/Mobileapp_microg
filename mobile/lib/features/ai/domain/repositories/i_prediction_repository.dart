import '../entities/prediction_result.dart';

/// Domain abstraction for generating predictions (API/ML/local, etc).
abstract class IPredictionRepository {
  Future<PredictionResult> generatePrediction(String imagePath);
}


