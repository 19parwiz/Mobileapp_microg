import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../domain/entities/prediction_result.dart';
import '../domain/repositories/i_prediction_repository.dart';

class PredictionRepositoryImpl implements IPredictionRepository {
  final Dio _dio;

  PredictionRepositoryImpl({required Dio dio}) : _dio = dio;

  String _endpoint({required bool tomatoDisease}) =>
      tomatoDisease ? '/ai/predict-tomato-disease' : '/ai/predict';

  String _normalizeClassificationWording(String message) {
    return message
        .replaceAll('prediction', 'classification')
        .replaceAll('Prediction', 'Classification');
  }

  PredictionResult _mapResponseToPredictionResult(Map<String, dynamic> data) {
    // Existing plant endpoint response
    if (data.containsKey('predictions') || data.containsKey('topPrediction')) {
      final rawPredictions = data['predictions'];
      final predictions = rawPredictions is List
          ? rawPredictions.whereType<String>().toList()
          : const <String>[];

      return PredictionResult(
        message: _normalizeClassificationWording(
          (data['message'] as String?) ??
              'Classification completed successfully.',
        ),
        filename: data['filename'] as String?,
        topPrediction: data['topPrediction'] as String?,
        predictions: predictions,
      );
    }

    // Tomato disease endpoint response
    final predictedClass = data['predicted_class']?.toString();
    final confidenceNum = data['confidence'];
    final confidence = confidenceNum is num ? confidenceNum.toDouble() : null;

    final top3Raw = data['top3'];
    final top3 = top3Raw is List ? top3Raw.whereType<Map>().toList() : const [];
    final top3Labels = top3
        .map((item) {
          final cls = item['class_name']?.toString();
          final conf = item['confidence'];
          final confPct =
              conf is num ? (conf.toDouble() * 100).toStringAsFixed(1) : null;
          if (cls == null || cls.isEmpty) return null;
          return confPct == null ? cls : '$cls ($confPct%)';
        })
        .whereType<String>()
        .toList();

    final topLabel =
        predictedClass ?? (top3Labels.isNotEmpty ? top3Labels.first : null);
    final message = confidence == null
        ? 'Tomato disease classification completed.'
        : 'Tomato disease classification completed (${(confidence * 100).toStringAsFixed(1)}% confidence).';

    return PredictionResult(
      message: message,
      filename: data['filename'] as String?,
      topPrediction: topLabel,
      predictions: top3Labels,
    );
  }

  @override
  Future<PredictionResult> generatePrediction(
    String imagePath, {
    bool tomatoDisease = false,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imagePath),
    });

    final response = await _dio.post(
      _endpoint(tomatoDisease: tomatoDisease),
      data: formData,
    );
    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Prediction response was not valid JSON.',
      );
    }
    return _mapResponseToPredictionResult(data);
  }

  @override
  Future<PredictionResult> generatePredictionFromBytes(
    Uint8List bytes, {
    String filename = 'capture.png',
    bool tomatoDisease = false,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });

    final response = await _dio.post(
      _endpoint(tomatoDisease: tomatoDisease),
      data: formData,
    );
    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Prediction response was not valid JSON.',
      );
    }
    return _mapResponseToPredictionResult(data);
  }
}
