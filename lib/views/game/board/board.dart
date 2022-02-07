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
  late bool taller = MediaQuery.of(context).size.height > MediaQuery.of(context).size.width;
  late double optimalWidth = taller
      ? (MediaQuery.of(context).size.width.toInt() / (game.boardSize + 2)).floor().toDouble()
      : (MediaQuery.of(context).size.height.toInt() / (game.boardSize + 2)).floor().toDouble();

  late double cardWidth = optimalWidth > 100 ? 100 : optimalWidth;
  late TextStyle defaultTextStyle =
      cardWidth < 100 ? Theme.of(context).textTheme.headline4! : Theme.of(context).textTheme.headline3!;

  List<List<Tile>> getRowsFromTiles() {
    return [
      for (int o = 0; o < game.tileCount; o += game.boardSize) [for (int i = 0; i < game.boardSize; i++) tiles[o]]
    ];
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
      width: cardWidth,
      height: cardWidth,
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Center(
          child: !tile.isBlank
              ? Text(
                  tile.solutionValue.toString(),
                  style: defaultTextStyle,
                )
              : TextField(
                  controller: tile.controller,
                  focusNode: tile.focusNode,
                  onTap: () {
                    print(tile.solutionValue);
                    tile.focusNode.requestFocus();
                  },
                  textAlign: TextAlign.center,
                  style: defaultTextStyle,
                  keyboardType: TextInputType.number,
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
    return SizedBox(
      width: cardWidth,
      height: cardWidth,
    );
  }

  Widget solutionTile(int solution, int tally) {
    TextStyle textStyle = defaultTextStyle;
    if (solve) {
      textStyle = textStyle.apply(color: tally == solution ? Colors.green : Colors.red);
    }
    return SizedBox(
      width: cardWidth,
      height: cardWidth,
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
    TextStyle textStyle = defaultTextStyle;

    textStyle = textStyle.apply(
        color: guess == solution
            ? Colors.green
            : guess < solution
                ? Colors.amber
                : Colors.red);

    return SizedBox(
      width: cardWidth,
      height: cardWidth,
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
