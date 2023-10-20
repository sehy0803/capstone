import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: (){
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios),
              iconSize: 30,
              color: Colors.black,
            ),
            actions: [
              IconButton(
                onPressed: (){},
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




              ],
            )


        ),
      ),
    );
  }
}

// ========================================== 커스텀 위젯 ==========================================
