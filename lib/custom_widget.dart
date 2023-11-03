import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Line extends StatelessWidget {
  const Line({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        Container(
          width: double.infinity,
          height: 1,
          color: Colors.black12
        ),
        SizedBox(height: 20),
      ],
    );
  }
}