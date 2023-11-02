import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommunityRegisterScreen extends StatefulWidget {
  const CommunityRegisterScreen({super.key, required String boardType});

  @override
  State<CommunityRegisterScreen> createState() =>
      _CommunityRegisterScreenState();
}

class _CommunityRegisterScreenState extends State<CommunityRegisterScreen> {
  final _firestore = FirebaseFirestore.instance;

  // 유저가 입력한 게시글 정보를 저장할 변수
  String title = '';
  String content = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('유저 게시판', style: TextStyle(color: Colors.black, fontSize: 20)),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.close),
          iconSize: 30,
          color: Colors.black,
        ),
        actions: [
          // 게시글 등록 버튼
          TextButton(
            onPressed: () {
              // 파이어스토어에 데이터 저장
              _saveCommunityData();
            },
            child: Text('등록',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.lightBlue)),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Column(
                children: [
                  TextField(
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                        hintText: '제목',
                        hintStyle: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    onChanged: (value) {
                      title = value;
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    style: TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                        hintText: '내용', hintStyle: TextStyle(fontSize: 18)),
                    keyboardType: TextInputType.multiline,
                    maxLines: 50,
                    onChanged: (value) {
                      content = value;
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // firestore에 게시글 데이터 저장
  void _saveCommunityData() async {
    if (title.isNotEmpty && content.isNotEmpty) {
      try {
        await _firestore.collection('UserCommunity').add({'title': title, 'content': content});
        Navigator.pop(context);
      } catch (e) {
        print('데이터 저장 오류: $e');
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('알림'),
            content: Text('제목과 내용을 모두 입력하세요.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
    }
  }
}