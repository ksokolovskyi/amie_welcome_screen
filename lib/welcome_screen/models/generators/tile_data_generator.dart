import 'dart:math' as math;

import 'package:amie_welcome_screen/welcome_screen/welcome_screen.dart';

abstract class TileDataGenerator {
  static const _titles = [
    'Brunch with Felix',
    'Sign up for Amie',
    'Mountain hike',
    'Write plan for diversity',
    'Buy a new car',
    'Hang with friends',
    'Build something fun',
    'Family BBQ',
    'Bake a cake',
    'Meet with Ava',
  ];

  static final _random = math.Random();

  static TileData generate() {
    final title = _titles[_random.nextInt(_titles.length)];
    final hours = _random.nextInt(13) + 8;
    final minutes = _random.nextBool() ? '00' : '30';

    return TileData(
      title: title,
      time: '$hours:$minutes',
    );
  }
}
