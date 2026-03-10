import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../app/router/app_router.dart';
import '../domain/models/camera_source.dart';
import 'package:go_router/go_router.dart';
import 'widgets/mjpeg_viewer.dart';
import 'widgets/camera_connection_test.dart';

/// Enhanced camera screen with device cameras and lab stream support.
///
/// Features:
/// - Dropdown to select camera source (Device cameras or Lab streams)
/// - Device camera preview using camera plugin
/// - Lab camera stream using video_player
/// - Modern UI with gradient buttons and animations
class CameraScreen extends StatefulWidget {
  /// Whether to show AppBar (for standalone routes) or not (for MainScaffold tabs)
  final bool showAppBar;
  
  const CameraScreen({super.key, this.showAppBar = false});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}


class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin {
  // Device cameras
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  int? _selectedDeviceCameraIndex;
  
  // Lab streams
  VideoPlayerController? _videoController;
  CameraSource? _selectedLabCamera;
  bool _isStreamPlaying = false;
  
  // UI state
  CameraSourceType _sourceType = CameraSourceType.device;
  bool _isLoading = true;
  String? _errorMessage;
  bool _showDropdown = false;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _initCameras();
  }

  /// Initialize device cameras on startup
  Future<void> _initCameras() async {
    try {
      final cameras = await availableCameras();

      if (!mounted) return;

      setState(() {
        _cameras = cameras;
        _isLoading = false;
      });

      if (cameras.isNotEmpty) {
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

  /// Select and initialize a device camera
  Future<void> _selectDeviceCamera(int index) async {
    if (index < 0 || index >= _cameras.length) return;

    final oldController = _cameraController;
    _cameraController = null;
    await oldController?.dispose();

    final description = _cameras[index];

    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );

    setState(() {
      _selectedDeviceCameraIndex = index;
      _cameraController = controller;
      _errorMessage = null;
    });

    try {
      await controller.initialize();
      if (!mounted) return;
      _animationController.forward(from: 0);
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to start camera: $e';
      });
    }
  }

  /// Select and initialize a lab camera stream
  Future<void> _selectLabCamera(CameraSource labCamera) async {
    // Dispose old video controller if any
    final oldVideoController = _videoController;
    _videoController = null;
    await oldVideoController?.dispose();

    setState(() {
      _selectedLabCamera = labCamera;
      _isStreamPlaying = true;
      _isLoading = true;
      _errorMessage = null;
    });

    final streamUrl = labCamera.streamUrl ?? '';
    final isHls = streamUrl.toLowerCase().contains('.m3u8');

    if (isHls) {
      try {
        final controller = VideoPlayerController.networkUrl(Uri.parse(streamUrl));
        _videoController = controller;
        await controller.initialize();
        await controller.setLooping(true);
        await controller.play();
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Failed to play HLS stream: $e';
        });
      }
    }

    if (!mounted) return;
    _animationController.forward(from: 0);
    setState(() {
      _isLoading = false;
    });
  }

  /// Switch between device camera and lab stream
  Future<void> _switchSourceType(CameraSourceType newType) async {
    if (_sourceType == newType) return;

    setState(() {
      _sourceType = newType;
      _showDropdown = false;
      _isLoading = true;
      _errorMessage = null;
    });

    if (newType == CameraSourceType.device) {
      // Dispose video controller
      await _videoController?.dispose();
      _videoController = null;
      _selectedLabCamera = null;

      // Reinitialize device camera
      if (_cameras.isNotEmpty && _selectedDeviceCameraIndex != null) {
        await _selectDeviceCamera(_selectedDeviceCameraIndex!);
      }
    } else {
      // Dispose camera controller
      await _cameraController?.dispose();
      _cameraController = null;
      _selectedDeviceCameraIndex = null;

      // Initialize first lab camera
      if (LabCameras.allLabs.isNotEmpty) {
        await _selectLabCamera(LabCameras.allLabs.first);
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  /// Capture photo from device camera
  Future<void> _onCapturePressed() async {
    final messenger = ScaffoldMessenger.of(context);

    if (_sourceType == CameraSourceType.device) {
      // Device camera capture
      final controller = _cameraController;
      if (controller == null || !controller.value.isInitialized) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Camera not ready')),
        );
        return;
      }

      try {
        final image = await controller.takePicture();
        messenger.showSnackBar(
          SnackBar(content: Text('Photo captured: ${image.path}')),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text('Capture failed: $e')),
        );
      }
    } else {
      // Lab stream snapshot
      messenger.showSnackBar(
        const SnackBar(content: Text('Stream snapshot feature coming soon!')),
      );
    }
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

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error.withValues(alpha: 0.7),
              ),
              const SizedBox(height: AppSizes.spacingM),
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Device camera preview
    if (_sourceType == CameraSourceType.device) {
      final controller = _cameraController;
      if (controller == null || !controller.value.isInitialized) {
        return const Center(child: Text('Initializing camera...'));
      }

      return FadeTransition(
        opacity: _fadeAnimation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: CameraPreview(controller),
          ),
        ),
      );
    }

    // Lab stream preview (HLS or MJPEG)
    if (_selectedLabCamera == null) {
      return const Center(
        child: Text('Select a lab camera from the dropdown'),
      );
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
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio == 0
                ? 16 / 9
                : controller.value.aspectRatio,
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

  Widget _buildSourceSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          onTap: () {
            setState(() {
              _showDropdown = !_showDropdown;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingL,
              vertical: AppSizes.paddingM,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingS),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Icon(
                    _sourceType == CameraSourceType.device
                        ? Icons.camera_alt
                        : Icons.stream,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSizes.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _sourceType == CameraSourceType.device
                            ? 'Device Cameras'
                            : 'Lab Streams',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (_sourceType == CameraSourceType.labStream &&
                          _selectedLabCamera != null)
                        Text(
                          _selectedLabCamera!.name,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  _showDropdown
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownMenu() {
    if (!_showDropdown) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.spacingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Device Cameras option
          ListTile(
            leading: const Icon(Icons.camera_alt, color: AppColors.primary),
            title: const Text('Device Cameras'),
            subtitle: Text('${_cameras.length} camera(s) available'),
            trailing: _sourceType == CameraSourceType.device
                ? const Icon(Icons.check_circle, color: AppColors.primary)
                : null,
            onTap: () => _switchSourceType(CameraSourceType.device),
          ),
          const Divider(height: 1),
          
          // Lab Streams header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.paddingL,
              AppSizes.paddingM,
              AppSizes.paddingL,
              AppSizes.paddingS,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'LAB CAMERA STREAMS',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
              ),
            ),
          ),
          
          // Lab cameras list
          ...LabCameras.allLabs.map((lab) {
            final isSelected = _sourceType == CameraSourceType.labStream &&
                _selectedLabCamera?.id == lab.id;
            
            return Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.videocam,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                  title: Text(lab.name),
                  subtitle: Text(
                    lab.description ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                    ),
                  ),
                  trailing: isSelected
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

  Widget _buildDeviceCameraList() {
    if (_sourceType != CameraSourceType.device) {
      return const SizedBox.shrink();
    }

    if (_cameras.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSizes.paddingL),
        child: Text('No device cameras detected.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
          child: Text(
            'Available Device Cameras',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: AppSizes.spacingS),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _cameras.length,
          itemBuilder: (context, index) {
            final camera = _cameras[index];
            final isSelected = index == _selectedDeviceCameraIndex;

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingXS,
              ),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 180),
                scale: isSelected ? 1.0 : 0.98,
                curve: Curves.easeOut,
                child: Card(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      camera.lensDirection == CameraLensDirection.front
                          ? Icons.camera_front
                          : Icons.camera_rear,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    title: Text('Camera ${index + 1}'),
                    subtitle: Text(_lensDirectionLabel(camera.lensDirection)),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppColors.primary)
                        : null,
                    onTap: () => _selectDeviceCamera(index),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStreamInfo() {
    if (_sourceType != CameraSourceType.labStream || _selectedLabCamera == null) {
      return const SizedBox.shrink();
    }

    final isPlaying = _isStreamPlaying;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isPlaying
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying ? Icons.fiber_manual_record : Icons.pause,
                  color: isPlaying ? Colors.green : Colors.grey,
                  size: 12,
                ),
              ),
              const SizedBox(width: AppSizes.spacingS),
              Text(
                isPlaying ? 'Live Stream' : 'Stream Paused',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isPlaying ? Colors.green : Colors.grey,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingS),
          Text(
            _selectedLabCamera!.name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (_selectedLabCamera!.description != null) ...[
            const SizedBox(height: AppSizes.spacingXS),
            Text(
              _selectedLabCamera!.description!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
          const SizedBox(height: AppSizes.spacingM),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isStreamPlaying = !_isStreamPlaying;
                    });

                    final controller = _videoController;
                    if (controller != null && controller.value.isInitialized) {
                      if (_isStreamPlaying) {
                        controller.play();
                      } else {
                        controller.pause();
                      }
                    }
                  },
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  label: Text(isPlaying ? 'Pause' : 'Play'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cameraController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppSizes.spacingM),
            
            // Camera source selector with dropdown
            _buildSourceSelector(),
            
            // Dropdown menu
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _buildDropdownMenu(),
            ),
            
            const SizedBox(height: AppSizes.spacingM),
            
            // Live camera/stream preview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
              child: SizedBox(
                height: 300,
                child: _buildPreview(),
              ),
            ),
            
            const SizedBox(height: AppSizes.spacingM),
            
            // Capture button (only for device cameras)
            if (_sourceType == CameraSourceType.device)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _onCapturePressed,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text(
                      'Capture Photo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingL,
                        vertical: AppSizes.paddingM,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                      ),
                      minimumSize: const Size(double.infinity, AppSizes.buttonHeightL),
                    ),
                  ),
                ),
              ),
            
            if (_sourceType == CameraSourceType.device)
              const SizedBox(height: AppSizes.spacingL),
            
            // Connection test (for lab cameras)
            if (_sourceType == CameraSourceType.labStream && _selectedLabCamera != null)
              CameraConnectionTest(url: _selectedLabCamera!.streamUrl!),
            
            // Stream info (for lab cameras)
            _buildStreamInfo(),
            
            const SizedBox(height: AppSizes.spacingL),
            
            // Device camera list (when in device mode)
            _buildDeviceCameraList(),
            
            const SizedBox(height: AppSizes.spacingXL),
          ],
        ),
      ),
    );
    
    // If showAppBar is true (standalone route), wrap in Scaffold with AppBar
    if (widget.showAppBar) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
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
    
    // If embedded in MainScaffold (showAppBar = false), return just the content
    return content;
  }
}
