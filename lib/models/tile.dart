import 'package:flutter/cupertino.dart';

import 'game.dart';

class Tile {
  final int solutionValue;
  final bool isSumTile;
  final bool isBlank;
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  late int index;

  late int outputValue = isBlank ? 0 : solutionValue;
  Tile(this.solutionValue, {this.index = -1, this.isBlank = false, this.isSumTile = false});

  int getCol(Game game) {
    return index % game.boardSize;
  }

  int getRow(Game game) {
    return (index / game.boardSize).floor();
  }
}
