import 'package:flutter/material.dart';

class FlyToCartOverlay {
  static OverlayEntry? _currentOverlay;

  static void showAnimation({
    required BuildContext context,
    required Widget itemWidget,
    required GlobalKey cartButtonKey,
    required GlobalKey sourceKey,
    VoidCallback? onComplete,
  }) {
    // Remove any existing overlay
    _currentOverlay?.remove();
    _currentOverlay = null;

    // Use a post frame callback to ensure the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? cartRenderBox =
          cartButtonKey.currentContext?.findRenderObject() as RenderBox?;
      final RenderBox? sourceRenderBox =
          sourceKey.currentContext?.findRenderObject() as RenderBox?;

      if (cartRenderBox == null || sourceRenderBox == null) {
        debugPrint('FlyToCart: RenderBox not found');
        debugPrint('Cart RenderBox: $cartRenderBox');
        debugPrint('Source RenderBox: $sourceRenderBox');
        onComplete?.call();
        return;
      }

      final cartPosition = cartRenderBox.localToGlobal(Offset.zero);
      final sourcePosition = sourceRenderBox.localToGlobal(Offset.zero);
      final sourceSize = sourceRenderBox.size;

      debugPrint('FlyToCart: Cart position: $cartPosition');
      debugPrint('FlyToCart: Source position: $sourcePosition');

      final targetOffset = Offset(
        cartPosition.dx - sourcePosition.dx - 90,
        cartPosition.dy - sourcePosition.dy - 20, // Adjust for visual alignment
      );

      _currentOverlay = OverlayEntry(
        builder: (context) => IgnorePointer(
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned(
                  left: sourcePosition.dx + (sourceSize.width / 2) - 30,
                  top: sourcePosition.dy + (sourceSize.height / 2) - 30,
                  child: FlyToCartAnimation(
                    targetPosition: targetOffset,
                    onAnimationComplete: () {
                      _currentOverlay?.remove();
                      _currentOverlay = null;
                      onComplete?.call();
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: itemWidget,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      Overlay.of(context).insert(_currentOverlay!);
    });
  }
}

class FlyToCartAnimation extends StatefulWidget {
  const FlyToCartAnimation({
    super.key,
    required this.child,
    required this.targetPosition,
    required this.onAnimationComplete,
  });

  final Widget child;
  final Offset targetPosition;
  final VoidCallback onAnimationComplete;

  @override
  State<FlyToCartAnimation> createState() => _FlyToCartAnimationState();
}

class _FlyToCartAnimationState extends State<FlyToCartAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _curveAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _curveAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInCubic),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      widget.onAnimationComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double progress = _curveAnimation.value;
        final double scale = _scaleAnimation.value;
        final double opacity = _opacityAnimation.value;

        return Transform.translate(
          offset: Offset(
            widget.targetPosition.dx * progress,
            widget.targetPosition.dy * progress,
          ),
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(scale: scale, child: widget.child),
          ),
        );
      },
    );
  }
}
