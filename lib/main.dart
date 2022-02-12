import 'package:cross_math/views/game/board/board.dart';
import 'package:cross_math/views/game/title_page/title_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cross-Math',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        "/": (context) => const TitlePageView(),
        "/board": (context) => const BoardView(),
        // '/end' :
      },
    );
  }
}
