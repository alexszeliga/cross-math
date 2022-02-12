import 'dart:async';

import 'package:cross_math/models/game.dart';
import 'package:cross_math/models/tile.dart';
import 'package:cross_math/widgets/game_scaffold.dart';
import 'package:flutter/material.dart';

class BoardView extends StatefulWidget {
  final int blanks;
  final int boardSize;
  const BoardView({
    Key? key,
    required this.blanks,
    required this.boardSize,
  }) : super(key: key);

  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<BoardView> {
  /*
    STATE!
  */
  late Game game = Game(widget.boardSize, widget.blanks);
  late List<int> blanks = game.blankIndexes();
  late List<Tile> tiles;
  bool showHints = false;
  bool solved = false;
  late Timer _timer;
  String timeFormatted = "0";
  late List<List<Tile>> rows;
  late List<List<Tile>> cols;

  late List<int> rowTotals;
  late List<int> colTotals;
  late List<int> rowSolutions;
  late List<int> colSolutions;
  late bool taller = MediaQuery.of(context).size.height > MediaQuery.of(context).size.width;
  late double optimalWidth = taller
      ? (MediaQuery.of(context).size.width.toInt() / (game.boardSize + 2)).floor().toDouble()
      : (MediaQuery.of(context).size.height.toInt() / (game.boardSize + 2)).floor().toDouble();

  late double cardWidth = optimalWidth > 100 ? 100 : optimalWidth;
  late TextStyle defaultTextStyle =
      cardWidth < 100 ? Theme.of(context).textTheme.headline6! : Theme.of(context).textTheme.headline3!;

  /* 
    OVERRIDES!
  */
  @override
  void initState() {
    super.initState();
    _generateTiles();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    // return _gameArea();
    return GameScaffold(
      body: _gameArea(),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  /* 
    METHODS!
  */

  void _updateTile(Tile tile, String input) {
    setState(() {
      tiles[tile.index].outputValue = int.tryParse(input) ?? 0;
    });
    _tallyBoard();
  }

  void _tallyBoard() {
    setState(() {
      cols = [
        for (int colOffset = 0; colOffset < game.boardSize; colOffset++)
          [for (int i = 0; i < game.tileCount; i += game.boardSize) tiles[i + colOffset]]
      ];
      rows = [
        for (int o = 0; o < game.tileCount; o += game.boardSize) [for (int i = 0; i < game.boardSize; i++) tiles[o + i]]
      ];
      rowTotals = [...rows.map((l) => l.fold(0, (p, t) => p + t.outputValue))];
      colTotals = [...cols.map((l) => l.fold(0, (p, t) => p + t.outputValue))];
      rowSolutions = [...rows.map((l) => l.fold(0, (p, t) => p + t.solutionValue))];
      colSolutions = [...cols.map((l) => l.fold(0, (p, t) => p + t.solutionValue))];
    });
  }

  void _generateTiles() {
    setState(() {
      tiles = [for (int i = 0; i < game.tileCount; i++) Tile(Game.rng(), index: i, isBlank: blanks.contains(i))];
    });
    _tallyBoard();
  }

  void _startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      setState(() {
        timeFormatted = timer.tick.toString();
      });
    });
  }

  /* 
    WIDGETS!
  */

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
        color: tile.isBlank ? Colors.white : Colors.white70,
        margin: const EdgeInsets.all(8),
        child: Center(
          child: !tile.isBlank
              ? Text(
                  tile.solutionValue.toString(),
                  style: defaultTextStyle,
                )
              : TextField(
                  decoration: const InputDecoration(hintText: "?", hintStyle: TextStyle(color: Colors.black26)),
                  controller: tile.controller,
                  focusNode: tile.focusNode,
                  onTap: () {
                    print(tile.solutionValue);
                    tile.focusNode.requestFocus();
                  },
                  textAlign: TextAlign.center,
                  style: defaultTextStyle,
                  keyboardType: TextInputType.number,
                  onChanged: (input) {
                    if (!solved) {
                      _updateTile(tile, input);
                    }
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
    if (solved) {
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Seconds elapsed: $timeFormatted"),
        ButtonBar(
          children: [
            if (!showHints)
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showHints = true;
                    });
                  },
                  child: const Text("Toggle Hints")),
            !solved
                ? ElevatedButton(
                    onPressed: () {
                      if (_timer.isActive) _timer.cancel();
                      setState(() {
                        solved = true;
                      });
                    },
                    child: const Text("Solve"))
                : ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                    child: const Text("New Game"))
          ],
        ),
      ],
    );
  }

  Widget _gameArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
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
}
