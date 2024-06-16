import 'dart:math' as math;

abstract class EmojisGenerator {
  static const _emojis = [
    ['🎾'],
    ['🔍'],
    ['📦'],
    ['🧠'],
    ['🎀'],
    ['💣'],
    ['👍'],
    ['💥'],
    ['🐼'],
    ['💙'],
    ['🧊'],
    ['⌛'],
    ['🦄'],
    ['😍'],
    ['🤩'],
    ['🍀', '🤞'],
    ['🏖️', '🐬'],
    ['🌂', '💜'],
    ['🔮', '💜'],
    ['🦄', '🌈'],
    ['💙', '🌊'],
    ['🍎', '🍒'],
    ['🍊', '🥕'],
    ['🍏', '🥝'],
    ['💛', '🍋', '🌻'],
    ['🐸', '🍏', '🌴'],
    ['🎹', '👻', '🖤'],
    ['💗', '🌸', '🌷'],
    ['🥑', '🍏', '🥦', '🌴'],
    ['☂️', '🔮', '🦄', '💜'],
  ];

  static final _random = math.Random();

  static List<String> generate() {
    return _emojis[_random.nextInt(_emojis.length)].toList()..shuffle();
  }
}
