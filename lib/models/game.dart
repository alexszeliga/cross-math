import 'dart:math';

import 'package:cross_math/models/tile.dart';

class Game {
  final int boardSize = 5;
  final int blanksPerRow = 2;
  late int tileCount = boardSize * boardSize;

  int rng() => Random().nextInt(9) + 1;

  Tile createTile() => Tile(rng());
}
