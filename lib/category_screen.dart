// === 스크롤 기본 ===
import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
            slivers: [
              SliverAppBar(
                  title: Text('카테고리',
                      style: TextStyle(color: Colors.black, fontSize: 20)),
                  backgroundColor: Colors.white,
                  floating: true,
                  pinned: false,
              ),
              SliverList(
                  delegate: SliverChildListDelegate(
                      [
                        // 위젯 추가








                      ]
                  )
              )
            ]
        ),
      ),
    );
  }
}
