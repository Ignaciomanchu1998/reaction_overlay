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
    this.maxVisibleButtons = 6,
    this.backgroundColor = const Color(0xFFFAFAFA),
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

  // Maximum number of visible buttons before showing "more" button
  final int maxVisibleButtons;

  // Background color of the container
  final Color backgroundColor;

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

    // Calculate total width including visible buttons and more button if needed
    final buttonWidth = 40.0;
    final spacing = 4.0;
    final visibleButtonsCount = widget.buttons.length > widget.maxVisibleButtons  ? widget.maxVisibleButtons + 1 : widget.buttons.length;
    final totalPadding = widget.padding.left + widget.padding.right;
    final overlayWidth = (visibleButtonsCount * buttonWidth) + ((visibleButtonsCount - 1) * spacing) + totalPadding;

    // Prevent the overlay from overflowing to the right
    if (dx + overlayWidth > screenSize.width) {
      dx = screenSize.width - overlayWidth - 8;
    }

    // Ensure it doesn't overflow to the left
    if (dx < 8) {
      dx = 8;
    }

    // Prevent the overlay from overflowing at the bottom
    if (dy > screenSize.height * 0.6) {
      dy -= 60;
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

  Widget _buildButtonContainer() {
    List<Widget> visibleButtons = [];

    // Add visible buttons
    for (int i = 0; i < widget.maxVisibleButtons && i < widget.buttons.length; i++) {
      if (i > 0) {
        visibleButtons.add(const SizedBox(width: 4));
      }
      visibleButtons.add(_buildReactionButton(widget.buttons[i]));
    }

    // Add more button if needed
    if (widget.buttons.length > widget.maxVisibleButtons) {
      visibleButtons.add(const SizedBox(width: 4));
      visibleButtons.add(_buildMoreButton());
    }

    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: widget.borderRadius,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: visibleButtons,
      ),
    );
  }

  Widget _buildReactionButton(IconButton button) {
    return SizedBox(
      width: 40,
      height: 45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            widget.onDismiss();
            Future.delayed(const Duration(milliseconds: 200), () {
              button.onPressed?.call();
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: button.icon,
          ),
        ),
      ),
    );
  }

  Widget _buildMoreButton() {
    return SizedBox(
      width: 45,
      height: 45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          customBorder: const CircleBorder(),
          onTap: () {},
          child: const Icon(
            Icons.arrow_right_alt,
            size: 20,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}