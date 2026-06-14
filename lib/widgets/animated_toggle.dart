import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedToggle extends StatelessWidget {
  const AnimatedToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutBack,
        width: 52,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: value ? AppTheme.primaryGradient : null,
          color: value ? null : AppTheme.surfaceHigh,
          border: value ? null : Border.all(color: AppTheme.border),
          boxShadow: value ? [AppTheme.glowingShadow] : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutBack,
              left: value ? 24 : 4,
              right: value ? 4 : 24,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
