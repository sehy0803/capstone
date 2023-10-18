import 'package:capstone/home_screen.dart';
import 'package:capstone/terms_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ProductInfo());
}

class ProductInfo extends StatelessWidget {
  const ProductInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.white,
                leading: IconButton(
                    onPressed: () {Navigator.pop(context);},
                    icon: Icon(Icons.arrow_back),
                    iconSize: 30,
                    color: Colors.black
                ),
                floating: true,
                pinned: false,
              ),
              SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Container(
                          height: 160,
                          color: Colors.black12,
                          child: Text('Image'),
                      ),
                      // ====================위젯 추가 자리====================
                      OtherInfo(),
                      // 구분선
                      Line(),
                      PostTitleAndContent(),
                      Line(),
                      StartPriceText(),
                      AuctionAttendButton()
                    ],
                  )
              )
            ]
        ),
      ),
    );
  }
}

// ======================================================= 커스텀 위젯 =======================================================

// 사용자 정보, 경매일, 하트 등 기타정보
class OtherInfo extends StatelessWidget {
  const OtherInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Icon(Icons.account_circle, size: 70),
          SizedBox(width: 10),
          SizedBox(
            width: 240,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('진한 헛개차(닉네임)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('작성일 2023-09-01 12:30',
                    style: TextStyle(color: Colors.grey, fontSize: 18)),
                Text('경매일 2023-09-02 15:30',
                    style: TextStyle(color: Color(0xff18a4f0), fontSize: 18))
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                  onPressed: (){},
                  icon: Icon(Icons.favorite),
                  iconSize: 35,
                  color: Colors.black
              ),
              Text('5', style: TextStyle(fontSize: 20)),
            ],

          ),

        ]
      )
    );
  }
}


// 글 제목, 내용
class PostTitleAndContent extends StatelessWidget {
  const PostTitleAndContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('제목 입니다', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text('내용 입니다\n내용 입니다\n내용 입니다\n내용 입니다\n내용 입니다\n내용 입니다\n내용 입니다\n내용 입니다\n내용 입니다\n',
                    style: TextStyle(fontSize: 20))
            )
          ],
        )
    );
  }
}


// 시작가 부분
class StartPriceText extends StatelessWidget {
  const StartPriceText({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('시작가', style: TextStyle(fontSize: 24)),
            Text('150,000원',
                style: TextStyle(fontSize: 24,
                    color: Color(0xff18a4f0),
                    fontWeight: FontWeight.bold))
          ],
        )
    );
  }
}

// 경매참여 버튼
class AuctionAttendButton extends StatelessWidget {
  const AuctionAttendButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: () {},
        child: Text("경매 참여",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)
        ),
        style: ButtonStyle(
          backgroundColor : MaterialStateProperty.all(Color(0xff18a4f0)),
          minimumSize: MaterialStateProperty.all(Size(300, 60)),
        ),
      ),
    );
  }
}

