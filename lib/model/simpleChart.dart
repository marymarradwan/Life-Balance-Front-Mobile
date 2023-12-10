
import 'package:flutter/cupertino.dart';

class SimpleChart {

  SimpleChart({this.x, this.y, this.text , this.pointColor});

  var x;
  var  y;
  var text;
  final Color pointColor;

  @override
  String toString() {
    return 'SimpleChart{x: $x, y: $y, text: $text}';
  }
}