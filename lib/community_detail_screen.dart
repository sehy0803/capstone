import 'package:flutter/material.dart';

class CommunityDetailScreen extends StatelessWidget {
  final String title;
  final String content;

  const CommunityDetailScreen({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: Text('유저 게시판',
                style: TextStyle(color: Colors.black, fontSize: 20)),
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: (){
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios),
              iconSize: 30,
              color: Colors.black,
            ),
        ),
        body: SingleChildScrollView(
            child: Column(
              children: [
                // 게시글 제목
                Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

                // 게시글 내용
                Text(content, style: TextStyle(fontSize: 18)),




              ],
            )


        ),
    );
  }
}

// ========================================== 커스텀 위젯 ==========================================

