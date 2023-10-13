import 'package:flutter/material.dart';

void main() {
  runApp(const Test());
}

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GridView.count(
          crossAxisCount : 3, //grid 수
          children : <Widget> [
            Container(
              color : Colors.red,
              width : 100,
              height : 100,
            ),
            Container(
              color : Colors.blueGrey,
              width : 100,
              height : 100,
            ),
            Container(
              color : Colors.lime,
              width : 100,
              height : 100,
            ),
            Container(
              color : Colors.teal,
              width : 100,
              height : 100,
            ),
            Container(
              color : Colors.blue,
              width : 100,
              height : 100,
            ),
            Container(
              color : Colors.indigo,
              width : 100,
              height : 100,
            ),
          ]
      ),
    );
  }
}
