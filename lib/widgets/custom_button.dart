import 'package:flutter/material.dart';
import '../utils/constants.dart';

enum ButtonVariant { primary, secondary, outline }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget buttonContent = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Text(text);

    Widget button;
    
    switch (variant) {
      case ButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: buttonContent,
        );
        break;
      case ButtonVariant.secondary:
        button = FilledButton.tonal(
          onPressed: isLoading ? null : onPressed,
          child: isLoading 
            ? const SizedBox(
                height: 20, 
                width: 20, 
                child: CircularProgressIndicator(strokeWidth: 2)
              ) 
            : Text(text),
        );
        break;
      case ButtonVariant.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: isLoading 
            ? const SizedBox(
                height: 20, 
                width: 20, 
                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary))
              ) 
            : Text(text),
        );
        break;
    }

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
