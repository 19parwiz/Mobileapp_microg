/// AI image prediction result returned by backend.
class PredictionResult {
  final String message;
  final String? filename;
  final String? topPrediction;
  final List<String> predictions;

  const PredictionResult({
    required this.message,
    this.filename,
    this.topPrediction,
    this.predictions = const [],
  });
}


