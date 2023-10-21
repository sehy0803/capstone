import 'package:capstone/profile_edit_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('마이페이지',
              style: TextStyle(color: Colors.black, fontSize: 20)),
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                // 위젯 추가
                UserProfileInfo()
              ],
            ),
          ),
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
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: firestore.collection('User').doc(user?.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('데이터를 가져오는 중 오류 발생');
          }
          if (snapshot.hasData) {
            // 데이터 가져오기 성공
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final userNickname = userData['nickname']; // 닉네임 가져오기
            return Row(
              children: [
                Icon(Icons.account_circle, size: 80), // 사용자 프로필 이미지
                SizedBox(width: 10),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        userNickname ?? '사용자 이름 없음', // 닉네임이 설정되지 않았을 경우 없음으로 표시
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black12,
                            width: 1.0,
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
        // 로딩중일때 표시되는 동그라미
        return CircularProgressIndicator();
      },
    );
  }
}
