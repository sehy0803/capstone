import 'package:capstone/home_screen.dart';
import 'package:capstone/category_screen.dart';
import 'package:capstone/community_screen.dart';
import 'package:capstone/favorite_screen.dart';
import 'package:capstone/my_page_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const test());
}

class test extends StatefulWidget {
  const test({Key? key}) : super(key: key);

  @override
  _testState createState() => _testState();
}

class _testState extends State<test> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static List<Widget> pages = <Widget>[
    HomeScreen(),
    CategoryScreen(),
    CommunityScreen(),
    FavoriteScreen(),
    MyPageScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: pages[_selectedIndex],
        bottomNavigationBar: BottomBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}

// ========================================== 커스텀 위젯 ==========================================

class BottomBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onItemTapped;

  const BottomBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Colors.lightBlue,
      unselectedItemColor: Colors.grey,
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.view_list), label: '카테고리'),
        BottomNavigationBarItem(icon: Icon(Icons.forum), label: '커뮤니티'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '즐겨찾기'),
        BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: '마이페이지'),
      ],
    );
  }
}