import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommunityRegisterScreen extends StatefulWidget {
  const CommunityRegisterScreen({super.key, required String boardType});

  @override
  State<CommunityRegisterScreen> createState() =>
      _CommunityRegisterScreenState();
}

class _CommunityRegisterScreenState extends State<CommunityRegisterScreen> {
  final _authentication = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // 유저가 입력한 게시글 정보를 저장할 변수
  String title = ''; // 제목
  String content = ''; // 내용
  String uploaderImageURL = ''; // 사용자 프로필 사진 URL
  String uploadernickname = ''; // 사용자 닉네임
  String createDate = ''; // 글을 올린 날짜와 시간
  int views = 0; // 조회수
  int favorite = 0; // 찜 횟수
  int comments = 0; // 댓글 수
  String photoURL = ''; // 게시글 사진

  @override
  void initState() {
    super.initState();
    getCurrentUser(); // Firestore에서 사용자 정보 가져오기
    setCreateDate(); // 현재 시간으로 createDate 설정
  }

  // Firestore에서 사용자 정보 가져오기
  void getCurrentUser() async {
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        final userDocument =
            await _firestore.collection('User').doc(user.uid).get();
        if (userDocument.exists) {
          uploaderImageURL = userDocument['imageURL'] ?? '';
          uploadernickname = userDocument['nickname'] ?? '';
        }
      }
    } catch (e) {
      print('사용자 정보 가져오기 오류: $e');
    }
  }

  // 현재 시간으로 createDate 설정
  void setCreateDate() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    createDate = formatter.format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title:
            Text('유저 게시판', style: TextStyle(color: Colors.black, fontSize: 20)),
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
              // 게시물 등록 확인 AlertDialog 표시
              showConfirmationDialog(context);
            },
            child: Text('등록',
                style: TextStyle(fontSize: 18, color: Colors.lightBlue)),
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

  // firestore에 게시글 정보 저장
  void _saveCommunityData() async {
    if (title.isNotEmpty && content.isNotEmpty) {
      try {
        await _firestore.collection('UserCommunity').add({
          'title': title,
          'content': content,
          'uploaderImageURL': uploaderImageURL, // 프로필 사진 URL 저장
          'uploadernickname': uploadernickname, // 닉네임 저장
          'createDate': createDate, // 작성일자 저장
          'views': views, // 조회수 초기값
          'favorite': favorite, // 찜 횟수 초기값
          'comments': comments, // 댓글 수 초기값
          'photoURL': photoURL,
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
                Navigator.pop(context); // AlertDialog 닫기
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                // 게시물을 등록하고 AlertDialog 닫기
                _saveCommunityData();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('게시물이 등록되었습니다.',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                    dismissDirection: DismissDirection.up,
                    duration: Duration(milliseconds: 1500),
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
