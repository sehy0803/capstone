import 'package:capstone/profile_edit_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final _authentication = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  String? profileImageUrl;
  String nickname = '';


  // 사용자의 닉네임을 Firestore에서 가져와 변수에 저장하는 함수
  void _fetchUserNickname() async {
    final user = _authentication.currentUser;
    if (user != null) {
      final userCollection =
          await _firestore.collection('User').doc(user.uid).get();
      final userData = userCollection.data() as Map<String, dynamic>;
      final nickname = userData['nickname'];
      setState(() {
        this.nickname = nickname;
      });
    }
  }

  // 사용자의 프로필 사진을 Firebase Storage에서 가져와 변수에 저장하는 함수
  void _fetchUserProfileImage() async {
    final user = _authentication.currentUser;
    if (user != null) {
      final userCollection =
      await _firestore.collection('User').doc(user.uid).get();
      final userData = userCollection.data() as Map<String, dynamic>;
      final imageUrl = userData['profileImageUrl'];

      if (imageUrl != null) {
        final ref = _storage.ref().child(imageUrl);
        final url = await ref.getDownloadURL();
        setState(() {
          profileImageUrl = url;
        });
      }
    }
  }

  // 유저 프로필 사진을 표시하는 부분
  Widget _buildUserProfileImage() {
    final _imageSize = MediaQuery.of(context).size.width / 2;

    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      // Firebase Storage에서 이미지를 가져와 표시
      return Container(
        constraints: BoxConstraints(
          minHeight: _imageSize,
          minWidth: _imageSize,
        ),
        child: Image.network(
          profileImageUrl!,
          width: _imageSize,
          height: _imageSize,
          fit: BoxFit.cover,
        ),
      );
    } else {
      // 기본 아이콘 표시
      return Container(
        constraints: BoxConstraints(
          minHeight: _imageSize,
          minWidth: _imageSize,
        ),
        child: Icon(
          Icons.account_circle,
          size: _imageSize,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserNickname();
    _fetchUserProfileImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            Text('마이페이지', style: TextStyle(color: Colors.black, fontSize: 20)),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [

          // 유저 프로필 사진 표시
          _buildUserProfileImage(),

          Row(
            children: [Text('닉네임'), Text(nickname)],
          ),



          // 프로필 수정 버튼
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileEditScreen()),
              ).then((updatedInfo) {
                if (updatedInfo != null) {
                  if (updatedInfo.containsKey('nickname')) {
                    setState(() {
                      nickname = updatedInfo['nickname'];
                    });
                  }
                  if (updatedInfo.containsKey('photoURL')) {
                    // 프로필 사진 업데이트 로직
                  }
                }
              });
            },
            child: Text('프로필 수정'),
          ),


          // 로그아웃 버튼
          TextButton(
            onPressed: () {
              _authentication.signOut();
            },
            child: Text('로그아웃'),
          ),
        ],
      )
      ),
    );
  }
}
