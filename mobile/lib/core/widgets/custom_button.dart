import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Custom button widget with primary and secondary styles, hover effects, and onPressed callback
class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonStyle style;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final double? elevation;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = CustomButtonStyle.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.width,
    this.height,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.elevation,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = _getTextStyle();
    final contentColor = _getContentColor();

    Widget child = widget.isLoading
        ? SizedBox(
            height: AppSizes.iconM,
            width: AppSizes.iconM,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(contentColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: AppSizes.iconS,
                  color: contentColor,
                ),
                const SizedBox(width: AppSizes.spacingS),
              ],
              Text(
                widget.text,
                style: textStyle,
              ),
            ],
          );

    final button = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _scaleController.forward();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _scaleController.reverse();
          if (widget.onPressed != null && !widget.isLoading) {
            widget.onPressed!();
          }
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _scaleController.reverse();
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: widget.style == CustomButtonStyle.primary
                  ? AppColors.primaryGradient
                  : null,
              color: widget.style == CustomButtonStyle.primary
                  ? null
                  : _getBackgroundColor(),
              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
              border: _getBorder(),
              boxShadow: _getBoxShadow(),
            ),
            padding: widget.padding ??
                EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingL,
                  vertical: AppSizes.paddingL,
                ),
            child: child,
          ),
        ),
      ),
    );

    if (widget.isFullWidth && widget.width == null) {
      return SizedBox(
        width: double.infinity,
        height: widget.height ?? AppSizes.buttonHeightM,
        child: button,
      );
    }

    if (widget.width != null || widget.height != null) {
      return SizedBox(
        width: widget.width,
        height: widget.height ?? AppSizes.buttonHeightM,
        child: button,
      );
    }

    return button;
  }

  Color _getBackgroundColor() {
    if (widget.isLoading || widget.onPressed == null) {
      return _getDisabledColor();
    }

    final baseColor = widget.backgroundColor ?? _getStyleBackgroundColor();
    
    if (_isPressed) {
      return _darkenColor(baseColor, 0.1);
    }
    
    if (_isHovered) {
      return _lightenColor(baseColor, 0.05);
    }

    return baseColor;
  }

  Color _getStyleBackgroundColor() {
    switch (widget.style) {
      case CustomButtonStyle.primary:
        return AppColors.primary;
      case CustomButtonStyle.secondary:
        return AppColors.secondary;
    }
  }

  Color _getDisabledColor() {
    switch (widget.style) {
      case CustomButtonStyle.primary:
        return AppColors.primary.withOpacity(0.5);
      case CustomButtonStyle.secondary:
        return AppColors.secondary.withOpacity(0.5);
    }
  }

  Border? _getBorder() {
    if (widget.style == CustomButtonStyle.secondary) {
      return Border.all(
        color: widget.backgroundColor ?? AppColors.secondary,
        width: 1.5,
      );
    }
    return null;
  }

  List<BoxShadow>? _getBoxShadow() {
    if (widget.onPressed == null || widget.isLoading) {
      return null;
    }

    final elevation = widget.elevation ?? (_isHovered ? 6.0 : 2.0);
    
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: elevation,
        offset: Offset(0, elevation / 2),
      ),
    ];
  }

  TextStyle _getTextStyle() {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: _getContentColor(),
      letterSpacing: 0.5,
    );
  }

  Color _getContentColor() {
    if (widget.textColor != null) return widget.textColor!;
    
    if (widget.onPressed == null || widget.isLoading) {
      return AppColors.textOnPrimary.withOpacity(0.7);
    }

    switch (widget.style) {
      case CustomButtonStyle.primary:
      case CustomButtonStyle.secondary:
        return AppColors.textOnPrimary;
    }
  }

  Color _darkenColor(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Color _lightenColor(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
}

/// Button style enum for CustomButton
enum CustomButtonStyle {
  primary,
  secondary,
}

