import 'package:cross_math/models/game.dart';
import 'package:cross_math/models/tile.dart';
import 'package:flutter/material.dart';

class BoardView extends StatefulWidget {
  const BoardView({Key? key}) : super(key: key);

  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<BoardView> {
  late Game game = Game();
  late List<int> blanks = game.blankIndexes();
  late List<Tile> tiles = [
    for (int i = 0; i < game.tileCount; i++) Tile(Game.rng(), index: i, isBlank: blanks.contains(i))
  ];
  bool showHints = false;
  bool solve = false;

  late List<List<Tile>> rows = getRowsFromTiles();
  late List<List<Tile>> cols = getColsFromTiles();

  late List<int> rowTotals = [...rows.map((l) => l.fold(0, (p, t) => p + t.outputValue))];
  late List<int> colTotals = [...cols.map((l) => l.fold(0, (p, t) => p + t.outputValue))];
  late List<int> rowSolutions = [...rows.map((l) => l.fold(0, (p, t) => p + t.solutionValue))];
  late List<int> colSolutions = [...cols.map((l) => l.fold(0, (p, t) => p + t.solutionValue))];

  // List<int> getRowSolutions() {
  //   return [...rows.map((l) => l.fold(0, (p, t) => p + t.solutionValue))];
  // }

  // List<int> getColSolutions() {
  //   return [...cols.map((l) => l.fold(0, (p, t) => p + t.solutionValue))];
  // }

  // List<int> getRowTotals() {
  //   return [...rows.map((l) => l.fold(0, (p, t) => p + t.outputValue))];
  // }

  // List<int> getColTotals() {
  //   return [...cols.map((l) => l.fold(0, (p, t) => p + t.outputValue))];
  // }

  List<List<Tile>> getRowsFromTiles() {
    List<List<Tile>> output = [];
    int o = 0;
    while (o < game.tileCount) {
      List<Tile> row = [];
      for (int i = 0; i < game.boardSize; i++) {
        row.add(tiles[o]);
        o++;
      }
      output.add(row);
    }
    return output;
  }

  List<List<Tile>> getColsFromTiles() {
    List<List<Tile>> output = [];
    for (int i = 0; i < game.boardSize; i++) {
      List<Tile> col = [];
      for (int j = 0; j < game.tileCount; j += game.boardSize) {
        col.add(tiles[j + i]);
      }
      output.add(col);
    }
    return output;
  }

  Widget _row([int offset = 0]) {
    List<Widget> cards = [];
    for (int i = 0; i < game.boardSize; i++) {
      cards.add(tileWidget(tiles[offset + i]));
    }
    return Row(
      children: cards,
    );
  }

  Widget tileWidget(Tile tile) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Center(
          child: !tile.isBlank
              ? Text(
                  tile.solutionValue.toString(),
                  style: Theme.of(context).textTheme.headline3,
                )
              : TextField(
                  controller: tile.controller,
                  onTap: () => print(tile.solutionValue),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline3,
                  onChanged: (s) {
                    setState(() {
                      tiles[tile.index].outputValue = int.tryParse(s) ?? 0;
                      cols = getColsFromTiles();
                      rows = getRowsFromTiles();
                      rowTotals = [...rows.map((l) => l.fold(0, (p, t) => p + t.outputValue))];
                      colTotals = [...cols.map((l) => l.fold(0, (p, t) => p + t.outputValue))];
                      rowSolutions = [...rows.map((l) => l.fold(0, (p, t) => p + t.solutionValue))];
                      colSolutions = [...cols.map((l) => l.fold(0, (p, t) => p + t.solutionValue))];
                    });
                  },
                ),
        ),
      ),
    );
  }

  Widget blankTile() {
    return const SizedBox(
      width: 100,
      height: 100,
    );
  }

  Widget solutionTile(int solution, int tally) {
    TextStyle textStyle = Theme.of(context).textTheme.headline3!;
    if (solve) {
      textStyle = textStyle.apply(color: tally == solution ? Colors.green : Colors.red);
    }
    return SizedBox(
      width: 100,
      height: 100,
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Center(
          child: Text(
            solution.toString(),
            style: textStyle,
          ),
        ),
      ),
    );
  }

  Widget answerTile(int solution, int guess) {
    TextStyle textStyle = Theme.of(context).textTheme.headline3!;

    textStyle = textStyle.apply(
        color: guess == solution
            ? Colors.green
            : guess < solution
                ? Colors.amber
                : Colors.red);

    return SizedBox(
      width: 100,
      height: 100,
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Center(
          child: Text(
            guess.toString(),
            style: textStyle,
          ),
        ),
      ),
    );
  }

  Widget _playingField() {
    List<Widget> rows = [for (int i = 0; i < game.boardSize; i++) _row(i * game.boardSize)];
    return Column(
      children: rows,
    );
  }

  Widget _sideSums() {
    return Column(
      children: [for (int i = 0; i < rows.length; i++) solutionTile(rowSolutions[i], rowTotals[i])],
    );
  }

  Widget _topSums() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [for (int i = 0; i < cols.length; i++) solutionTile(colSolutions[i], colTotals[i])],
    );
  }

  Widget _userSideSums() {
    List<Widget> kids = [];
    for (int i = 0; i < rows.length; i++) {
      kids.add(showHints ? answerTile(rowSolutions[i], rowTotals[i]) : blankTile());
    }
    return Column(
      children: kids,
    );
  }

  Widget _userBottomSums() {
    List<Widget> kids = [];
    for (int i = 0; i < cols.length; i++) {
      kids.add(showHints ? answerTile(colSolutions[i], colTotals[i]) : blankTile());
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        blankTile(),
        ...kids,
        blankTile(),
      ],
    );
  }

  Widget _controls() {
    return ButtonBar(
      children: [
        ElevatedButton(
            onPressed: () {
              setState(() {
                showHints = true;
              });
            },
            child: const Text("Toggle Hints")),
        ElevatedButton(
            onPressed: () {
              setState(() {
                solve = true;
              });
            },
            child: const Text("Solve"))
      ],
    );
  }

  Widget _gameArea() {
    return Column(
      children: [
        _topSums(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _userSideSums(),
            _playingField(),
            _sideSums(),
          ],
        ),
        _userBottomSums(),
        _controls(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _gameArea();
  }
}
