import 'package:flutter/material.dart';

class CommunityRegisterScreen extends StatelessWidget {
  const CommunityRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 뒤로 가기 버튼을 누를 때의 동작을 정의
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.close),
            iconSize: 30,
            color: Colors.black,
          ),
          actions: [
            CommunityRegisterButton(),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                // 위젯 추가
                CommunityTitleInputText(),
                CommunityContentInputText(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ========================================== 커스텀 위젯 ==========================================

// 게시글 등록 버튼
class CommunityRegisterButton extends StatelessWidget {
  const CommunityRegisterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: (){},
        child: Text('등록',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue
            )
        )
    );
  }
}

// 게시글 제목
class CommunityTitleInputText extends StatelessWidget {
  const CommunityTitleInputText({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: '제목',
      ),
      maxLength: 20,
    );
  }
}

// 게시글 내용
class CommunityContentInputText extends StatelessWidget {
  const CommunityContentInputText({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: '내용',
        border: InputBorder.none,
      ),
      keyboardType: TextInputType.multiline,
      maxLines: null,
      maxLength: 300,
    );
  }
}

