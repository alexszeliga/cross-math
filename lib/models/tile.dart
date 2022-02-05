import 'package:flutter/cupertino.dart';

class Tile {
  final int solutionValue;
  final TextEditingController controller = TextEditingController();

  bool isEditable;
  late int index;

  late int? outputValue = isEditable ? int.tryParse(controller.text) ?? 0 : solutionValue;
  int? playerGuess;
  Tile(this.solutionValue, [this.isEditable = false]);

  void makeEditable() {
    this.isEditable = true;
  }
}
