import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            title: Text('카테고리',
                style: TextStyle(color: Colors.black, fontSize: 20)),
            backgroundColor: Colors.white,
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
