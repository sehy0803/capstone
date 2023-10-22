import 'package:capstone/auction_register_screen.dart';
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
        backgroundColor: Colors.white,
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
              child: Column(
                children: [
                  // 위젯 추가
                  AuctionPostImage(),
                  AuctionUserInfo(),
                  Line(),
                  AuctionTitleAndContent(),
                  Line(),
                  // 댓글









                ],
              ),
        )

      ),
    );
  }
}

// ========================================== 커스텀 위젯 ==========================================

// 경매 게시글에 등록된 이미지
class AuctionPostImage extends StatelessWidget {
  const AuctionPostImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      color: Colors.lightBlue,
    );
  }
}


// 경매를 등록한 사용자 정보
class AuctionUserInfo extends StatelessWidget {
  const AuctionUserInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Icon(Icons.account_circle, size: 60),
          SizedBox(width: 10),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("닉네임", style: TextStyle(fontSize: 18)),
                    Text("등록일 2023-10-22", style: TextStyle(fontSize: 14, color: Colors.grey)),
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
            ),
          )
        ],
      ),
    );
  }
}

// 경매 게시글 제목, 내용
class AuctionTitleAndContent extends StatelessWidget {
  const AuctionTitleAndContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("제목", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("내용", style: TextStyle(fontSize: 16))
          ],
        ),
      ),
    );
  }
}
