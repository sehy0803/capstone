// === 스크롤 기본 ===
import 'package:flutter/material.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
            slivers: [
              SliverAppBar(
                  title: Text('관심목록',
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
