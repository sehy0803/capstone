import 'package:capstone/community_regist_screen.dart';
import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: Text('커뮤니티',
                style: TextStyle(color: Colors.black, fontSize: 20)),
            backgroundColor: Colors.white,
            actions: [
              IconButton(
                onPressed: (){},
                icon: Icon(Icons.search),
                iconSize: 30,
                color: Colors.black,
              ),
            ]
        ),
        body: SingleChildScrollView(
            child: Column(
              children: [
                // 위젯 추가
                CommunityPostList(), // 커뮤니티 게시글 리스트




              ],
            )
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CommunityRegisterScreen()),
            );
          },
          child: Icon(Icons.edit),
          backgroundColor: Colors.lightBlue,
        ),


      ),
    );
  }
}

// ========================================== 커스텀 위젯 ==========================================

// 커뮤니티 게시글 item
class CommunityPostItem extends StatelessWidget {
  const CommunityPostItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // 배경색
        border: Border(
          bottom: BorderSide(
            color: Colors.black12, // 테두리 색
            width: 1.0, // 테두리 두께
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("게시글 제목", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("내용", style: TextStyle(fontSize: 14)),
            SizedBox(height: 10),
            Row(
              children: [
                Text("댓글 0", style: TextStyle(fontSize: 14, color: Colors.grey)),
                SizedBox(width: 10),
                Text("조회수 0", style: TextStyle(fontSize: 14, color: Colors.grey)),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: (){},
                        icon: Icon(Icons.sms_outlined, color: Colors.grey),
                        iconSize: 25,
                        padding: EdgeInsets.zero, // 패딩 설정
                        constraints: BoxConstraints(), // 패딩 설정
                      ),
                    ],
                  ),
                )
              ],
            ),

          ],
        ),
      ),
    );
  }
}

// 커뮤니티 게시글 리스트
class CommunityPostList extends StatelessWidget {
  const CommunityPostList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommunityPostItem(),
        CommunityPostItem(),
        CommunityPostItem(),
      ],
    );
  }
}
