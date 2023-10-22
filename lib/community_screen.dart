import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Community_Screen extends StatelessWidget {
  const Community_Screen({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(left: 16.0), // 왼쪽 들여쓰기 설정
            child: Text(
              '커뮤니티',
              style: TextStyle(color: Colors.black, fontSize: 24.0), // 글꼴 크기 조절
            ),
          ),
          backgroundColor: Colors.white,
          centerTitle: false,
          titleSpacing: 0.0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 45.0), // 오른쪽 들여쓰기 설정
              child: IconButton(
                icon: Padding(
                  padding: const EdgeInsets.only(left: 8.0), // 검색 아이콘 왼쪽 들여쓰기 설정
                  child: Icon(Icons.search, color: Colors.black, size: 45.0),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(onPressed: (){}, icon: Icon(Icons.home)),
              IconButton(onPressed: (){}, icon: Icon(Icons.launch)),
              IconButton(onPressed: (){}, icon: Icon(Icons.chat)),
              IconButton(onPressed: (){}, icon: Icon(Icons.favorite)),
              IconButton(onPressed: (){}, icon: Icon(Icons.person)),

            ],
          ),
        ),
      ),
    );
  }
}