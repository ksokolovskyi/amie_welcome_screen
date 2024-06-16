import 'dart:math' as math;

import 'package:amie_welcome_screen/welcome_screen/welcome_screen.dart';
import 'package:flutter/material.dart';

class ReactionsOverlay extends StatefulWidget {
  const ReactionsOverlay({
    required this.child,
    super.key,
  });

  final Widget child;

  /// Finds the [ReactionsOverlayState] from the closest instance of this class
  /// that encloses the given context.
  ///
  /// This method can be expensive (it walks the element tree).
  static ReactionsOverlayState of(BuildContext context) {
    final state = context.findAncestorStateOfType<ReactionsOverlayState>();

    // ignore: prefer_asserts_with_message
    assert(() {
      if (state == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('No $ReactionsOverlay widget found.'),
          ErrorDescription(
            '${context.widget.runtimeType} widgets require an '
            '$ReactionsOverlay widget ancestor.',
          ),
          ...context.describeMissingAncestor(
            expectedAncestorType: ReactionsOverlay,
          ),
        ]);
      }

      return true;
    }());

    return state!;
  }

  @override
  State<ReactionsOverlay> createState() => ReactionsOverlayState();
}

class ReactionsOverlayState extends State<ReactionsOverlay> {
  final _overlayKey = GlobalKey<OverlayState>();

  late final _childEntry = OverlayEntry(
    maintainState: true,
    opaque: true,
    builder: (context) => widget.child,
  );

  late final _entries = <OverlayEntry>[];

  @override
  void dispose() {
    _childEntry
      ..remove()
      ..dispose();

    for (final entry in _entries) {
      entry
        ..remove()
        ..dispose();
    }

    super.dispose();
  }

  /// Displays the random reaction on the given position.
  void displayReactionAt({
    required Offset globalPosition,
  }) {
    final renderBox =
        _overlayKey.currentContext!.findRenderObject()! as RenderBox;
    final size = renderBox.size;
    final overlayGlobalPosition = renderBox.localToGlobal(Offset.zero);

    final rect = overlayGlobalPosition & size;

    if (rect.contains(globalPosition)) {
      late final OverlayEntry entry;

      void removeEntry() {
        entry
          ..remove()
          ..dispose();
      }

      final emojis = EmojisGenerator.generate();

      final dx = globalPosition.dx - rect.left;
      final dy = globalPosition.dy - rect.top;
      final initialPosition = Offset(dx, dy);

      entry = OverlayEntry(
        builder: (context) {
          return _Reaction(
            emojis: emojis,
            initialPosition: initialPosition,
            onAnimationCompleted: removeEntry,
          );
        },
      );

      _entries.add(entry);
      _overlayKey.currentState!.insert(entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(
      key: _overlayKey,
      clipBehavior: Clip.none,
      initialEntries: [_childEntry],
    );
  }
}

class _Reaction extends StatefulWidget {
  const _Reaction({
    required this.emojis,
    required this.initialPosition,
    required this.onAnimationCompleted,
  }) : assert(
          emojis.length < 5,
          '$_Reaction is designed to show not more than 4 emojis.',
        );

  /// List of emoji to show.
  final List<String> emojis;

  /// Initial global position on screen to display the reaction from.
  final Offset initialPosition;

  /// Called when reaction animation is completed (when the reaction is
  /// offscreen).
  final VoidCallback onAnimationCompleted;

  @override
  State<_Reaction> createState() => _ReactionState();
}

class _ReactionState extends State<_Reaction> with TickerProviderStateMixin {
  static const _startAngle = 3 * math.pi / 4;
  static const _stepAngle = math.pi / 3;

  final _random = math.Random();

  late final AnimationController _appearanceController;

  // List of scale animations for each emoji.
  final List<Animation<double>> _scale = [];

  // List of slide(transition) animations for each emoji.
  final List<Animation<Offset>> _slide = [];

  late final AnimationController _rotationController;

  // List of rotation animations for each emoji.
  final List<Animation<double>> _rotation = [];

  late final AnimationController _positionController;

  // List of position animations for each emoji.
  final List<Animation<Offset>> _position = [];

  @override
  void initState() {
    super.initState();

    _appearanceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    final positionAnimationDuration = math.max(
      widget.initialPosition.dy * 1500 ~/ 800,
      400,
    );

    _positionController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: positionAnimationDuration),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: math.max(700, positionAnimationDuration),
      ),
    );

    var previousAngle = _startAngle;

    for (var i = 0; i < widget.emojis.length; i++) {
      _scale.add(
        Tween<double>(begin: 0, end: 1)
            .chain(
              CurveTween(
                curve: const Interval(0, 0.8, curve: Curves.easeOutCirc),
              ),
            )
            .animate(_appearanceController),
      );

      final radius =
          widget.emojis.length == 1 ? 0.8 : 0.8 + 0.5 * _random.nextDouble();

      final angle = i == 0
          ? previousAngle - (_stepAngle * _random.nextDouble())
          : previousAngle -
              _stepAngle -
              (_stepAngle / 2 * _random.nextDouble());

      previousAngle = angle;

      _slide.add(
        Tween<Offset>(
          begin: Offset.zero,
          end: _polarToCartesian(radius: radius, angle: angle),
        )
            .chain(
              CurveTween(
                curve: const Interval(0, 0.8, curve: Curves.easeOutCirc),
              ),
            )
            .animate(_appearanceController),
      );

      _position.add(
        Tween<Offset>(
          begin: widget.initialPosition,
          end: Offset(widget.initialPosition.dx, -100),
        )
            .chain(
              CurveTween(
                curve: Interval(
                  _random.nextDouble() * 0.05,
                  0.9 + _random.nextDouble() * 0.1,
                  curve: Curves.easeIn,
                ),
              ),
            )
            .animate(_positionController),
      );

      _rotation.add(
        Tween<double>(begin: 0, end: math.pi / 3)
            .chain(
              CurveTween(
                curve: Interval(
                  _random.nextDouble() * 0.5,
                  1,
                  curve: Curves.easeIn,
                ),
              ),
            )
            .animate(_rotationController),
      );
    }

    _appearanceController
      ..forward()
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _rotationController.forward();
          _positionController.forward();
        }
      });

    _positionController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationCompleted();
      }
    });
  }

  @override
  void dispose() {
    _appearanceController.dispose();
    _rotationController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  // Converts coordinate from polar to cartesian coordinate system.
  Offset _polarToCartesian({
    required double radius,
    required double angle,
  }) {
    return Offset(
      radius * math.cos(angle),
      radius * math.sin(angle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withNoTextScaling(
      child: IgnorePointer(
        child: Stack(
          children: [
            for (var i = 0; i < widget.emojis.length; i++)
              ListenableBuilder(
                listenable: _position[i],
                builder: (context, child) {
                  final position = _position[i].value;

                  return Positioned(
                    left: position.dx,
                    top: position.dy,
                    child: child!,
                  );
                },
                child: MatrixTransition(
                  animation: _rotation[i],
                  onTransform: Matrix4.rotationZ,
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, -0.5),
                    child: SlideTransition(
                      position: _slide[i],
                      child: ScaleTransition(
                        scale: _scale[i],
                        child: Text(
                          widget.emojis[i],
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
