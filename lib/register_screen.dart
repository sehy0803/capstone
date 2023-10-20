import 'package:capstone/test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final TextEditingController emailController = TextEditingController();
    final TextEditingController passController = TextEditingController();
    final TextEditingController nickController = TextEditingController();

    Future<void> addUserToFirestore(String email, String password, String nickname) async {
      if (email.isEmpty || password.isEmpty || nickname.isEmpty) {
        print("빈 칸을 모두 입력해주세요");
        return;
      }
      try {
        // Firestore 컬렉션 참조
        CollectionReference User = firestore.collection('User');

        // 데이터 추가
        await User.add({
          'email': email,
          'password' : password,
          'nickname': nickname,
        });

        print("회원가입 성공");

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => test()),
        );

      } catch (e) {
        print('Firestore에 사용자 추가 중 오류 발생: $e');
      }
    }

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: Text('회원가입',
                style: TextStyle(color: Colors.black, fontSize: 20)),
            centerTitle: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: (){
                Navigator.pop(context);
              },
              icon: Icon(Icons.close),
              iconSize: 30,
              color: Colors.black,
            ),
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  RegisterInputText(emailController, passController, nickController), // 사용자 정보 입력칸
                ],
              )
          ),
        ),
          bottomNavigationBar: BottomAppBar(
            child: SizedBox(
              height: 50,
              child: RegisterButton(() {
                addUserToFirestore(emailController.text, passController.text, nickController.text);
              }),
            ),
          )
      )
    );
  }
}

// ========================================== 커스텀 위젯 ==========================================

class RegisterInputText extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passController;
  final TextEditingController nickController;

  RegisterInputText(this.emailController, this.passController, this.nickController);

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
        TextField(
          controller: passController,
          decoration: InputDecoration(
            hintText: '비밀번호',
          ),
        ),
        TextField(
          controller: nickController,
          decoration: InputDecoration(
            hintText: '닉네임',
          ),
        ),
      ],
    );
  }
}

// 회원가입
class RegisterButton extends StatelessWidget {
  final Function registerFunction;

  RegisterButton(this.registerFunction);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        registerFunction();
      },
      child: Text("가입완료",
          style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold)
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor : Colors.lightBlue,
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
    );
  }
}
