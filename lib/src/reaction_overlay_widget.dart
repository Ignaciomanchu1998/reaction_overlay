import 'package:flutter/material.dart';

class ReactionOverlayWidget extends StatefulWidget {
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

  final Offset position;
  final VoidCallback onDismiss;
  final List<IconButton> buttons;
  final Curve curve;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final int maxVisibleButtons;
  final Color backgroundColor;

  @override
  State<ReactionOverlayWidget> createState() => _ReactionOverlayWidgetState();
}

class _ReactionOverlayWidgetState extends State<ReactionOverlayWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final ScrollController _scrollController;
  Offset _adjustedPosition = Offset.zero;
  bool _isAtEnd = false;

  // Constantes para el cálculo de tamaños
  static const double buttonWidth = 40.0;
  static const double buttonSpacing = 4.0;
  static const double moreButtonWidth = 45.0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: widget.curve),
    );

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculatePosition();
      _animationController.forward();
    });
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      setState(() {
        bool isAtEnd = _scrollController.offset >= _scrollController.position.maxScrollExtent - 15;
        _isAtEnd = isAtEnd;
      });
    }
  }

  double _calculateContainerWidth() {
    final totalButtons = widget.buttons.length;
    final showMoreButton = totalButtons > widget.maxVisibleButtons;
    final visibleButtons = showMoreButton ? widget.maxVisibleButtons : totalButtons;

    return (buttonWidth * visibleButtons) + (buttonSpacing * (visibleButtons - 1)) + (showMoreButton ? buttonSpacing + moreButtonWidth : 0);
  }

  void _calculatePosition() {
    final screenSize = MediaQuery.of(context).size;
    double dx = widget.position.dx;
    double dy = widget.position.dy;

    final containerWidth = _calculateContainerWidth();
    final totalPadding = widget.padding.left + widget.padding.right;
    final overlayWidth = containerWidth + totalPadding;

    if (dx + overlayWidth > screenSize.width) {
      dx = screenSize.width - overlayWidth - 8;
    }

    if (dx < 8) {
      dx = 8;
    }

    if (dy > screenSize.height * 0.6) {
      dy -= 60;
    }

    setState(() {
      _adjustedPosition = Offset(dx, dy);
    });
  }

  void _handleMoreButtonTap() {
    if (_scrollController.hasClients) {
      if (_isAtEnd) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        final nextPosition = _scrollController.offset + (buttonWidth * 3 + buttonSpacing * 2);
        _scrollController.animateTo(
          nextPosition.clamp(0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
        Positioned.fill(
          child: GestureDetector(
            onTap: _dismiss,
            child: Container(color: Colors.transparent),
          ),
        ),
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
    final showMoreButton = widget.buttons.length > widget.maxVisibleButtons;
    final containerWidth = _calculateContainerWidth();

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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: containerWidth - (showMoreButton ? moreButtonWidth + buttonSpacing : 0),
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.buttons.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(right: index < widget.buttons.length - 1 ? buttonSpacing : 0),
                    child: _buildReactionButton(widget.buttons[index]),
                  );
                }),
              ),
            ),
          ),
          if (showMoreButton) ...[
            SizedBox(width: buttonSpacing),
            _buildMoreButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildReactionButton(IconButton button) {
    return SizedBox(
      width: buttonWidth,
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
      width: moreButtonWidth,
      height: 45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          customBorder: const CircleBorder(),
          onTap: _handleMoreButtonTap,
          child: Icon(
            _isAtEnd ? Icons.replay : Icons.arrow_right_alt,
            size: 20,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}