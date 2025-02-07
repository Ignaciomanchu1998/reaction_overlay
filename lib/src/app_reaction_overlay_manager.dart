import 'package:flutter/material.dart';

import 'reaction_overlay_widget.dart';

/// Manages the reaction overlay component.
class AppReactionOverlayManager {
  OverlayEntry? _overlayEntry;

  /// Displays a reaction overlay at a specific position on the screen.
  void showReactionOverlay({
    required BuildContext context,
    required Map<int, GlobalKey> itemKeys,
    required int itemId,
    required List<IconButton> buttons,
    Curve? curve,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
  }) {
    if (!_isMessageValid(itemKeys, itemId)) return;

    _removeOverlay();
    final position = _calculateOverlayPosition(itemKeys[itemId]!);
    _overlayEntry = _createOverlayEntry(
      position: position,
      buttons: buttons,
      curve: curve ?? Curves.easeOutBack,
      padding: padding ?? const EdgeInsets.all(5),
      borderRadius: borderRadius ?? BorderRadius.circular(50),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Removes the currently displayed overlay, if any.
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Validates if the message exists in the key map and has a valid context.
  bool _isMessageValid(Map<int, GlobalKey> messageKeys, int messageId) {
    final key = messageKeys[messageId]?.currentContext;
    return key != null && key.findRenderObject() is RenderBox;
  }

  /// Calculates the position of the overlay based on the target widget.
  Offset _calculateOverlayPosition(GlobalKey key) {
    final renderBox = key.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    return Offset(position.dx + size.width / 2 - 150, position.dy + 5);
  }

  /// Creates an overlay entry with the given position and options.
  OverlayEntry _createOverlayEntry({
    required Offset position,
    required List<IconButton> buttons,
    required Curve curve,
    required EdgeInsets padding,
    required BorderRadius borderRadius,
  }) {
    return OverlayEntry(
      builder: (context) => ReactionOverlayWidget(
        position: position,
        onDismiss: _removeOverlay,
        buttons: buttons,
        curve: curve,
        padding: padding,
        borderRadius: borderRadius,
      ),
    );
  }
}