import 'package:capstone/my_page_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        body: EditUserProfile(),
      ),
    );
  }
}

// ========================================== 커스텀 위젯 ==========================================

// 프로필 수정
class EditUserProfile extends StatefulWidget {
  const EditUserProfile({super.key});

  @override
  _EditUserProfileState createState() => _EditUserProfileState();
}

class _EditUserProfileState extends State<EditUserProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  TextEditingController passwordController = TextEditingController();
  TextEditingController nicknameController = TextEditingController();
  User? user;
  String userPassword = "";
  String userNickname = "";

  @override
  void initState() {
    // 사용자 정보 가져오기
    super.initState();
    user = _auth.currentUser;
    if (user != null) {
      final userCollection = firestore.collection('User');
      userCollection.doc(user!.uid).get().then((doc) {
        if (doc.exists) {
          final userData = doc.data() as Map<String, dynamic>;
          setState(() {
            userPassword = userData['password'];
            userNickname = userData['nickname'];
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Center(
                child: Icon(
                    Icons.account_circle, size: 100, color: Colors.black12),
              ),
              SizedBox(height: 50),
              Row(
                children: [
                  Text("이메일", style: TextStyle(fontSize: 16)),
                  SizedBox(width: 50),
                  Text(user?.email ?? "",
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("비밀번호", style: TextStyle(fontSize: 16)),
                  SizedBox(width: 35),
                  Expanded(
                    child: TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        hintText: '변경할 비밀번호',
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text("닉네임", style: TextStyle(fontSize: 16)),
                  SizedBox(width: 50),
                  Expanded(
                    child: TextField(
                      controller: nicknameController,
                      decoration: InputDecoration(
                        hintText: '변경할 닉네임',
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                updateProfile();
              },
              child: Text("수정완료",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void updateProfile() async {
    String newPassword = passwordController.text.trim();
    String newNickname = nicknameController.text.trim();

    if (newPassword.isEmpty && newNickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("변경할 내용을 입력해주세요."),
        ),
      );
      return;
    }

    try {
      if (newPassword.isNotEmpty) {
        // 사용자 비밀번호 업데이트
        await user!.updatePassword(newPassword);
      }

      if (newNickname.isNotEmpty) {
        // Firestore에 사용자 정보 업데이트
        final userCollection = firestore.collection('User');
        Map<String, dynamic> updates = {};

        if (newPassword.isNotEmpty) {
          updates['password'] = newPassword;
        }

        updates['nickname'] = newNickname;

        await userCollection.doc(user!.uid).update(updates);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("프로필 수정 완료"),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyPageScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("프로필 수정 중 오류 발생"),
        ),
      );
    }
  }
}
