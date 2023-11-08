// 스크롤 없이 기본
import 'package:flutter/material.dart';

class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            title: Text('프로필 수정',
                style: TextStyle(color: Colors.black, fontSize: 20)),
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: (){Navigator.pop(context);},
              icon: Icon(Icons.close),
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

