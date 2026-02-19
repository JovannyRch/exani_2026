import 'package:flutter/material.dart';
import 'package:exani/theme/app_theme.dart';

/// Professional loading indicators inspired by Duolingo
///
/// Usage examples:
///
/// 1. Simple bouncing dots loader (default):
/// ```dart
/// AppLoader(message: 'Cargando...')
/// ```
///
/// 2. Full-screen overlay with backdrop:
/// ```dart
/// AppLoading.show(context, message: 'Processing...');
/// // Later...
/// AppLoading.hide(context);
/// ```
///
/// 3. Pulsing loader:
/// ```dart
/// AppPulseLoader(message: 'Preparing...')
/// ```
///
/// 4. Material-style spinner:
/// ```dart
/// AppSpinnerLoader(message: 'Loading data...')
/// ```
///
/// All loaders support:
/// - Custom message (optional)
/// - Custom color (optional, defaults to AppColors.primary)
/// - Custom size (optional)

/// Professional loading indicator inspired by Duolingo
/// Uses staggered bouncing dots animation with color transitions
class AppLoader extends StatefulWidget {
  final String? message;
  final Color? color;
  final double size;

  const AppLoader({super.key, this.message, this.color, this.size = 60});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();

    // Create staggered animations for 3 dots
    _dotAnimations = List.generate(3, (index) {
      final start = index * 0.2; // 200ms delay between each dot
      final end = start + 0.4; // 400ms animation duration

      return TweenSequence([
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 0.0,
            end: -20.0,
          ).chain(CurveTween(curve: Curves.easeOut)),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween<double>(
            begin: -20.0,
            end: 0.0,
          ).chain(CurveTween(curve: Curves.easeIn)),
          weight: 50,
        ),
      ]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouncing dots
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _dotAnimations[index],
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _dotAnimations[index].value),
                      child: Container(
                        width: widget.size * 0.2,
                        height: widget.size * 0.2,
                        margin: EdgeInsets.symmetric(
                          horizontal: widget.size * 0.05,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),

          // Optional message
          if (widget.message != null) ...[
            const SizedBox(height: 16),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Text(
                    widget.message!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Full-screen overlay loader with backdrop
class AppLoaderOverlay extends StatelessWidget {
  final String? message;
  final Color? color;
  final bool dismissible;

  const AppLoaderOverlay({
    super.key,
    this.message,
    this.color,
    this.dismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: dismissible,
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: AppLoader(message: message, color: color),
          ),
        ),
      ),
    );
  }
}

/// Pulsing loader with circular progress
class AppPulseLoader extends StatefulWidget {
  final String? message;
  final Color? color;
  final double size;

  const AppPulseLoader({super.key, this.message, this.color, this.size = 80});

  @override
  State<AppPulseLoader> createState() => _AppPulseLoaderState();
}

class _AppPulseLoaderState extends State<AppPulseLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulsing ring
                    Opacity(
                      opacity: _opacityAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: widget.size,
                          height: widget.size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: color, width: 3),
                          ),
                        ),
                      ),
                    ),
                    // Inner solid circle
                    Container(
                      width: widget.size * 0.5,
                      height: widget.size * 0.5,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 24),
            Text(
              widget.message!,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Spinner with rotating arcs (Material style)
class AppSpinnerLoader extends StatefulWidget {
  final String? message;
  final Color? color;
  final double size;
  final double strokeWidth;

  const AppSpinnerLoader({
    super.key,
    this.message,
    this.color,
    this.size = 48,
    this.strokeWidth = 4,
  });

  @override
  State<AppSpinnerLoader> createState() => _AppSpinnerLoaderState();
}

class _AppSpinnerLoaderState extends State<AppSpinnerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: CircularProgressIndicator(
              strokeWidth: widget.strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.message!,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Helper class to show/hide loaders easily
class AppLoading {
  /// Show a full-screen loader overlay
  static void show(
    BuildContext context, {
    String? message,
    Color? color,
    bool dismissible = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: dismissible,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder:
          (_) => AppLoaderOverlay(
            message: message,
            color: color,
            dismissible: dismissible,
          ),
    );
  }

  /// Hide the current loader overlay
  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
