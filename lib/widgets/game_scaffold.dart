import 'package:flutter/material.dart';

class GameScaffold extends StatelessWidget {
  final Widget? body;
  final String? title;
  const GameScaffold({
    Key? key,
    this.body,
    this.title,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? "superfun_01"),
      ),
      body: body,
    );
  }
}
