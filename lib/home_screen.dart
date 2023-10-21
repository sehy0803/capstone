import 'package:capstone/auction_register_screen.dart';
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
                  padding: const EdgeInsets.all(30),
                  child: CategoryNavigation(), // 카테고리 이동 버튼,
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: RecentAuctionList(),
              ), // 최근 경매 결과
            ],
          )
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AuctionRegisterScreen()),
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
        SizedBox(height: 30),
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
      ],
    );
  }
}

// 최근 경매 결과 - 경매 정보 아이템
class RecentAuctionItem extends StatelessWidget {
  const RecentAuctionItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Row(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white, // 배경색
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
      ),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("최근 경매 결과", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                onPressed: (){},
                icon: Icon(Icons.arrow_forward_ios_rounded),
                iconSize: 25,
                color: Colors.black,
                padding: EdgeInsets.zero, // 패딩 설정
                constraints: BoxConstraints(), // 패딩 설정
              ),
            ],
          ),
        ),
        RecentAuctionItem(), // 최근 경매 결과 - 경매 정보
        RecentAuctionItem(),
        RecentAuctionItem()
      ],
    );
  }
}
