import 'package:flutter/material.dart';

void main() {
  runApp(const AuctionScreen());
}

class AuctionScreen extends StatelessWidget {
  const AuctionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            title: Text('경매',
                style: TextStyle(color: Colors.black, fontSize: 20)),
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: (){},
              icon: Icon(Icons.arrow_back_ios_new_rounded),
              iconSize: 30,
              color: Colors.black,
            ),
        ),
        body: SingleChildScrollView(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // 위젯 추가
                  Container(
                    height: 150,
                    color: Colors.lightBlue,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(Icons.account_circle, size: 60),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("닉네임", style: TextStyle(fontSize: 18)),
                                Text("등록일 2023-10-18 20:33",
                                    style: TextStyle(fontSize: 14, color: Colors.grey))
                              ],
                            ),
                            IconButton(
                              onPressed: (){},
                              icon: Icon(Icons.favorite, color: Colors.redAccent),
                              iconSize: 30,
                              padding: EdgeInsets.zero, // 패딩 설정
                              constraints: BoxConstraints(), // 패딩 설정
                            ),
                          ],
                        )


                      ],
                    ),
                  )
                  






                ],
              ),
            )


        ),
      ),
    );
  }
}

// ========================================== 커스텀 위젯 ==========================================

