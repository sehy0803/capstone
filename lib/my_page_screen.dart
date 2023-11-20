import 'package:capstone/custom_widget.dart';
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

  String userID = '';

  // 현재 로그인한 유저의 UID 저장
  void getCurrentUser() async {
    final user = _authentication.currentUser;
    if (user != null) {
      setState(() {
        userID = user.uid;
      });
    }
  }

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
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('User').doc(userID).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {return Center(child: CircularProgressIndicator());}
          if (snapshot.hasError) {return Center(child: Text('데이터를 불러올 수 없습니다.'));}

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          String imageURL = userData['imageURL'] as String;
          String nickname = userData['nickname'] as String;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                              builder: (context) {
                                return ProfileEditScreen(
                                  userID: userID,
                                );
                              },
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DarkColors.basic,
                        ),
                        child: Text('프로필 수정', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                  Line(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  //============================================================================

  // 사용자의 프로필사진을 표시하는 함수
  Widget _buildUserProfileImage(String imageURL) {
    double _imageSize = 80.0;
    if (imageURL != null && imageURL.isNotEmpty) {
      return Container(
        width: _imageSize,
        height: _imageSize,
        child: ClipOval(
          child: Image.network(
            imageURL,
            width: _imageSize,
            height: _imageSize,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      // imageURL이 공백 또는 null일 경우 기본 이미지 표시
      return Container(
        width: _imageSize,
        height: _imageSize,
        child: ClipOval(
          child: Image.asset(
            'assets/images/defaultImage.png', // 기본 이미지 파일 경로
            width: _imageSize,
            height: _imageSize,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
  }

}
