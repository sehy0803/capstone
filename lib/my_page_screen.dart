import 'package:capstone/profile_edit_screen.dart';
import 'package:flutter/material.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('마이페이지',
              style: TextStyle(color: Colors.black, fontSize: 20)),
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    // 위젯 추가
                    UserProfileInfo()





                  ],
                ),
              ),
            )


        ),
      ),
    );
  }
}

// ========================================== 커스텀 위젯 ==========================================

// 사용자 프로필 정보
class UserProfileInfo extends StatelessWidget {
  const UserProfileInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.account_circle, size: 80), // 사용자 프로필 이미지
        SizedBox(width: 10),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("닉네임", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.black12,
                      width: 1.0
                  ),
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileEditScreen()),
                    );
                  },
                  icon: Icon(Icons.settings, size: 30, color: Colors.grey),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
