import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileSettingScreen extends StatefulWidget {
  final String userID;

  ProfileSettingScreen({
    required this.userID,
  });

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  final _authentication = FirebaseAuth.instance;

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
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('로그아웃 되었습니다.',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                      dismissDirection: DismissDirection.up,
                      duration: Duration(milliseconds: 1500),
                      backgroundColor: Colors.black,
                    )
                );
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
              showDialogWithdrawal(context);
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

  // 회원탈퇴 확인 AlertDialog 표시
  void showDialogWithdrawal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('회원탈퇴'),
          content: Text('회원을 탈퇴하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {Navigator.pop(context);},
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
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

                      // authentication에서 사용자 삭제
                      await user.delete();

                      // firestore에서 사용자 정보 삭제
                      await FirebaseFirestore.instance.collection('User').doc(user.uid).delete();

                      // 회원 탈퇴 성공 시, 로그아웃 및 로그인 화면으로 이동
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('회원탈퇴가 완료되었습니다.',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white)),
                          margin: EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.height - 90,
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
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 비밀번호 확인 알림창
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

}
