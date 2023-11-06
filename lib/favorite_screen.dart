import 'package:flutter/material.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title:
              Text('관심목록', style: TextStyle(color: Colors.black, fontSize: 20)),
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        body: ListView(
          children: [
            Text('좋아요 한 게시물 표시')
          ],
        ));
  }
}

// ========================================== 커스텀 위젯 ==========================================
