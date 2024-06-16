import 'package:amie_welcome_screen/welcome_screen/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef TileDragStartCallback = void Function(Offset position);

typedef TileDragUpdateCallback = TileDragStartCallback;

typedef TileDragEndCallback = void Function();

class Tile extends StatelessWidget {
  const Tile({
    required this.data,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    super.key,
  });

  /// Data to show on this tile.
  final TileData data;

  /// Called when drag starts.
  final TileDragStartCallback onDragStart;

  /// Called when drag position is updated.
  final TileDragUpdateCallback onDragUpdate;

  /// Called when drag ends.
  final TileDragEndCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => onDragStart(details.globalPosition),
      onPanUpdate: (details) => onDragUpdate(details.globalPosition),
      onPanEnd: (_) => onDragEnd(),
      onPanCancel: onDragEnd,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x33B7B6B7),
              blurRadius: 16,
              offset: Offset(0, 3),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Checkbox(),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        height: 20 / 16,
                        letterSpacing: -0.24,
                        color: Color(0xFF171717),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      data.time,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        height: 14 / 12,
                        letterSpacing: 0.12,
                        color: Color(0xFF737374),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Checkbox extends StatefulWidget {
  const _Checkbox();

  @override
  State<_Checkbox> createState() => _CheckboxState();
}

class _CheckboxState extends State<_Checkbox>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    duration: const Duration(milliseconds: 150),
    vsync: this,
  );

  late final _scale = Tween<double>(begin: 1, end: 0.9).animate(_controller);

  var _isChecked = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown() {
    _controller.forward();
  }

  Future<void> _onTapUp() async {
    await _controller.forward();
    await _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => _onTapDown(),
        onTapUp: (details) {
          setState(() {
            _isChecked = !_isChecked;
          });

          HapticFeedback.lightImpact().ignore();

          if (_isChecked) {
            ReactionsOverlay.of(context).displayReactionAt(
              globalPosition: details.globalPosition,
            );
          }

          _onTapUp();
        },
        onTapCancel: _onTapUp,
        child: MatrixTransition(
          animation: _scale,
          onTransform: (scale) => Matrix4.identity()..scale(scale),
          child: DecoratedBox(
            decoration: _isChecked
                ? const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                    color: Color(0xFF131313),
                  )
                : const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                    border: Border.fromBorderSide(
                      BorderSide(
                        color: Color(0xFF737374),
                        width: 2,
                      ),
                    ),
                  ),
            child: _isChecked
                ? const CustomPaint(
                    painter: _CheckboxPainter(),
                    size: Size.square(20),
                  )
                : const SizedBox.square(dimension: 20),
          ),
        ),
      ),
    );
  }
}

class _CheckboxPainter extends CustomPainter {
  const _CheckboxPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // This following code is generated from SVG by:
    // https://fluttershapemaker.com.

    final path = Path()
      ..moveTo(size.width * 0.29, size.height * 0.54)
      ..lineTo(size.width * 0.38, size.height * 0.63)
      ..cubicTo(
        size.width * 0.4,
        size.height * 0.65,
        size.width * 0.43,
        size.height * 0.65,
        size.width * 0.45,
        size.height * 0.63,
      )
      ..lineTo(size.width * 0.72, size.height * 0.35);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12
      ..color = Colors.white
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckboxPainter oldDelegate) => false;
}
