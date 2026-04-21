import 'package:flutter_test/flutter_test.dart';
import 'package:diploma_mobile_app/app/config/api_config.dart';

void main() {
  group('ApiConfig', () {
    test('baseUrl has expected api suffix', () {
      expect(ApiConfig.baseUrl.endsWith('/api'), isTrue);
    });

    test('camera URL builders append stream path', () {
      const streamPath = 'live/stream.m3u8';

      final hlsUrl = ApiConfig.cameraHlsUrl(streamPath);
      final mjpegUrl = ApiConfig.cameraMjpegUrl(streamPath);

      expect(hlsUrl.endsWith('/$streamPath'), isTrue);
      expect(mjpegUrl.endsWith('/$streamPath'), isTrue);
    });
  });
}
