import '../../../../app/config/api_config.dart';

/// Represents different camera sources available in the app
enum CameraSourceType {
  /// Local device cameras (front/back)
  device,

  /// Remote lab camera streams
  labStream,
}

/// A camera source configuration
class CameraSource {
  final String id;
  final String name;
  final CameraSourceType type;
  final String? streamUrl;
  final String? description;

  const CameraSource({
    required this.id,
    required this.name,
    required this.type,
    this.streamUrl,
    this.description,
  });

  bool get isLabStream => type == CameraSourceType.labStream;
  bool get isDeviceCamera => type == CameraSourceType.device;
}

/// Predefined lab camera streams
/// Uses the central environment configuration from ApiConfig.
class LabCameras {
  static final camera1 = CameraSource(
    id: 'camera1',
    name: 'Camera 1 - Main Growing Room (HLS)',
    type: CameraSourceType.labStream,
    streamUrl: ApiConfig.cameraHlsUrl('cam1/index.m3u8'),
    description: 'Best for mobile playback (MediaMTX HLS)',
  );

  static final camera1Web = CameraSource(
    id: 'camera1_web',
    name: 'Camera 1 - Web Endpoint',
    type: CameraSourceType.labStream,
    streamUrl: ApiConfig.cameraMjpegUrl('cam1/'),
    description: 'Fallback endpoint used by web dashboard',
  );

  static final lab2 = CameraSource(
    id: 'lab2',
    name: 'Lab 2 - Growing Room B (HLS)',
    type: CameraSourceType.labStream,
    streamUrl: ApiConfig.cameraHlsUrl('cam1/index.m3u8'),
    description: 'Secondary growing room with vertical farming (HLS)',
  );

  static final lab3 = CameraSource(
    id: 'lab3',
    name: 'Lab 3 - Seedling Area (HLS)',
    type: CameraSourceType.labStream,
    streamUrl: ApiConfig.cameraHlsUrl('cam3/index.m3u8'),
    description: 'Seedling propagation and germination area (HLS)',
  );

  static final lab4 = CameraSource(
    id: 'lab4',
    name: 'Lab 4 - Harvest Preparation (HLS)',
    type: CameraSourceType.labStream,
    streamUrl: ApiConfig.cameraHlsUrl('cam4/index.m3u8'),
    description: 'Post-harvest processing and packaging (HLS)',
  );

  static final allLabs = [
    camera1,
    lab2,
    lab3,
    lab4,
  ];
}
