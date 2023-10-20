import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:capstone/register_screen.dart';
import 'package:capstone/test.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailInputTextController = TextEditingController();
  final TextEditingController _passInputTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(30, 120, 30, 120),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MainText(), // 글씨 부분
              Column(
                children: [
                  EmailPassInputText(_emailInputTextController, _passInputTextController), // 이메일, 비밀번호 입력칸
                  EmailPassFindButton(), // 이메일, 비밀번호 찾기
                  SizedBox(height: 10),
                  LoginButton(_emailInputTextController, _passInputTextController, _auth), // 로그인 버튼
                  SizedBox(height: 50),
                  MoveRegisterScreenButton() // 회원가입 화면으로 이동하는 버튼
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================================== 커스텀 위젯 ==========================================

// 글씨 부분
class MainText extends StatelessWidget {
  const MainText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("쉽고 빠른", style: TextStyle(fontSize: 24, color: Colors.black)),
        Text("경매의 시작", style: TextStyle(fontSize: 24, color: Colors.black)),
        Text("Logo", style: TextStyle(fontSize: 44, color: Colors.lightBlue, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// 이메일, 비밀번호 입력 텍스트필드
class EmailPassInputText extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passController;

  EmailPassInputText(this.emailController, this.passController);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            hintText: '이메일',
          ),
        ),
        SizedBox(height: 5),
        TextField(
          controller: passController,
          decoration: InputDecoration(
            hintText: '비밀번호',
          ),
        ),
        SizedBox(height: 10)
      ],
    );
  }
}

// 이메일, 비밀번호 찾기 버튼
class EmailPassFindButton extends StatelessWidget {
  const EmailPassFindButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {},
          child: Text("이메일 찾기",
              style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.normal),
          ),
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        SizedBox(width: 5),
        Text("|", style: TextStyle(fontSize: 10, color: Colors.grey)),
        SizedBox(width: 5),
        TextButton(
          onPressed: () {},
          child: Text("비밀번호 찾기",
              style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.normal)
          ),
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}


// 로그인 버튼
class LoginButton extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passController;
  final FirebaseAuth auth;

  LoginButton(this.emailController, this.passController, this.auth);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () async {
            final email = emailController.text;
            final password = passController.text;

            try {
              // Firestore에서 사용자 데이터 읽어오기
              final firestore = await FirebaseFirestore.instance
                  .collection('User')
                  .where('email', isEqualTo: email)
                  .get();

              if (firestore.docs.isNotEmpty) {
                final userData = firestore.docs.first.data() as Map<String, dynamic>;
                final storedPassword = userData['password'];

                if (password == storedPassword) {
                  final UserCredential userCredential = await auth.signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  );

                  if (userCredential.user != null) {
                    // 로그인에 성공한 경우
                    print("로그인 성공");
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => test()),
                    );
                  } else {
                    // 로그인에 실패한 경우
                    print("Firebase Authentication 로그인 실패");
                  }
                } else {
                  print("비밀번호가 일치하지 않습니다.");
                }
              } else {
                print("사용자를 찾을 수 없습니다.");
              }
            } catch (e) {
              print("로그인 중 오류 발생: $e");
            }
          },
          child: Text("로그인",
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
    );
  }
}




// 회원가입 버튼
class MoveRegisterScreenButton extends StatelessWidget {
  const MoveRegisterScreenButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Logo가 처음이신가요?", style: TextStyle(fontSize: 16, color: Colors.grey)),
        TextButton(
          onPressed: () { // 버튼 클릭 시
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterScreen()),
            );
          },
          child: Text("회원가입",
              style: TextStyle(fontSize: 16, color: Colors.lightBlue)
          ),
        )
      ],
    );
  }
}
