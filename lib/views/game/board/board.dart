import 'package:cross_math/models/board.dart';
import 'package:cross_math/models/game.dart';
import 'package:cross_math/models/tile.dart';
import 'package:flutter/material.dart';

class BoardView extends StatefulWidget {
  final Game game;
  const BoardView({Key? key, required this.game}) : super(key: key);

  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<BoardView> {
  late Game game = widget.game;

  late Board board = Board(game: game);
  late List<int> rowUserTotals = [
    ...board.rowTiles.map((l) => l.map((t) => t.outputValue ?? 0).reduce((a, b) => a + b))
  ];

  Widget _row([int offset = 0]) {
    List<Widget> cards = [];
    for (int i = 0; i < game.boardSize; i++) {
      cards.add(_tile(board.tiles[offset + i]));
    }
    return Row(
      children: cards,
    );
  }

  Widget _card(int i, [int? u]) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Center(
          child: Text(
            i.toString(),
            // style: Theme.of(context).textTheme.headline3,
            style: i != u ? Theme.of(context).textTheme.headline3 : Theme.of(context).textTheme.headline2,
          ),
        ),
      ),
    );
  }

  Widget _tile(Tile t) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Center(
          child: t.isEditable
              ? Text(
                  t.solutionValue.toString(),
                  style: Theme.of(context).textTheme.headline3,
                )
              : TextField(
                  controller: t.controller,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline3,
                  onTap: () {
                    print(t.solutionValue);
                  },
                  onChanged: (s) => print(rowUserTotals),
                ),
        ),
      ),
    );
  }

  Widget _topSums() {
    List<Widget> cards = [...board.colTotals.map((i) => _card(i))];
    cards.add(_card(0));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: cards,
    );
  }

  Widget _sideSums() {
    print(rowUserTotals);
    List<Widget> cards = [...board.rowTotals.map((i) => _card(i, i))];

    return Column(
      children: cards,
    );
  }

  Widget _playingField() {
    List<Widget> rows = [for (int i = 0; i < game.boardSize; i++) _row(i * game.boardSize)];
    return Column(
      children: rows,
    );
  }

  Widget _gameArea() {
    return Column(
      children: [
        _topSums(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _playingField(),
            _sideSums(),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _gameArea();
  }
}
