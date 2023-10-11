import 'package:capstone/home_screen.dart';
import 'package:capstone/terms_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyPageScreen());
}

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text("마이페이지",
                  style: TextStyle(color: Colors.black, fontSize: 25)
              ),
              backgroundColor: Colors.white,
              floating: true,
              pinned: false,
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                [
                  Line(),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        UserProfileInfo(), // 사용자 정보, 프로필 수정 부분
                        SizedBox(height: 20),
                        Line(),
                        FavoriteAndMore(), // 관심목록, 더보기 글씨 부분
                        AuctionProductList(), // 경매 상품 리스트
                        SizedBox(height: 20),
                        Line(),
                        MyAuctionHistoryTextAndMore(),
                        AuctionProductList(),
                        SizedBox(height: 20),
                        Line(),
                        MyPostListTextAndMore(),
                        MyPostList(),


                      ],
                    ),
                  )
                  ],
                ),
              ),
          ],
        ),
        bottomNavigationBar: HomeBottomAppBar(),
      ),
    );
  }
}

// ======================================================= 커스텀 위젯 =======================================================

// 사용자 정보, 프로필 수정 부분
class UserProfileInfo extends StatelessWidget {
  const UserProfileInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 100,
          height: 100,
          color: Colors.black12,
        ),
        SizedBox(width: 15),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('닉네임', style: TextStyle(fontSize: 20)),
                  Text('010-1234-0909', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
              TextButton(onPressed: (){}, child: Text('프로필 수정', style: TextStyle(fontSize: 16,color: Colors.black)))
            ],
          ),
        ),

      ],
    );
  }
}

// 관심목록, 더보기 글씨 부분
class FavoriteAndMore extends StatelessWidget {
  const FavoriteAndMore ({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('관심목록', style: TextStyle(fontSize: 20)),
        TextButton(onPressed: (){}, child: Text('더보기', style: TextStyle(fontSize: 16,color: Colors.grey)))
      ],
    );
  }
}

// 상품 리스트 아이템의 상품 정보
class ProductListItemInfo extends StatelessWidget {
  const ProductListItemInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('괜찮은 의자(상품 제목)', style: TextStyle(fontSize: 14)),
                Text('경매일 2023-09-31', style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('시작가', style: TextStyle(fontSize: 14)),
                Text('150,000원', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xff18a4f0)))
              ],
            )

          ],
        ),
      ),
    );
  }
}

// 경매 상품 리스트
class AuctionProductList extends StatelessWidget {
  const AuctionProductList({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container( // 상품 이미지 들어갈 자리
          width: 100,
          height: 100,
          color: Colors.black12,
        ),
        SizedBox(width: 15),
        ProductListItemInfo(), // 상품 리스트 아이템의 상품 정보
      ],
    );
  }
}

// 내 경매내역, 더보기 글씨 부분
class MyAuctionHistoryTextAndMore extends StatelessWidget {
  const MyAuctionHistoryTextAndMore ({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('내 경매내역', style: TextStyle(fontSize: 20)),
        TextButton(onPressed: (){}, child: Text('더보기', style: TextStyle(fontSize: 16,color: Colors.grey)))
      ],
    );
  }
}

// 내가 쓴 글, 더보기 글씨 부분
class MyPostListTextAndMore extends StatelessWidget {
  const MyPostListTextAndMore ({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('내가 쓴 글', style: TextStyle(fontSize: 20)),
        TextButton(onPressed: (){}, child: Text('더보기', style: TextStyle(fontSize: 16,color: Colors.grey)))
      ],
    );
  }
}

// 내가 쓴 글 리스트
class MyPostList extends StatelessWidget {
  const MyPostList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('게시글1(제목)', style: TextStyle(fontSize: 16)),
          Text('게시글2게시글2(제목)', style: TextStyle(fontSize: 16)),
          Text('게시글3게시글3게시글3(제목)', style: TextStyle(fontSize: 16)),
          Text('게시글4(제목)', style: TextStyle(fontSize: 16)),
          Text('게시글5(제목)', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
