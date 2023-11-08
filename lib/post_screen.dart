import 'package:flutter/material.dart';

// void main() {
//   runApp(const PostScreen());
// }

class PostScreen extends StatelessWidget {
  const PostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            title: Text('게시글 제목',
                style: TextStyle(color: Colors.black, fontSize: 20)),
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: (){
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios),
              iconSize: 30,
              color: Colors.black,
            ),
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

