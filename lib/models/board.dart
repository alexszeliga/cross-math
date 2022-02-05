import 'package:cross_math/models/tile.dart';

import 'game.dart';

class Board {
  final Game game;
  Board({required this.game});
  late List<int> numbers = [for (int i = 0; i < game.tileCount; i++) game.rng()];
  late List<List<int>> rows = [
    for (int i = 0; i < game.tileCount; i = i + game.boardSize)
      [
        for (int j = i; j < i + game.boardSize; j++) numbers[j],
      ]
  ];

  late List<List<Tile>> rowTiles = rows.map((l) => [...l.map((i) => tiles[i])]).toList();

  late List<int> rowTotals = [...rowTiles.map((l) => l.map((t) => t.solutionValue).reduce((a, b) => a + b))];
  late List<List<int>> cols = [
    for (int i = 0; i < game.boardSize; i++) [for (int j = 0; j < game.boardSize; j++) rows[j][i]]
  ];
  late List<List<Tile>> colTiles = cols.map((l) => [...l.map((i) => tiles[i])]).toList();

  late List<int> colTotals = [...colTiles.map((l) => l.map((t) => t.solutionValue).reduce((a, b) => a + b))];
  late List<int> blanks = _blanks();
  late List<Tile> tiles = _tiles();
  late List<int> rowIndexes = [for (int r = 0; r < rows.length; r++) r];
  late List<int> colIndexes = [for (int c = 0; c < cols.length; c++) c];
  List<int> _blanks() {
    List<int> finalOutput = [];

    for (int round = 0; round < game.blanksPerRow; round++) {
      List<int> internalNumbers = [];

      List<int> ci = [...colIndexes];
      List<int> ri = [...rowIndexes];
      ci.shuffle();
      ri.shuffle();
      while (ci.isNotEmpty && ri.isNotEmpty) {
        int rowVal = ri.removeLast();
        int colVal = ci.removeLast();
        int value = (rowVal * game.boardSize) + colVal;
        if (finalOutput.contains(value)) {
          internalNumbers = [];
          ci = [...colIndexes];
          ri = [...rowIndexes];
          ci.shuffle();
          ri.shuffle();
        }
        internalNumbers.add(value);
      }
      finalOutput.addAll(internalNumbers);
    }
    return finalOutput;
  }

  List<Tile> _tiles() {
    List<Tile> output = [];
    for (int i = 0; i < numbers.length; i++) {
      if (blanks.contains(i)) {
        // output.add(Tile(false, numbers[i], i, (i / game.boardSize).floor(), (i % game.boardSize)));
        output.add(Tile(numbers[i]));
      } else {
        output.add(Tile(numbers[i]));
      }
    }
    return output;
  }
}
