import 'package:capstone/auction_register_screen.dart';
import 'package:capstone/community_register_screen.dart';
import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int _currentTabIndex = 0; // 현재 선택된 탭을 저장하는 변수

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('커뮤니티', style: TextStyle(color: Colors.black, fontSize: 20)),
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          bottom: TabBar(
            tabs: [
              Tab(text: '경매 게시판'),
              Tab(text: '유저 게시판'),
            ],
            labelColor: Colors.black,
            indicatorColor: Colors.lightBlue,
            onTap: (index) {
              // 탭이 선택되었을 때 호출되는 콜백 함수
              setState(() {
                _currentTabIndex = index;
              });
            },
          ),
        ),
        body: TabBarView(
          children: [
            // 경매 게시판
            ListView(
              children: [
                Text('경매'),
                Text('경매'),
                Text('경매'),
                Text('경매'),
                Text('경매'),
              ],
            ),

            // 유저 게시판
            ListView(
              children: [
                Text('유저'),
                Text('유저'),
                Text('유저'),
                Text('유저'),
                Text('유저'),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_currentTabIndex == 0) {
              // 경매 게시판 탭이 선택된 상태면 경매 게시글 등록 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AuctionRegisterScreen(boardType: '경매 게시판')),
              );
            } else {
              // 유저 게시판 탭이 선택된 상태면 유저 게시글 등록 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CommunityRegisterScreen(boardType: '유저 게시판')),
              );
            }
          },
          backgroundColor: Colors.lightBlue,
          child: Icon(Icons.edit),
        ),
      ),
    );
  }
}
