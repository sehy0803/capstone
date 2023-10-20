import 'package:flutter/material.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: Text('관심목록',
                style: TextStyle(color: Colors.black, fontSize: 20)),
            backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // 위젯 추가
              FavoriteList()




            ],
          ),

        ),
      ),
    );
  }
}

// ========================================== 커스텀 위젯 ==========================================

// 관심목록 item
class FavoriteItem extends StatelessWidget {
  const FavoriteItem({super.key});

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
                            Text("경매종료일", style: TextStyle(fontSize: 16)),
                            Text("2023-10-18", style: TextStyle(fontSize: 16))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("즉시거래가", style: TextStyle(fontSize: 16)),
                            Text("100,000원", style: TextStyle(fontSize: 16, color: Colors.lightBlue))
                          ],
                        ),
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

// 관심목록 리스트
class FavoriteList extends StatelessWidget {
  const FavoriteList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FavoriteItem(), // 최근 경매 결과 - 경매 정보
        FavoriteItem(),
        FavoriteItem()
      ],
    );
  }
}
