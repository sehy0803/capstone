import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('캡스톤디자인'),
        ),
        body: Container(
          child: Text('우리팀 파이팅'),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.star),
                Icon(Icons.star),
                Icon(Icons.star)
              ],
            ),
          )
        ),
      ),
    );
  }
}
