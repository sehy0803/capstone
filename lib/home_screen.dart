import 'package:flutter/material.dart';

void main() {
  runApp(const HomeScreen());
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text("Logo",
                  style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold)
              ),
              backgroundColor: Colors.white,
              floating: true,
              pinned: false,
              actions: [
                IconButton(
                    icon: Icon(Icons.search),
                    color: Colors.black,
                    iconSize: 30,
                    onPressed: () {
                      print('click');
                    }
                ),
              ],
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Container(
                    height: 160,
                    color: Colors.black12,
                    child: Column(
                      children: [
                        Text('실시간 인기 경매 Image',
                          style: TextStyle(),
                          textAlign: TextAlign.center,
                        ),
                        Align(
                          alignment: Alignment.bottomRight, // 우측 하단으로 정렬
                          child: TextButton(
                            onPressed: () {},
                            child: Text('이미지 개수'),
                          ),
                        ),
                      ],
                    )
                  ),
                  // ====================위젯 추가 자리====================
                  CategoryIcons(),
                  CategoryIcons(),
                  RecentAuctionResults(),
                  ItemList(),
                  ItemList(),
                  ItemList(),


                ],
              )
            )
          ]
        ),

        bottomNavigationBar: HomeBottomAppBar(),
      ),
    );
  }
}

// ======================================================= 커스텀 위젯 =======================================================

// 최근 경매 결과에 표시할 상품 리스트
class ItemList extends StatelessWidget {
  const ItemList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Row(
          children: [
            //Image.asset('assets/Tshirts.jpeg', width: 120, height: 120),
            Container(width: 120, height: 120, color: Colors.black12),
            Container(
                width: 210,
                height: 120,
                margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("괜찮은 의자", style: TextStyle(fontSize: 18)),
                    Text("2023-09-02", style: TextStyle(fontSize: 18, color: Colors.grey)),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("시작가", style: TextStyle(fontSize: 18)),
                        Text("150,000원", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("낙찰가", style: TextStyle(fontSize: 18)),
                        Text("210,000원", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
                      ],
                    )
                  ],
                )
            )
          ],
        )
    );
  }
}


// 카테고리로 이동할 수 있는 아이콘버튼들
class CategoryIcons extends StatelessWidget {
  const CategoryIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(onPressed: (){}, icon: Icon(Icons.home), iconSize: 60),
            IconButton(onPressed: (){}, icon: Icon(Icons.home), iconSize: 60),
            IconButton(onPressed: (){}, icon: Icon(Icons.home), iconSize: 60),
            IconButton(onPressed: (){}, icon: Icon(Icons.home), iconSize: 60),
          ],
        )
    );
  }
}

// 최근 경매 결과 글씨 부분
class RecentAuctionResults extends StatelessWidget {
  const RecentAuctionResults({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("최근 경매 결과",
                style: TextStyle(fontSize: 24)),
            TextButton(onPressed: (){}, child: Text("더보기", style: TextStyle(fontSize: 20, color: Colors.grey))),
          ],
        )
    );
  }
}

// BottomAppBar
class HomeBottomAppBar extends StatelessWidget {
  const HomeBottomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(onPressed: (){}, icon: Icon(Icons.home), iconSize: 40),
          IconButton(onPressed: (){}, icon: Icon(Icons.launch), iconSize: 40),
          IconButton(onPressed: (){}, icon: Icon(Icons.chat), iconSize: 40),
          IconButton(onPressed: (){}, icon: Icon(Icons.favorite), iconSize: 40),
          IconButton(onPressed: (){}, icon: Icon(Icons.person), iconSize: 40),
        ],
      ),
    );
  }
}
