import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../app/router/app_router.dart';
import 'package:go_router/go_router.dart';

/// Camera screen that lists device cameras and shows a live preview.
///
/// Android-focused implementation using the `camera` plugin.
/// - Lists all available cameras with index and lens direction.
/// - Initializes the first camera on open and shows a live [CameraPreview].
/// - Allows switching cameras by tapping an item in the list.
/// - Provides a "Capture" button (placeholder for now).
/// - Includes fade-in animation for the preview and subtle scaling for list items.
class CameraScreen extends StatefulWidget {
  /// Whether to show AppBar (for standalone routes) or not (for MainScaffold tabs)
  final bool showAppBar;
  
  const CameraScreen({super.key, this.showAppBar = false});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int? _selectedCameraIndex;
  bool _isLoadingCameras = true;
  String? _errorMessage;

  late final AnimationController _previewAnimationController;
  late final Animation<double> _previewFadeAnimation;

  @override
  void initState() {
    super.initState();

    _previewAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _previewFadeAnimation = CurvedAnimation(
      parent: _previewAnimationController,
      curve: Curves.easeIn,
    );

    _initCameras();
  }

  /// Dispose the camera controller and attempt to close this screen.
  /// Only works when used as a separate route, not when embedded in MainScaffold.
  void _closeCameraScreen() {
    // Controller will also be disposed in [dispose], but we null it here so
    // we stop using it immediately after closing.
    _controller?.dispose();
    _controller = null;
    // Only pop if we're in a navigator stack (not when embedded in MainScaffold)
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      // When opened via GoRouter (MainScaffold -> context.go), there may be
      // no Navigator stack to pop. Use GoRouter to navigate back to home.
      context.go(AppRouter.home);
    }
  }

  /// Discover available cameras on the device and initialize the first one.
  Future<void> _initCameras() async {
    try {
      final cameras = await availableCameras();

      if (!mounted) return;

      setState(() {
        _cameras = cameras;
        _isLoadingCameras = false;
      });

      if (cameras.isNotEmpty) {
        // Initialize first camera as default.
        await _selectCamera(0);
      } else {
        setState(() {
          _errorMessage = 'No cameras available on this device.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingCameras = false;
        _errorMessage = 'Failed to initialize cameras: $e';
      });
    }
  }

  /// Initialize the [CameraController] for the camera at [index].
  Future<void> _selectCamera(int index) async {
    if (index < 0 || index >= _cameras.length) return;

    // Dispose any existing controller before creating a new one.
    final oldController = _controller;
    _controller = null;
    await oldController?.dispose();

    final description = _cameras[index];

    final controller = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: false, // For still image capture / AI processing only.
    );

    setState(() {
      _selectedCameraIndex = index;
      _controller = controller;
      _errorMessage = null;
    });

    try {
      await controller.initialize();
      if (!mounted) return;
      _previewAnimationController.forward(from: 0);
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to start camera: $e';
      });
    }
  }

  /// Placeholder capture action for future AI/ML integration.
  Future<void> _onCapturePressed() async {
    final messenger = ScaffoldMessenger.of(context);

    // In the future, this is where image capture and
    // AI processing (e.g., sending frames to a model) will live.
    messenger.showSnackBar(
      const SnackBar(content: Text('Capture feature coming soon!')),
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
    if (_isLoadingCameras) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: Text('Initializing camera...'));
    }

    return FadeTransition(
      opacity: _previewFadeAnimation,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  Widget _buildCameraList() {
    if (_cameras.isEmpty && !_isLoadingCameras) {
      return const Padding(
        padding: EdgeInsets.all(AppSizes.paddingL),
        child: Text('No cameras detected on this device.'),
      );
    }

    return ListView.builder(
      itemCount: _cameras.length,
      itemBuilder: (context, index) {
        final camera = _cameras[index];
        final isSelected = index == _selectedCameraIndex;

        return AnimatedScale(
          duration: const Duration(milliseconds: 180),
          scale: isSelected ? 1.02 : 1.0,
          curve: Curves.easeOut,
          child: Card(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: ListTile(
              leading: Icon(
                camera.lensDirection == CameraLensDirection.front
                    ? Icons.camera_front
                    : Icons.camera_rear,
                color: AppColors.primary,
              ),
              title: Text('Camera ${index + 1}'),
              subtitle: Text(_lensDirectionLabel(camera.lensDirection)),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              onTap: () => _selectCamera(index),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _previewAnimationController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = SafeArea(
        child: Column(
          children: [
            // Live camera preview section.
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: SizedBox(
                height: 260,
                child: _buildPreview(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _onCapturePressed,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text(
                          'Capture',
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
                            vertical: AppSizes.paddingL,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                          ),
                          minimumSize: const Size(double.infinity, AppSizes.buttonHeightL),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Available cameras',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingS),
            // Camera list below preview.
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                child: _buildCameraList(),
              ),
            ),
          ],
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
            onPressed: _closeCameraScreen,
          ),
        ),
        body: content,
      );
    }
    
    // If embedded in MainScaffold (showAppBar = false), return just the content (no Scaffold)
    return content;
  }
}
