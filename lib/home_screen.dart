import 'package:capstone/search_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text('홈', style: TextStyle(color: Colors.black, fontSize: 20)),
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchScreen()),
                );
              },
              icon: Icon(Icons.search),
              iconSize: 30,
              color: Colors.black,
            ),
          ]),
      body: SingleChildScrollView(
          child: Column(
        children: [
          // 위젯 추가
          // 상단 이미지
          Container(
            height: 150,
            color: Colors.blue[50],
          ),

          // 카테고리 버튼
          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.add),
                      iconSize: 50,
                      padding: EdgeInsets.zero,
                      // 패딩 설정
                      constraints: BoxConstraints(), // 패딩 설정
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.add),
                      iconSize: 50,
                      padding: EdgeInsets.zero,
                      // 패딩 설정
                      constraints: BoxConstraints(), // 패딩 설정
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.add),
                      iconSize: 50,
                      padding: EdgeInsets.zero,
                      // 패딩 설정
                      constraints: BoxConstraints(), // 패딩 설정
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.add),
                      iconSize: 50,
                      padding: EdgeInsets.zero,
                      // 패딩 설정
                      constraints: BoxConstraints(), // 패딩 설정
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.add),
                      iconSize: 50,
                      padding: EdgeInsets.zero,
                      // 패딩 설정
                      constraints: BoxConstraints(), // 패딩 설정
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.add),
                      iconSize: 50,
                      padding: EdgeInsets.zero,
                      // 패딩 설정
                      constraints: BoxConstraints(), // 패딩 설정
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.add),
                      iconSize: 50,
                      padding: EdgeInsets.zero,
                      // 패딩 설정
                      constraints: BoxConstraints(), // 패딩 설정
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.add),
                      iconSize: 50,
                      padding: EdgeInsets.zero,
                      // 패딩 설정
                      constraints: BoxConstraints(), // 패딩 설정
                    ),
                  ],
                ),
              ],
            ), // 카테고리 이동 버튼,
          ),

          // 경매 게시판
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('경매 게시판', style: TextStyle(fontSize: 20, height: 1.3)),
                  ],
                ),

                // 경매 게시글 들어갈 곳
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Container(
                    height: 500,
                    color: Colors.blue[50],
                  ),
                )
              ],
            ),
          ), // 최근 경매 결과
        ],
      )),
    );
  }
}

// ========================================== 커스텀 위젯 ==========================================
