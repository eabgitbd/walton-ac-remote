import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TactileButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final double width;
  final double height;
  final double borderRadius;
  final bool isCircle;

  const TactileButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor = const Color(0xFFF1F5F9),
    this.textColor = const Color(0xFF1E293B),
    this.borderColor = const Color(0xFFCBD5E1),
    this.width = 68,
    this.height = 48,
    this.borderRadius = 10,
    this.isCircle = false,
  });

  @override
  State<TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<TactileButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double depth = _isPressed ? 1.0 : 3.5;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        width: widget.width,
        height: widget.height,
        margin: EdgeInsets.only(
          top: _isPressed ? 2.5 : 0.0,
          bottom: _isPressed ? 0.0 : 2.5,
        ),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: widget.isCircle ? null : BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: widget.borderColor,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x33000000),
              offset: Offset(0, depth),
              blurRadius: _isPressed ? 1.5 : 3.0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: DefaultTextStyle(
          style: TextStyle(
            color: widget.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
