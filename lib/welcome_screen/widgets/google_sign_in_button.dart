import 'package:flutter/material.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    duration: const Duration(milliseconds: 150),
    vsync: this,
  );

  late final _scale = Tween<double>(begin: 1, end: 0.95).animate(_controller);

  late final _color = ColorTween(
    begin: const Color(0xFFE5E5E4),
    end: const Color(0xFFE5E5E4).withOpacity(0.8),
  ).animate(_controller);

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
    return GestureDetector(
      onTapDown: (_) => _onTapDown(),
      onTapUp: (_) => _onTapUp(),
      onTapCancel: _onTapUp,
      child: MatrixTransition(
        animation: _scale,
        onTransform: (scale) => Matrix4.identity()..scale(scale),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: Color(0xFF171717),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ListenableBuilder(
                  listenable: _color,
                  builder: (context, _) {
                    return Image.asset(
                      'assets/images/google.png',
                      height: 18,
                      width: 18,
                      color: _color.value,
                    );
                  },
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 8,
                      bottom: 8,
                      left: 8,
                    ),
                    child: ListenableBuilder(
                      listenable: _color,
                      builder: (context, _) {
                        return Text(
                          'Continue with Google',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            height: 32 / 16,
                            letterSpacing: -0.26,
                            color: _color.value,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
