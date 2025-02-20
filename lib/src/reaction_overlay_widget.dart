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
        bool isAtEnd = _scrollController.offset >= _scrollController.position.maxScrollExtent - 10;

        _isAtEnd = isAtEnd;
      });
    }
  }

  void _calculatePosition() {
    final screenSize = MediaQuery.of(context).size;
    double dx = widget.position.dx;
    double dy = widget.position.dy;

    final buttonWidth = 40.0;
    final spacing = 4.0;
    final visibleButtonsCount = widget.maxVisibleButtons;
    final totalPadding = widget.padding.left + widget.padding.right;
    final overlayWidth = (visibleButtonsCount * buttonWidth) + ((visibleButtonsCount - 1) * spacing) + totalPadding + 45; // +45 for more button

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
        // Si estamos al final, volvemos al inicio
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        // Calculamos la siguiente posición de scroll
        final nextPosition = _scrollController.offset + (40.0 * 3); // Avanzamos 3 botones
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
        children: [
          SizedBox(
            width: widget.maxVisibleButtons * 44.0, // 40 + 4 spacing
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(), // Deshabilitamos el scroll manual
              child: Row(
                children: List.generate(widget.buttons.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(right: index < widget.buttons.length - 1 ? 4 : 0),
                    child: _buildReactionButton(widget.buttons[index]),
                  );
                }),
              ),
            ),
          ),
          if (widget.buttons.length > widget.maxVisibleButtons) ...[
            const SizedBox(width: 4),
            _buildMoreButton(),
          ],
        ],
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