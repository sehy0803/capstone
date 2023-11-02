import 'package:capstone/profile_edit_screen.dart';
import 'package:capstone/profile_setting_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void initState() {
    super.initState();
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
        actions: [
          // 프로필 설정 버튼
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileSettingScreen()),
                );
              },
              icon: Icon(Icons.settings, color: Colors.grey, size: 30))
        ],
      ),
      body: StreamBuilder(
        stream: _fetchUserProfileStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('데이터를 불러올 수 없습니다.'));
          }

          final userData = snapshot.data as Map<String, dynamic>;

          final imageURL = userData['imageURL'];
          final nickname = userData['nickname'];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // 유저 프로필 사진 표시
                          _buildUserProfileImage(imageURL),
                          SizedBox(width: 10),
                          // 닉네임 표시
                          Text(
                            nickname,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      // 프로필 수정 버튼
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfileEditScreen()),
                          );
                        },
                        child: Text('프로필 수정', style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                      ),
                    ],
                  ),


                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 유저 정보 실시간 업데이트하는 함수
  Stream<Map<String, dynamic>> _fetchUserProfileStream() {
    final user = _authentication.currentUser;
    if (user != null) {
      return _firestore
          .collection('User')
          .doc(user.uid)
          .snapshots()
          .map((snapshot) {
        return snapshot.data() as Map<String, dynamic>;
      });
    } else {
      return Stream.value({});
    }
  }

  // 유저 프로필 사진을 표시하는 부분
  Widget _buildUserProfileImage(String? profileImageUrl) {
    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      // Firebase Storage에서 이미지를 가져와 표시
      return Container(
        width: 120,
        height: 120,
        child: ClipOval(
          child: Image.network(
            profileImageUrl,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      // 기본 아이콘 표시
      return Container(
        width: 120,
        height: 120,
        child: Icon(
          Icons.account_circle,
          color: Colors.black12,
          size: 120,
        ),
      );
    }
  }
}
