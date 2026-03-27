import 'dart:async';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../app/di/injector.dart';
import '../../../app/router/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../ai/domain/entities/prediction_result.dart';
import '../../ai/domain/usecases/generate_prediction_use_case.dart';
import '../domain/models/camera_source.dart';
import 'widgets/camera_connection_test.dart';
import 'widgets/mjpeg_viewer.dart';
import 'widgets/stream_webview.dart';

class CameraScreen extends StatefulWidget {
  final bool showAppBar;

  const CameraScreen({super.key, this.showAppBar = false});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _hlsInitTimeout = Duration(seconds: 6);
  static const int _maxHlsAutoRetries = 2;

  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  int? _selectedDeviceCameraIndex;

  VideoPlayerController? _videoController;
  CameraSource? _selectedLabCamera;
  bool _isStreamPlaying = false;
  Timer? _hlsRetryTimer;
  int _hlsRetryAttempt = 0;
  String? _webFallbackUrl;

  CameraSourceType _sourceType = CameraSourceType.device;
  bool _isLoading = true;
  bool _isPredicting = false;
  String? _errorMessage;
  bool _showDropdown = false;
  PredictionResult? _predictionResult;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final GeneratePredictionUseCase _generatePredictionUseCase;

  @override
  void initState() {
    super.initState();
    _generatePredictionUseCase = getIt<GeneratePredictionUseCase>();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _initCameras();
  }

  Future<void> _initCameras() async {
    try {
      final cameras = await availableCameras();
      // Some phones expose extra logical cameras (3rd/4th). Keep UI simple:
      // show the first two only (typically back + front).
      final visibleCameras = cameras.length > 2 ? cameras.take(2).toList() : cameras;
      if (!mounted) return;

      setState(() {
        _cameras = visibleCameras;
        _isLoading = false;
      });

      if (visibleCameras.isNotEmpty) {
        await _selectDeviceCamera(0);
      } else {
        setState(() {
          _errorMessage = 'No device cameras available.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to initialize cameras: $e';
      });
    }
  }

  Future<void> _selectDeviceCamera(int index) async {
    if (index < 0 || index >= _cameras.length) return;

    final oldController = _cameraController;
    _cameraController = null;
    await oldController?.dispose();

    final controller = CameraController(
      _cameras[index],
      ResolutionPreset.high,
      enableAudio: false,
    );

    setState(() {
      _selectedDeviceCameraIndex = index;
      _cameraController = controller;
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      await controller.initialize();
      if (!mounted) return;
      _animationController.forward(from: 0);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to start camera: $e';
      });
    }
  }

  Future<void> _selectLabCamera(CameraSource labCamera) async {
    _hlsRetryTimer?.cancel();

    final oldVideoController = _videoController;
    _videoController = null;
    await oldVideoController?.dispose();

    setState(() {
      _selectedLabCamera = labCamera;
      _isStreamPlaying = true;
      _isLoading = true;
      _errorMessage = null;
      _webFallbackUrl = null;
    });

    final streamUrl = _normalizeLabStreamUrl(labCamera.streamUrl ?? '');
    final isHls = streamUrl.toLowerCase().contains('.m3u8');

    if (isHls) {
      try {
        // Single VideoPlayer init per candidate. (Previously we probed each URL with a
        // full initialize()+dispose, then initialized again — that doubled HLS startup time.)
        final candidates = _hlsFallbackCandidates(streamUrl);
        Object? lastError;
        for (final candidate in candidates) {
          VideoPlayerController? controller;
          try {
            controller = VideoPlayerController.networkUrl(Uri.parse(candidate));
            await controller.initialize().timeout(_hlsInitTimeout);
            await controller.setLooping(true);
            await controller.play();
            _videoController = controller;
            _hlsRetryTimer?.cancel();
            _hlsRetryAttempt = 0;
            break;
          } catch (e) {
            lastError = e;
            await controller?.dispose();
          }
        }
        if (_videoController == null) {
          throw StateError('No playable HLS URL. $lastError');
        }
      } catch (e) {
        if (!mounted) return;
        final webFallbackUrl = _toWebStreamUrl(streamUrl);
        setState(() {
          _errorMessage = 'Failed to play HLS stream: $e';
          _webFallbackUrl = webFallbackUrl;
        });
        _scheduleHlsRetry(labCamera);
      }
    }

    if (!mounted) return;
    _animationController.forward(from: 0);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _switchSourceType(CameraSourceType newType) async {
    if (_sourceType == newType) return;

    _hlsRetryTimer?.cancel();

    setState(() {
      _sourceType = newType;
      _showDropdown = false;
      _isLoading = true;
      _errorMessage = null;
      _webFallbackUrl = null;
    });

    if (newType == CameraSourceType.device) {
      await _videoController?.dispose();
      _videoController = null;
      _selectedLabCamera = null;

      if (_cameras.isNotEmpty) {
        await _selectDeviceCamera(_selectedDeviceCameraIndex ?? 0);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No device cameras available.';
        });
      }
      return;
    }

    await _cameraController?.dispose();
    _cameraController = null;
    _selectedDeviceCameraIndex = null;

    if (LabCameras.allLabs.isNotEmpty) {
      await _selectLabCamera(LabCameras.allLabs.first);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No lab streams configured.';
      });
    }
  }

  String _normalizeLabStreamUrl(String streamUrl) {
    final lower = streamUrl.toLowerCase();
    if (lower.contains('.m3u8')) return streamUrl;

    final uri = Uri.tryParse(streamUrl);
    if (uri == null) return streamUrl;

    // MediaMTX HLS commonly serves playlist as <path>/index.m3u8 on port 8888.
    if (uri.port == 8888) {
      final hasTrailingSlash = streamUrl.endsWith('/');
      final base = hasTrailingSlash ? streamUrl : '$streamUrl/';
      return '${base}index.m3u8';
    }

    return streamUrl;
  }

  List<String> _hlsFallbackCandidates(String streamUrl) {
    final candidates = <String>{streamUrl};

    final uri = Uri.tryParse(streamUrl);
    if (uri == null) return candidates.toList();

    final segments = uri.pathSegments;
    if (segments.length < 2) return candidates.toList();

    final pathSegment = segments.first;
    final playlist = segments.last;
    if (!playlist.toLowerCase().endsWith('.m3u8')) return candidates.toList();

    final toggledSegment = pathSegment.endsWith('_ai')
        ? pathSegment.substring(0, pathSegment.length - 3)
        : '${pathSegment}_ai';

    final toggledUri = uri.replace(
      pathSegments: [toggledSegment, ...segments.skip(1)],
    );
    candidates.add(toggledUri.toString());

    return candidates.toList();
  }

  String? _toWebStreamUrl(String streamUrl) {
    final uri = Uri.tryParse(streamUrl);
    if (uri == null) return null;

    final segments = uri.pathSegments;
    if (segments.isEmpty) return null;

    final streamPath = segments.first;
    return 'http://${uri.host}:8889/$streamPath';
  }

  void _scheduleHlsRetry(CameraSource labCamera) {
    // Avoid infinite reconnect loops that make stream appear unstable.
    if (_hlsRetryAttempt >= _maxHlsAutoRetries) return;

    _hlsRetryTimer?.cancel();
    _hlsRetryAttempt += 1;

    final seconds = _hlsRetryAttempt <= 3 ? 2 : 5;
    _hlsRetryTimer = Timer(Duration(seconds: seconds), () {
      if (!mounted) return;
      if (_sourceType != CameraSourceType.labStream) return;
      if (_selectedLabCamera?.id != labCamera.id) return;
      _selectLabCamera(labCamera);
    });
  }

  Future<void> _onCapturePressed() async {
    final messenger = ScaffoldMessenger.of(context);

    if (_sourceType == CameraSourceType.device) {
      final controller = _cameraController;
      if (controller == null || !controller.value.isInitialized) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Camera is not ready yet.')),
        );
        return;
      }

      try {
        final image = await controller.takePicture();
        if (!mounted) return;

        setState(() {
          _isPredicting = true;
          _predictionResult = null;
        });

        final result = await _generatePredictionUseCase(image.path);
        if (!mounted) return;

        setState(() {
          _predictionResult = result;
        });

        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Prediction Result'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Top prediction: ${result.topPrediction ?? 'No result'}'),
                if (result.predictions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Detections: ${result.predictions.join(', ')}'),
                ],
                const SizedBox(height: 8),
                Text(result.message),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } on DioException catch (e) {
        if (!mounted) return;
        final errorMessage = _formatPredictionError(e);
        messenger.showSnackBar(SnackBar(content: Text(errorMessage)));
      } catch (e) {
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Capture completed, but prediction failed. Please try again.',
            ),
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isPredicting = false;
          });
        }
      }
      return;
    }

    messenger.showSnackBar(
      const SnackBar(content: Text('Stream snapshot will be available soon.')),
    );
  }

  String _lensDirectionLabel(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return 'Back camera';
      case CameraLensDirection.front:
        return 'Front camera';
      case CameraLensDirection.external:
        return 'External camera';
    }
  }

  Widget _buildPreview() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_sourceType == CameraSourceType.labStream && _webFallbackUrl != null) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: StreamWebView(url: _webFallbackUrl!),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 56,
                color: AppColors.error.withValues(alpha: 0.78),
              ),
              const SizedBox(height: AppSizes.spacingM),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error),
              ),
            ],
          ),
        ),
      );
    }

    if (_sourceType == CameraSourceType.device) {
      final controller = _cameraController;
      if (controller == null || !controller.value.isInitialized) {
        return const Center(child: Text('Initializing camera...'));
      }

      return FadeTransition(
        opacity: _fadeAnimation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: CameraPreview(controller),
        ),
      );
    }

    if (_selectedLabCamera == null) {
      return const Center(child: Text('Select a stream to begin.'));
    }

    final streamUrl = _selectedLabCamera!.streamUrl ?? '';
    final isHls = streamUrl.toLowerCase().contains('.m3u8');

    if (isHls) {
      final controller = _videoController;
      if (controller == null || !controller.value.isInitialized) {
        return const Center(child: Text('Initializing HLS stream...'));
      }

      return FadeTransition(
        opacity: _fadeAnimation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio:
                controller.value.aspectRatio == 0 ? 16 / 9 : controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: MjpegViewer(
        streamUrl: streamUrl,
        isPlaying: _isStreamPlaying,
      ),
    );
  }

  Widget _buildPageHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingL,
        AppSizes.paddingL,
        AppSizes.paddingL,
        AppSizes.paddingM,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.device_hub_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSizes.spacingM),
          Expanded(
            child: Text(
              'DEVICE CAMERAS & STREAMS',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: AppColors.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceAndSelectionCard() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final card = isDark ? theme.colorScheme.surfaceContainerHigh : Colors.white;
    final border = isDark ? theme.colorScheme.outlineVariant : const Color(0xFF5A8A5A);

    final selectedTitle = _sourceType == CameraSourceType.device
        ? (_selectedDeviceCameraIndex != null
            ? 'Camera ${_selectedDeviceCameraIndex! + 1}'
            : 'Device camera')
        : (_selectedLabCamera?.name ?? 'Lab stream');

    final selectedSubtitle = _sourceType == CameraSourceType.device
        ? (_selectedDeviceCameraIndex != null
            ? _lensDirectionLabel(_cameras[_selectedDeviceCameraIndex!].lensDirection)
            : '${_cameras.length} camera(s) available')
        : (_selectedLabCamera?.description ?? 'Remote stream source');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              setState(() {
                _showDropdown = !_showDropdown;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Row(
                children: [
                  Icon(
                    _sourceType == CameraSourceType.device
                        ? Icons.videocam_outlined
                        : Icons.stream_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSizes.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _sourceType == CameraSourceType.device
                              ? 'CAMERAS'
                              : 'LAB STREAMS',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          selectedTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Text(
                          selectedSubtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _showDropdown ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeInOut,
            child: _showDropdown ? _buildDropdownOptions() : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownOptions() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? theme.colorScheme.outlineVariant : const Color(0xFFD4E1D0),
          ),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.phone_android, color: AppColors.primary),
            title: const Text('Device Cameras'),
            subtitle: Text('${_cameras.length} available'),
            trailing: _sourceType == CameraSourceType.device
                ? const Icon(Icons.check_circle, color: AppColors.primary)
                : null,
            onTap: () => _switchSourceType(CameraSourceType.device),
          ),
          const Divider(height: 1),
          ...LabCameras.allLabs.map((lab) {
            final selected = _sourceType == CameraSourceType.labStream &&
                _selectedLabCamera?.id == lab.id;
            return Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.videocam,
                    color: selected ? AppColors.primary : AppColors.textSecondary,
                  ),
                  title: Text(lab.name),
                  subtitle: Text(
                    lab.description ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  trailing: selected
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  onTap: () async {
                    if (_sourceType != CameraSourceType.labStream) {
                      await _switchSourceType(CameraSourceType.labStream);
                    }
                    await _selectLabCamera(lab);
                  },
                ),
                if (lab != LabCameras.allLabs.last)
                  const Divider(height: 1, indent: 56),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSizes.paddingL,
        AppSizes.paddingM,
        AppSizes.paddingL,
        0,
      ),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceContainerHigh : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: _buildPreview(),
        ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    final deviceReady = _sourceType == CameraSourceType.device &&
        _cameraController != null &&
        _cameraController!.value.isInitialized &&
        !_isLoading &&
        !_isPredicting;

    final isEnabled = deviceReady || _sourceType == CameraSourceType.labStream;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingL,
        AppSizes.paddingL,
        AppSizes.paddingL,
        0,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isEnabled
                ? const [Color(0xFF2E7D32), Color(0xFF1B5E20)]
                : const [Color(0xFF9FB09F), Color(0xFF8A9A8A)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B5E20).withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: isEnabled ? _onCapturePressed : null,
          icon: _isPredicting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.camera_alt_rounded),
          label: Text(
            _isPredicting
                ? 'PROCESSING...'
                : _sourceType == CameraSourceType.device
                    ? 'CAPTURE & PREDICT'
                    : 'SNAPSHOT (SOON)',
            style: const TextStyle(
              letterSpacing: 0.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.transparent,
            disabledForegroundColor: Colors.white70,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionResultCard() {
    final result = _predictionResult;
    if (result == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSizes.paddingL,
        AppSizes.paddingL,
        AppSizes.paddingL,
        0,
      ),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceContainerHigh : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI PREDICTION',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSizes.spacingS),
          Text(
            result.topPrediction ?? 'No object detected',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (result.filename != null && result.filename!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.spacingXS),
            Text(
              'Image: ${result.filename}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (result.predictions.isNotEmpty) ...[
            const SizedBox(height: AppSizes.spacingS),
            Text(
              'Detections: ${result.predictions.join(', ')}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: AppSizes.spacingS),
          Text(
            result.message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCameraSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    if (_sourceType != CameraSourceType.device) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSizes.paddingL,
        AppSizes.paddingL,
        AppSizes.paddingL,
        0,
      ),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceContainerHigh : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DEVICE CAMERAS',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: AppSizes.spacingS),
          if (_cameras.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: AppSizes.spacingS),
              child: Text('No device cameras detected.'),
            )
          else
            ...List.generate(_cameras.length, (index) {
              final selected = index == _selectedDeviceCameraIndex;
              final camera = _cameras[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  camera.lensDirection == CameraLensDirection.front
                      ? Icons.camera_front
                      : Icons.camera_rear,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
                title: Text('Camera ${index + 1}'),
                subtitle: Text(_lensDirectionLabel(camera.lensDirection)),
                trailing: selected
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () => _selectDeviceCamera(index),
              );
            }),
        ],
      ),
    );
  }

  String _formatPredictionError(DioException exception) {
    final responseData = exception.response?.data;

    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
      final detail = responseData['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail.trim();
      }
    }

    if (exception.type == DioExceptionType.connectionError ||
        exception.type == DioExceptionType.connectionTimeout) {
      return 'Unable to reach backend. Check backend and AI service are running.';
    }

    return 'Prediction failed. Please try again.';
  }

  Widget _buildLabStreamsSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    if (_sourceType != CameraSourceType.labStream) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSizes.paddingL,
        AppSizes.paddingL,
        AppSizes.paddingL,
        0,
      ),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceContainerHigh : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LAB CAMERA STREAMS',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: AppSizes.spacingS),
          ...LabCameras.allLabs.map((lab) {
            final selected = _selectedLabCamera?.id == lab.id;
            return Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.videocam, color: AppColors.primary),
                  title: Text(lab.name),
                  subtitle: Text(
                    lab.description ?? '',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  trailing: selected
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  onTap: () => _selectLabCamera(lab),
                ),
                if (lab != LabCameras.allLabs.last) const Divider(height: 1),
              ],
            );
          }),
          const SizedBox(height: AppSizes.spacingM),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final controller = _videoController;
                    if (controller == null || !controller.value.isInitialized) {
                      return;
                    }
                    setState(() {
                      _isStreamPlaying = !_isStreamPlaying;
                    });
                    if (_isStreamPlaying) {
                      controller.play();
                    } else {
                      controller.pause();
                    }
                  },
                  icon: Icon(_isStreamPlaying ? Icons.pause : Icons.play_arrow),
                  label: Text(_isStreamPlaying ? 'Pause stream' : 'Play stream'),
                ),
              ),
            ],
          ),
          if (_selectedLabCamera?.streamUrl != null) ...[
            const SizedBox(height: AppSizes.spacingM),
            CameraConnectionTest(url: _selectedLabCamera!.streamUrl!),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final content = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF102116), Color(0xFF0A180F)]
              : const [Color(0xFFF6F9F0), Color(0xFFEEF4E8)],
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            _buildPageHeader(),
            _buildSourceAndSelectionCard(),
            _buildPreviewCard(),
            _buildCaptureButton(),
            _buildPredictionResultCard(),
            _buildLabStreamsSection(),
            _buildDeviceCameraSection(),
            const SizedBox(height: AppSizes.spacingXL),
          ],
        ),
      ),
    );

    if (widget.showAppBar) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Camera'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _cameraController?.dispose();
              _videoController?.dispose();
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go(AppRouter.home);
              }
            },
          ),
        ),
        body: content,
      );
    }

    return content;
  }

  @override
  void dispose() {
    _hlsRetryTimer?.cancel();
    _animationController.dispose();
    _cameraController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }
}
