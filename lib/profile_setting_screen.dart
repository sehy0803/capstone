import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileSettingScreen extends StatefulWidget {
  const ProfileSettingScreen({Key? key});

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  final _authentication = FirebaseAuth.instance;

  Future<String?> _showPasswordInputDialog(BuildContext context) async {
    String? password;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('비밀번호 확인'),
          content: TextField(
            obscureText: true,
            onChanged: (value) {
              password = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, password);
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
    return password;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text('설정', style: TextStyle(color: Colors.black, fontSize: 20)),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.close),
          iconSize: 30,
          color: Colors.black,
        ),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 로그아웃 버튼
          TextButton(
            onPressed: () async {
              // 다이얼로그를 표시하여 사용자에게 확인 메시지 표시
              bool confirm = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("로그아웃"),
                    content: Text("로그아웃하시겠습니까?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false); // 취소
                        },
                        child: Text("취소"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true); // 확인
                        },
                        child: Text("확인"),
                      ),
                    ],
                  );
                },
              );
              if (confirm == true){
                _authentication.signOut();
              }
            },
            child: Text('로그아웃'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
          ),

          // 회원탈퇴 버튼
          TextButton(
            onPressed: () async {
              // 다이얼로그를 표시하여 사용자에게 확인 메시지 표시
              bool confirm = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("회원탈퇴"),
                    content: Text("정말로 회원을 탈퇴하시겠습니까?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false); // 취소
                        },
                        child: Text("취소"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true); // 확인
                        },
                        child: Text("확인"),
                      ),
                    ],
                  );
                },
              );

              // 회원탈퇴 진행
              if (confirm == true){
                // 다이얼로그 또는 모달 팝업을 통해 사용자로부터 비밀번호를 입력받음
                final userPassword = await _showPasswordInputDialog(context);

                if (userPassword != null) {
                  // 사용자 인증
                  try {
                    final user = _authentication.currentUser;

                    if (user != null) {
                      // 사용자의 입력한 비밀번호로 인증
                      await user.reauthenticateWithCredential(
                        EmailAuthProvider.credential(
                          email: user.email!,
                          password: userPassword,
                        ),
                      );

                      // 사용자 삭제
                      await user.delete();

                      // 파이어스토어에서 사용자 정보 삭제
                      await FirebaseFirestore.instance.collection('User').doc(user.uid).delete();

                      // 회원 탈퇴 성공 시, 로그아웃 및 로그인 화면으로 이동
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('회원탈퇴가 완료되었습니다.',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white)),
                          margin: EdgeInsets.only(
                              bottom: MediaQuery.of(context)
                                  .size
                                  .height -
                                  90,
                              left: 10,
                              right: 10),
                          dismissDirection: DismissDirection.up,
                          duration: Duration(milliseconds: 1500),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.black,
                        ),
                      );
                      await _authentication.signOut();
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    print("회원 탈퇴 오류: $e");
                  }
                }
              }
            },
            child: Text('회원탈퇴'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
