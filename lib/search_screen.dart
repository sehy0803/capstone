import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 빈 곳 터치시 키패드 사라짐
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            // 검색어 입력창
            title: TextFormField(
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  ),
                  hintText: '검색어를 입력해주세요.',
                  hintStyle: TextStyle(fontSize: 16, color: Colors.grey[400]!),
                  contentPadding: EdgeInsets.all(10)),
            ),
            backgroundColor: Colors.white,
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios),
                iconSize: 30,
                color: Colors.black,
                padding: EdgeInsets.all(0)),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.search),
                iconSize: 30,
                color: Colors.black,
              ),
            ]),
        body: SingleChildScrollView(
            child: Column(
          children: [],
        )),
      ),
    );
  }
}

// ========================================== 커스텀 위젯 ==========================================
