import 'package:capstone/auction_regist_screen.dart';
import 'package:capstone/search_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: Text('홈',
                style: TextStyle(color: Colors.black, fontSize: 20)),
            backgroundColor: Colors.white,
            actions: [
              IconButton(
                onPressed: () { // 버튼 클릭 시
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchScreen()),
                  );
                },
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
              TopImageBox(),
              Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CategoryNavigation(), // 카테고리 이동 버튼
                      RecentAuctionList(), // 최근 경매 결과
                    ],
                  )
              ),
            ],
          )
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AuctionRegistScreen()),
            );
          },
          icon: Icon(Icons.add),
          label: Text('경매 글쓰기', style: TextStyle(fontSize: 18)),
          backgroundColor: Colors.lightBlue,
        ),
      ),
    );
  }
}

// ========================================== 커스텀 위젯 ==========================================

// IconButton(
// onPressed: (){},
// icon: Icon(Icons.favorite),
// iconSize: 35,
// color: Colors.black
// ),

// 상단 이미지
class TopImageBox extends StatelessWidget {
  const TopImageBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      color: Colors.lightBlue,
    );
  }
}


// 카테고리 이동 버튼
class CategoryNavigation extends StatelessWidget {
  const CategoryNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: (){},
              icon: Icon(Icons.add),
              iconSize: 50,
              padding: EdgeInsets.zero, // 패딩 설정
              constraints: BoxConstraints(), // 패딩 설정
            ),
            IconButton(
              onPressed: (){},
              icon: Icon(Icons.add),
              iconSize: 50,
              padding: EdgeInsets.zero, // 패딩 설정
              constraints: BoxConstraints(), // 패딩 설정
            ),
            IconButton(
              onPressed: (){},
              icon: Icon(Icons.add),
              iconSize: 50,
              padding: EdgeInsets.zero, // 패딩 설정
              constraints: BoxConstraints(), // 패딩 설정
            ),
            IconButton(
              onPressed: (){},
              icon: Icon(Icons.add),
              iconSize: 50,
              padding: EdgeInsets.zero, // 패딩 설정
              constraints: BoxConstraints(), // 패딩 설정
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: (){},
              icon: Icon(Icons.add),
              iconSize: 50,
              padding: EdgeInsets.zero, // 패딩 설정
              constraints: BoxConstraints(), // 패딩 설정
            ),
            IconButton(
              onPressed: (){},
              icon: Icon(Icons.add),
              iconSize: 50,
              padding: EdgeInsets.zero, // 패딩 설정
              constraints: BoxConstraints(), // 패딩 설정
            ),
            IconButton(
              onPressed: (){},
              icon: Icon(Icons.add),
              iconSize: 50,
              padding: EdgeInsets.zero, // 패딩 설정
              constraints: BoxConstraints(), // 패딩 설정
            ),
            IconButton(
              onPressed: (){},
              icon: Icon(Icons.add),
              iconSize: 50,
              padding: EdgeInsets.zero, // 패딩 설정
              constraints: BoxConstraints(), // 패딩 설정
            ),
          ],
        ),
        SizedBox(height: 20)
      ],
    );
  }
}

// 최근 경매 결과 - 경매 정보 아이템
class RecentAuctionItem extends StatelessWidget {
  const RecentAuctionItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white, // 배경색
            borderRadius: BorderRadius.circular(10), // 모서리 둥글게
            border: Border.all(
              color: Colors.black, // 테두리 색상
              width: 1.0, // 테두리 두께
            ),
          ),
        ),
        Expanded(
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white, // 배경색
                borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                border: Border.all(
                  color: Colors.black12, // 테두리 색상
                  width: 1.0, // 테두리 두께
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text("경매 제목", style: TextStyle(fontSize: 18)),
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
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("즉시거래가", style: TextStyle(fontSize: 16)),
                            Text("100,000원", style: TextStyle(fontSize: 16))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("낙찰가", style: TextStyle(fontSize: 16)),
                            Text("100,000원", style: TextStyle(fontSize: 16, color: Colors.lightBlue))
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
        )
      ],
    );
  }
}

// 최근 경매 결과 - 경매 정보 리스트
class RecentAuctionList extends StatelessWidget {
  const RecentAuctionList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            width: double.infinity,
            child: Text("최근 경매 결과", style: TextStyle(fontSize: 20))
        ),
        SizedBox(height: 10),
        RecentAuctionItem(), // 최근 경매 결과 - 경매 정보
        RecentAuctionItem(),
        RecentAuctionItem()
      ],
    );
  }
}
