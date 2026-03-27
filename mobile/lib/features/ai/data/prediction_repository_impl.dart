import 'package:dio/dio.dart';

import '../domain/entities/prediction_result.dart';
import '../domain/repositories/i_prediction_repository.dart';

class PredictionRepositoryImpl implements IPredictionRepository {
  final Dio _dio;

  PredictionRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  Future<PredictionResult> generatePrediction(String imagePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imagePath),
    });

    final response = await _dio.post('/ai/predict', data: formData);
    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Prediction response was not valid JSON.',
      );
    }

    final rawPredictions = data['predictions'];
    final predictions = rawPredictions is List
        ? rawPredictions.whereType<String>().toList()
        : const <String>[];

    return PredictionResult(
      message: (data['message'] as String?) ?? 'Prediction completed successfully.',
      filename: data['filename'] as String?,
      topPrediction: data['topPrediction'] as String?,
      predictions: predictions,
    );
  }
}
