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
          color: Colors.grey[300]
        ),
        SizedBox(height: 20),
      ],
    );
  }
}

class CommentLine extends StatelessWidget {
  const CommentLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10),
        Container(
            width: double.infinity,
            height: 1,
            color: Color(0xffeeeeee)
        ),
        SizedBox(height: 10),
      ],
    );
  }
}

class AuctionLine extends StatelessWidget {
  const AuctionLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            width: double.infinity,
            height: 1,
            color: DarkColors.basic
        ),
      ],
    );
  }
}

class DarkColors {
  static const Color basic = Color(0xff1F1F1F);
}
