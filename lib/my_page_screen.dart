// === 스크롤 기본 ===
import 'package:flutter/material.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
            slivers: [
              SliverAppBar(
                  title: Text('마이페이지',
                      style: TextStyle(color: Colors.black, fontSize: 20)),
                  backgroundColor: Colors.white,
                  floating: true,
                  pinned: false,
                  actions: [
                    IconButton(
                        onPressed: (){},
                        icon: Icon(Icons.search),
                        iconSize: 30,
                        color: Colors.black
                    ),
                  ]
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
