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
/// Using university server (MediaMTX)
class LabCameras {
  // Camera 1 - preferred mobile playback endpoint (HLS)
  static const camera1 = CameraSource(
    id: 'camera1',
    name: 'Camera 1 - Main Growing Room (HLS)',
    type: CameraSourceType.labStream,
    streamUrl: 'http://10.1.10.144:8888/cam1/index.m3u8',
    description: 'Best for mobile playback (MediaMTX HLS)',
  );

  // Fallback MJPEG/web endpoint for testing
  static const camera1Web = CameraSource(
    id: 'camera1_web',
    name: 'Camera 1 - Web Endpoint',
    type: CameraSourceType.labStream,
    streamUrl: 'http://10.1.10.144:8889/cam1/',
    description: 'Fallback endpoint used by web dashboard',
  );

  // Additional camera endpoints (if you add more cameras)
  static const lab2 = CameraSource(
    id: 'lab2',
    name: 'Lab 2 - Growing Room B (HLS)',
    type: CameraSourceType.labStream,
    streamUrl: 'http://10.1.10.144:8888/cam2/index.m3u8',
    description: 'Secondary growing room with vertical farming (HLS)',
  );

  static const lab3 = CameraSource(
    id: 'lab3',
    name: 'Lab 3 - Seedling Area (HLS)',
    type: CameraSourceType.labStream,
    streamUrl: 'http://10.1.10.144:8888/cam3/index.m3u8',
    description: 'Seedling propagation and germination area (HLS)',
  );

  static const lab4 = CameraSource(
    id: 'lab4',
    name: 'Lab 4 - Harvest Preparation (HLS)',
    type: CameraSourceType.labStream,
    streamUrl: 'http://10.1.10.144:8888/cam4/index.m3u8',
    description: 'Post-harvest processing and packaging (HLS)',
  );

  // Main camera list
  static const allLabs = [
    camera1,
    camera1Web,
    lab2,
    lab3,
    lab4,
  ];
}
