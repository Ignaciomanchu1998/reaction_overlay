import 'package:flutter/material.dart';


class ReactionOverlayWidget extends StatefulWidget {
  /// Creates a [ReactionOverlayWidget].
  ///
  /// - [position]: The position where the overlay will be displayed.
  /// - [onDismiss]: Callback called when the overlay is closed.
  /// - [buttons]: List of buttons to be displayed in the overlay.
   ReactionOverlayWidget({
    super.key,
    required this.position,
    required this.onDismiss,
    required this.buttons,
    required this.curve,
    required this.padding,
    required this.borderRadius,
  }): assert(buttons.isNotEmpty, 'The button list cannot be empty.');

  /// Position where the overlay will be displayed.
  final Offset position;

  /// Callback called when the overlay is closed.
  final VoidCallback onDismiss;

  /// List of buttons to be displayed in the overlay.
  final List<IconButton> buttons;

  // Animation curve.
  final Curve curve;

  // Container of padding.
  final EdgeInsets padding;

  // Container of border.
  final BorderRadius borderRadius;

  @override
  State<ReactionOverlayWidget> createState() => _ReactionOverlayWidgetState();
}

class _ReactionOverlayWidgetState extends State<ReactionOverlayWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  Offset _adjustedPosition = Offset.zero;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller.
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Configure the scale animation.
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: widget.curve),
    );

    // Start the forward animation.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculatePosition();
      _animationController.forward();
    });
  }

  void _calculatePosition() {
    final screenSize = MediaQuery.of(context).size;
    double dx = widget.position.dx;
    double dy = widget.position.dy;

    // Prevent the overlay from overflowing to the right
    final overlayWidth = widget.buttons.length * 50.0; // Each button is approximately 50px
    if (dx + overlayWidth > screenSize.width) {
      dx = screenSize.width - overlayWidth - 10;
    }

    // Prevent the overlay from overflowing at the bottom
    if (dy > screenSize.height * 0.6) {
      dy -= 60; // Move it up a bit if it's too low
    }

    setState(() {
      _adjustedPosition = Offset(dx, dy);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Closes the overlay by reversing the animation and calling the [onDismiss] callback.
  void _dismiss() {
    _animationController.reverse().then((_) => widget.onDismiss());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background area to detect taps outside the modal.
        Positioned.fill(
          child: GestureDetector(
            onTap: _dismiss,
            child: Container(color: Colors.transparent),
          ),
        ),

        // Modal with buttons.
        Positioned(
          left: _adjustedPosition.dx,
          top: _adjustedPosition.dy,
          child: Material(
            color: Colors.transparent,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                );
              },
              child: _buildButtonContainer(),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the container that holds the buttons.
  Widget _buildButtonContainer() {
    return GestureDetector(
      onTap: _dismiss,
      child: Container(
        padding: widget.padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: widget.borderRadius,
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: widget.buttons.map((button) => _buildIconButton(button)).toList(),
        ),
      ),
    );
  }

  /// Builds an individual button with its associated action.
  Widget _buildIconButton(IconButton button) {
    return IconButton(
      icon: button.icon,
      onPressed: () {
        widget.onDismiss(); // Close the modal first.
        Future.delayed(const Duration(milliseconds: 200), () {
          button.onPressed?.call(); // Execute the action after a delay.
        });
      },
    );
  }
}
