import 'package:capstone/category_screen.dart';
import 'package:capstone/chat_list_screen.dart';
import 'package:capstone/community_screen.dart';
import 'package:capstone/custom_widget.dart';
import 'package:capstone/favorite_list_screen.dart';
import 'package:capstone/home_screen.dart';
import 'package:capstone/my_page_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
class TabScreen extends StatefulWidget {

  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  // 현재 로그인된 유저의 정보를 저장
  void getCurrentUser(){
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        loggedUser = user;
        print(loggedUser!.email);
      }
    } catch(e){
      print(e);
    }
  }

  // 현재 선택된 페이지
  int _selectedIndex = 0;

  // 버튼이 클릭되면 해당하는 페이지로 이동하는 동작을 하는 클래스
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 이동할 페이지
  final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    CategoryScreen(),
    CommunityScreen(),
    ChatListScreen(),
    FavoriteScreen(),
    MyPageScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _widgetOptions[_selectedIndex], // 현재 선택된 페이지를 표시
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: DarkColors.basic,
          type: BottomNavigationBarType.fixed, // 애니메이션 효과 제거
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey[700],
          selectedFontSize: 12,
          unselectedFontSize: 12,
          currentIndex: _selectedIndex,
          showUnselectedLabels: true,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
            BottomNavigationBarItem(icon: Icon(Icons.view_list), label: '카테고리'),
            BottomNavigationBarItem(icon: Icon(Icons.forum), label: '커뮤니티'),
            BottomNavigationBarItem(icon: Icon(Icons.sms), label: '채팅'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '관심목록'),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: '마이페이지'),
          ],
        )
    );
  }
}