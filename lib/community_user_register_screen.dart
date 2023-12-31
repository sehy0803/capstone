import 'package:capstone/custom_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommunityRegisterScreen extends StatefulWidget {
  const CommunityRegisterScreen({super.key, required String boardType});

  @override
  State<CommunityRegisterScreen> createState() =>
      _CommunityRegisterScreenState();
}

class _CommunityRegisterScreenState extends State<CommunityRegisterScreen> {
  final _authentication = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String uploaderUID = '';
  String title = '';
  String content = '';


  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: DarkColors.basic,
        title:
        Text('유저 게시판', style: TextStyle(color: Colors.white, fontSize: 20)),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.close),
          iconSize: 30,
          color: Colors.white,
        ),
        actions: [
          // 게시글 등록 버튼
          TextButton(
            onPressed: () {
              showConfirmationDialog(context);
            },
            child:
            Text('등록', style: TextStyle(fontSize: 18, color: Colors.amber)),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                maxLength: 30,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                    hintText: '제목',
                    hintStyle:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onChanged: (value) {
                  title = value;
                },
              ),
              SizedBox(height: 10),
              TextField(
                maxLength: 200,
                style: TextStyle(fontSize: 18),
                decoration: InputDecoration(
                    hintText: '내용', hintStyle: TextStyle(fontSize: 18)),
                keyboardType: TextInputType.multiline,
                maxLines: 20,
                onChanged: (value) {
                  content = value;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  //============================================================================
  // Firestore에서 uploaderUID(현재 로그인한 사용자의 UID)를 가져오는 함수
  void getCurrentUser() async {
    final user = _authentication.currentUser;
    final userDocument = await _firestore.collection('User').doc(user!.uid).get();
    if (userDocument.exists) {
      uploaderUID = user!.uid;
    }
  }

  // firestore에 게시글 정보 저장
  void _saveCommunityData() async {
    if (title.isNotEmpty && content.isNotEmpty) {
      try {
        int views = 0;
        int likes = 0;
        int comments = 0;
        Timestamp createDate = Timestamp.now();
        await _firestore.collection('UserCommunity').add({
          'uploaderUID': uploaderUID,
          'title': title,
          'content': content,
          'views': views,
          'likes': likes,
          'comments': comments,
          'createDate': createDate,
        });
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

  // 게시물 등록 확인 AlertDialog 표시
  void showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('등록하기'),
          content: Text('게시물을 등록하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                _saveCommunityData();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('게시물이 등록되었습니다.',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                    dismissDirection: DismissDirection.up,
                    duration: Duration(milliseconds: 15000), // 경매 시간 제한
                    backgroundColor: Colors.black,
                  ),
                );
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }
}
