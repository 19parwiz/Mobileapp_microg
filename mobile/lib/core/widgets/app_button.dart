import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

enum AppButtonType { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.width,
    this.height,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final textStyle = _getTextStyle();
    final contentColor = _getContentColor();

    Widget child = isLoading
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
              if (icon != null) ...[
                Icon(icon, size: AppSizes.iconS, color: contentColor),
                const SizedBox(width: AppSizes.spacingS),
              ],
              Text(
                text,
                style: textStyle,
              ),
            ],
          );

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle,
      child: child,
    );

    if (isFullWidth && width == null) {
      return SizedBox(
        width: double.infinity,
        height: height ?? AppSizes.buttonHeightM,
        child: button,
      );
    }

    if (width != null || height != null) {
      return SizedBox(
        width: width,
        height: height ?? AppSizes.buttonHeightM,
        child: button,
      );
    }

    return button;
  }

  ButtonStyle _getButtonStyle() {
    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: textColor ?? AppColors.textOnPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          elevation: 2,
        );
      case AppButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.secondary,
          foregroundColor: textColor ?? AppColors.textOnPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          elevation: 2,
        );
      case AppButtonType.outline:
        return OutlinedButton.styleFrom(
          foregroundColor: textColor ?? AppColors.primary,
          side: BorderSide(
            color: backgroundColor ?? AppColors.primary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
        );
      case AppButtonType.text:
        return TextButton.styleFrom(
          foregroundColor: textColor ?? AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
        );
    }
  }

  TextStyle _getTextStyle() {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: _getContentColor(),
    );
  }

  Color _getContentColor() {
    if (textColor != null) return textColor!;
    
    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.secondary:
        return AppColors.textOnPrimary;
      case AppButtonType.outline:
      case AppButtonType.text:
        return AppColors.primary;
    }
  }
}

