import 'package:cross_math/widgets/game_scaffold.dart';
import 'package:flutter/material.dart';

class TitlePageView extends StatefulWidget {
  const TitlePageView({Key? key}) : super(key: key);

  @override
  _TitlePageViewState createState() => _TitlePageViewState();
}

class _TitlePageViewState extends State<TitlePageView> {
  int difficultySettingInt = 2;
  String difficultyName = "Normal";

  Widget _difficultySelect() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio(
                value: 1,
                groupValue: difficultySettingInt,
                onChanged: (int? v) {
                  setState(() {
                    difficultyName = "Easy";
                    difficultySettingInt = v!;
                  });
                }),
            const Text("Easy")
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio(
                value: 2,
                groupValue: difficultySettingInt,
                onChanged: (int? v) {
                  setState(() {
                    difficultyName = "Normal";
                    difficultySettingInt = v!;
                  });
                }),
            const Text("Noarmal")
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio(
                value: 3,
                groupValue: difficultySettingInt,
                onChanged: (int? v) {
                  setState(() {
                    difficultyName = "Hard";
                    difficultySettingInt = v!;
                  });
                }),
            const Text("Hard")
          ],
        )
      ],
    );
  }

  Widget _titlePage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _difficultySelect(),
        ElevatedButton(
            onPressed: () => Navigator.pushNamed(
                  context,
                  '/board',
                  arguments: {
                    "boardSize": 5,
                    "blanks": difficultySettingInt,
                  },
                ),
            child: const Text("Start!"))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      body: _titlePage(),
    );
  }
}
