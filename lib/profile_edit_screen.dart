import 'package:capstone/my_page_screen.dart';
import 'package:flutter/material.dart';

class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
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
        body: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 위젯 추가
                EditTextField(), // 수정할 내용 입력칸
                EditCompleteButton(), // 수정 완료 버튼
              ]
          ),
        )


      ),
    );
  }
}

// ========================================== 커스텀 위젯 ==========================================

// 수정할 내용
class EditTextField extends StatelessWidget {
  const EditTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center( // 프로필 이미지
            child: Icon(Icons.account_circle, size: 100, color: Colors.black12)
        ),
        SizedBox(height: 50),
        Row(
          children: [
            Text("이메일",
                style: TextStyle(fontSize: 16)),
            SizedBox(width: 50),
            Text("사용자 이메일",
                style: TextStyle(fontSize: 16, color: Colors.grey))
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Text("비밀번호",
                style: TextStyle(fontSize: 16)),
            SizedBox(width: 35),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: '변경할 비밀번호', // 초기엔 사용자 비밀번호 표시
                ),
              ),
            )
          ],
        ),
        Row(
          children: [
            Text("닉네임",
                style: TextStyle(fontSize: 16)),
            SizedBox(width: 50),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: '변경할 닉네임', // 초기엔 사용자 닉네임 표시
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}

// 수정 완료 버튼
class EditCompleteButton extends StatelessWidget {
  const EditCompleteButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300,
        height: 50,
        child: ElevatedButton(
          onPressed: () { // 버튼 클릭 시
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyPageScreen()),
            );
          },
          child: Text("수정완료",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor : Colors.lightBlue,
          ),
        ),
      ),
    );
  }
}
