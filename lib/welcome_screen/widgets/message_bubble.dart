import 'dart:math' as math;

import 'package:flutter/material.dart';

class MessageBubble extends StatefulWidget {
  const MessageBubble({super.key});

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1).chain(
          CurveTween(curve: Curves.ease),
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0.95).chain(
          CurveTween(curve: Curves.ease),
        ),
        weight: 1,
      ),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: MatrixTransition(
        animation: _scale,
        onTransform: (scale) {
          return Matrix4.identity()
            ..rotateZ(math.pi / 14)
            ..scaleByDouble(scale, scale, 1, 1);
        },
        child: const DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            color: Color(0xD8D6F5E1),
            boxShadow: [
              BoxShadow(
                color: Color(0x3377947C),
                blurRadius: 4,
                offset: Offset(0, 2),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/avatar.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox.square(dimension: 46),
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hey you,',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          height: 22 / 15,
                          letterSpacing: -0.3,
                          color: Color(0xFF64C387),
                        ),
                      ),
                      Text(
                        "You're invited to drop #1.",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          height: 22 / 15,
                          letterSpacing: -0.10,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
