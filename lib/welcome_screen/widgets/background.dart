import 'dart:math' as math;

import 'package:amie_welcome_screen/welcome_screen/welcome_screen.dart';
import 'package:equatable/equatable.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Transform;
import 'package:flutter/material.dart';

class Background extends StatefulWidget {
  const Background({super.key});

  @override
  State<Background> createState() => _BackgroundState();
}

class _BackgroundState extends State<Background> {
  final _tilesState = _TilesState(count: 15);

  late final _flowDelegate = _BackgroundFlowDelegate(
    tilesState: _tilesState,
  );

  late final _simulation = _BackgroundSimulation(tilesState: _tilesState);

  @override
  void dispose() {
    _tilesState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          GameWidget(game: _simulation),
          RepaintBoundary(
            child: Flow.unwrapped(
              clipBehavior: Clip.none,
              delegate: _flowDelegate,
              children: [
                for (var id = 0; id < _tilesState.count; id++)
                  Tile(
                    data: _tilesState.getData(id),
                    onDragStart: (position) {
                      _simulation.onDragStart(id, position);
                    },
                    onDragUpdate: (position) {
                      _simulation.onDragUpdate(id, position);
                    },
                    onDragEnd: () {
                      _simulation.onDragEnd();
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TilesState extends ChangeNotifier {
  _TilesState({
    required this.count,
  });

  /// The total number of tiles.
  final int count;

  late final List<TileData> _data = List.generate(
    count,
    (_) => TileDataGenerator.generate(),
  );

  final Map<int, _TileConfig> _config = {};

  bool _hasChange = false;
  
  /// Whether all tiles are configured.
  bool get isReady => _config.length == count;

  /// Returns data of a specific tile.
  TileData getData(int id) {
    assert(id >= 0 && id < count, 'tile with $id id is not found');
    return _data[id];
  }

  /// Returns config of a specific tile.
  _TileConfig getConfig(int id) {
    assert(_config.containsKey(id), 'tile with $id id is not found');
    return _config[id]!;
  }

  /// Updates config of a specific tile.
  void setConfig({
    required int id,
    required _TileConfig config,
  }) {
    if (_config[id] == config) {
      return;
    }

    _hasChange = true;
    _config[id] = config;
  }

  /// Notifies all of the listeners of this state if it has changed.
  void notifyListenersIfChanged() {
    if (_hasChange) {
      notifyListeners();
      _hasChange = false;
    }
  }
}

class _TileConfig extends Equatable {
  const _TileConfig({
    required this.size,
    required this.position,
    required this.angle,
  });

  _TileConfig copyWith({
    Size? size,
    Offset? position,
    double? angle,
  }) {
    return _TileConfig(
      size: size ?? this.size,
      position: position ?? this.position,
      angle: angle ?? this.angle,
    );
  }

  /// The actual size of the tile.
  final Size size;

  /// The position of the top left tile's corner.
  final Offset position;

  /// The angle of the tile.
  final double angle;

  @override
  List<Object?> get props => [size, position, angle];
}

class _BackgroundFlowDelegate extends FlowDelegate {
  _BackgroundFlowDelegate({
    required this.tilesState,
  }) : super(repaint: tilesState);

  final _TilesState tilesState;

  final _random = math.Random();

  @override
  Size getSize(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return constraints.loosen();
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    final size = context.size;

    // This check is needed as on iOS Flutter has zero size first frame which
    // need to be ignored in our case.
    // Details: https://github.com/flutter/flutter/issues/149974#issuecomment-2166168911.
    if (size == Size.zero) {
      return;
    }

    if (tilesState.isReady) {
      for (var id = 0; id < tilesState.count; id++) {
        final config = tilesState.getConfig(id);

        context.paintChild(
          id,
          transform: _computeTransformation(config),
        );
      }
    } else {
      final maxY = size.height * 0.75;

      final half = tilesState.count ~/ 2;

      for (var id = 0; id < tilesState.count; id++) {
        final childSize = context.getChildSize(id)!;

        final Offset childPosition;

        final maxX = id < half ? size.width / 2 : size.width;

        var dx = _random.nextDouble() * maxX;
        if (dx + childSize.width > size.width) {
          dx = size.width - childSize.width;
        }

        var dy = _random.nextDouble() * maxY;
        if (dy + childSize.height > maxY) {
          dy = maxY - childSize.height;
        }

        childPosition = Offset(dx, dy);

        final sign = _random.nextBool() ? 1 : -1;
        final factor = _random.nextInt(20) + 10;
        final childAngle = math.pi / 2 / factor * sign;

        final config = _TileConfig(
          size: childSize,
          position: childPosition,
          angle: childAngle,
        );

        tilesState.setConfig(
          id: id,
          config: config,
        );

        context.paintChild(
          id,
          transform: _computeTransformation(config),
        );
      }
    }
  }

  Matrix4 _computeTransformation(_TileConfig config) {
    final translation = Alignment.center.alongSize(config.size);

    final result = Matrix4.identity()
      ..translate(translation.dx, translation.dy)
      ..multiply(
        Matrix4.identity()
          ..translate(config.position.dx, config.position.dy)
          ..rotateZ(config.angle),
      )
      ..translate(-translation.dx, -translation.dy);

    return result;
  }

  @override
  bool shouldRepaint(covariant FlowDelegate oldDelegate) {
    return false;
  }
}

class _BackgroundSimulation extends Forge2DGame {
  static const zoom = 20.0;

  _BackgroundSimulation({
    required _TilesState tilesState,
  })  : _tilesState = tilesState,
        super(
          zoom: zoom,
          gravity: Vector2.zero(),
        );

  final _random = math.Random();

  final _TilesState _tilesState;

  final Map<int, Body> _bodies = {};

  late final Body _groundBody;

  MouseJoint? _mouseJoint;

  @override
  Color backgroundColor() => Colors.white;

  @override
  void onLoad() {
    super.onLoad();

    _groundBody = world.createBody(BodyDef());

    _createBoundaries();
  }

  @override
  void renderTree(Canvas canvas) {}

  @override
  // ignore: must_call_super
  void render(Canvas canvas) {}

  @override
  void renderDebugMode(Canvas canvas) {}

  @override
  void onDispose() {
    onDragEnd();
    super.onDispose();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_tilesState.isReady) {
      return;
    }

    if (_bodies.isEmpty) {
      for (var id = 0; id < _tilesState.count; id++) {
        _createTileBody(
          id: id,
          config: _tilesState.getConfig(id),
        );
      }
    } else {
      assert(
        _bodies.length == _tilesState.count,
        'bodies count has to be exactly the same as tile count',
      );

      for (final MapEntry(key: id, value: body) in _bodies.entries) {
        final previousConfig = _tilesState.getConfig(id);

        final size = previousConfig.size;

        final position = worldToScreen(body.position).toOffset().translate(
              -size.width / 2,
              -size.height / 2,
            );

        final config = previousConfig.copyWith(
          position: position,
          angle: body.angle,
        );

        _tilesState.setConfig(
          id: id,
          config: config,
        );
      }

      _tilesState.notifyListenersIfChanged();
    }
  }

  void _createBoundaries() {
    final visibleRect = camera.visibleWorldRect;
    const translation = 1.0;

    final topLeft =
        visibleRect.topLeft.translate(-translation, -translation).toVector2();
    final topRight =
        visibleRect.topRight.translate(translation, -translation).toVector2();
    final bottomRight =
        visibleRect.bottomRight.translate(translation, translation).toVector2();
    final bottomLeft =
        visibleRect.bottomLeft.translate(-translation, translation).toVector2();

    _createBoundary(start: topLeft, end: topRight);
    _createBoundary(start: topRight, end: bottomRight);
    _createBoundary(start: bottomRight, end: bottomLeft);
    _createBoundary(start: bottomLeft, end: topLeft);
  }

  void _createBoundary({
    required Vector2 start,
    required Vector2 end,
  }) {
    final shape = EdgeShape()..set(start, end);
    final fixtureDef = FixtureDef(shape, friction: 0.3);
    final bodyDef = BodyDef(
      position: Vector2.zero(),
    );

    world.createBody(bodyDef).createFixture(fixtureDef);
  }

  void _createTileBody({
    required int id,
    required _TileConfig config,
  }) {
    final globalCenterPosition = config.position.translate(
      config.size.width / 2,
      config.size.height / 2,
    );

    final position = screenToWorld(
      Vector2(globalCenterPosition.dx, globalCenterPosition.dy),
    );
    final size = config.size / zoom;

    final bodyDef = BodyDef(
      position: position,
      angle: config.angle,
      type: BodyType.dynamic,
    );
    final body = world.createBody(bodyDef);

    final shape = PolygonShape()..setAsBoxXY(size.width / 2, size.height / 2);
    final fixtureDef = FixtureDef(
      shape,
      restitution: 0.2,
      friction: 0.5,
      density: 1000,
      filter: Filter()..groupIndex = -1,
    );
    body.createFixture(fixtureDef);

    if (_random.nextBool()) {
      final sign = _random.nextBool() ? 1 : -1;
      final impulse = 800.0 + _random.nextInt(500);
      body.applyLinearImpulse(Vector2(0, impulse * sign));
    }

    if (_random.nextBool()) {
      final sign = _random.nextBool() ? 1 : -1;
      final impulse = 7000.0 + _random.nextInt(5000);
      body.applyAngularImpulse(impulse * sign);
    }

    _bodies[id] = body;
  }

  void onDragStart(int id, Offset position) {
    assert(_bodies.containsKey(id), 'body with $id id is not found');

    final body = _bodies[id]!;
    final localPosition = screenToWorld(position.toVector2());

    final mouseJointDef = MouseJointDef()
      ..maxForce = 2000 * body.mass
      ..dampingRatio = 0.1
      ..frequencyHz = 50
      ..target.setFrom(localPosition)
      ..collideConnected = false
      ..bodyA = _groundBody
      ..bodyB = body;

    if (_mouseJoint == null) {
      _mouseJoint = MouseJoint(mouseJointDef);
      world.createJoint(_mouseJoint!);
    }
  }

  void onDragUpdate(int id, Offset position) {
    final localPosition = screenToWorld(position.toVector2());
    _mouseJoint?.setTarget(localPosition);
  }

  void onDragEnd() {
    if (_mouseJoint != null) {
      world.destroyJoint(_mouseJoint!);
      _mouseJoint = null;
    }
  }
}
