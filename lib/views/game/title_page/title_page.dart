import 'package:cross_math/widgets/game_scaffold.dart';
import 'package:flutter/material.dart';

class TitlePageView extends StatefulWidget {
  const TitlePageView({Key? key}) : super(key: key);

  @override
  _TitlePageViewState createState() => _TitlePageViewState();
}

Widget _titlePage(BuildContext context) {
  return Column(
    children: [
      const Text("hello!"),
      TextButton(onPressed: () => Navigator.pushNamed(context, '/board'), child: const Text("Hello!"))
    ],
  );
}

class _TitlePageViewState extends State<TitlePageView> {
  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: "superfun_01 title page",
      body: _titlePage(context),
    );
  }
}
