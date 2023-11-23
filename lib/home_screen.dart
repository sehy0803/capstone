import 'package:capstone/search_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Image.asset('assets/images/logo.png', width: 150),
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
          SizedBox(
            height: 150,
            child: Image.asset('assets/images/logo.png', width: 100),
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
                    color: Colors.black12,
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
