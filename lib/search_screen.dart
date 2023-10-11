import 'package:capstone/home_screen.dart';
import 'package:capstone/my_page_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const SearchScreen());
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: SearchTextField()
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                AuctionProductList(),
                SizedBox(height: 20),
                AuctionProductList(),
                SizedBox(height: 20),
                AuctionProductList(),
                SizedBox(height: 20),
                AuctionProductList(),
                SizedBox(height: 20),
                AuctionProductList(),
                SizedBox(height: 20),
                AuctionProductList(),

              ],
            ),
          ),






        ),
        bottomNavigationBar: HomeBottomAppBar(),
      ),
    );
  }
}

// ======================================================= 커스텀 위젯 =======================================================

// AppBar - 뒤로가기 버튼, 검색창, 검색버튼
class SearchTextField extends StatelessWidget {
  const SearchTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: (){
              Navigator.pop(context);
              },
        ),
        Container(
          width: 250,
          height: 40,
          child: TextField(
              style: TextStyle(height: 0.6),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black12,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(width: 1, color: Colors.black12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(width: 1, color: Colors.black12),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
              keyboardType: TextInputType.number
          ),
        ),
        IconButton(onPressed: (){}, icon: Icon(Icons.search, color: Colors.black, size: 30)),
      ],
    );
  }
}
