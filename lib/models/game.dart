import 'dart:math';

import 'package:cross_math/models/tile.dart';

class Game {
  final int boardSize;
  final int blanksPerRow;
  Game([this.boardSize = 5, this.blanksPerRow = 2]);
  static const int dimensions = 2;

  late int tileCount = pow(boardSize, Game.dimensions).toInt();
  static int rng() => Random().nextInt(9) + 1;
  List<int> blankIndexes() {
    List<int> finalOutput = [];
    for (int round = 0; round < blanksPerRow; round++) {
      List<int> internalNumbers = [];
      List<int> ci = _shuffledIndex();
      List<int> ri = _shuffledIndex();
      while (ci.isNotEmpty && ri.isNotEmpty) {
        int rowVal = ri.removeLast();
        int colVal = ci.removeLast();
        int value = (rowVal * boardSize) + colVal;
        if (finalOutput.contains(value)) {
          internalNumbers = [];
          ci = _shuffledIndex();
          ri = _shuffledIndex();
        }
        internalNumbers.add(value);
      }
      finalOutput.addAll(internalNumbers);
    }
    return finalOutput;
  }

  List<int> _shuffledIndex() {
    List<int> indexes = List.generate(boardSize, (i) => i);
    indexes.shuffle();
    return indexes;
  }

  int getCol(Tile tile) {
    return tile.index % boardSize;
  }

  int getRow(Tile tile) {
    return (tile.index / boardSize).floor();
  }
}
