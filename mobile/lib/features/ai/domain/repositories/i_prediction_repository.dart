import 'dart:typed_data';

import '../entities/prediction_result.dart';

/// Domain abstraction for generating predictions (API/ML/local, etc).
abstract class IPredictionRepository {
  Future<PredictionResult> generatePrediction(String imagePath);

  /// Same as [generatePrediction] but uploads raw image bytes (e.g. stream frame capture).
  Future<PredictionResult> generatePredictionFromBytes(
    Uint8List bytes, {
    String filename = 'capture.png',
  });
}


