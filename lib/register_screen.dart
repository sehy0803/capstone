import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("회원가입"),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                }
            )
    ),
        body: ListView(
          children: [
            Column(
              children: [
                Padding(
                    child: TextField(
                      decoration: InputDecoration(hintText: '아이디'),
                    ),
                    padding: EdgeInsets.all(20)),
                Padding(
                    child: TextField(
                      decoration: InputDecoration(hintText: '비밀번호'),
                    ),
                    padding: EdgeInsets.all(20)),
                Padding(
                    child: TextField(
                      decoration: InputDecoration(hintText: '비밀번호 재입력'),
                    ),
                    padding: EdgeInsets.all(20)),
                Padding(
                    child: TextField(
                      decoration: InputDecoration(hintText: '이름'),
                    ),
                    padding: EdgeInsets.all(20)),
                Padding(
                    child: TextField(
                      decoration: InputDecoration(hintText: '이메일'),
                    ),
                    padding: EdgeInsets.all(20)),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Container(
                        width: 210,
                        child: TextField(
                          decoration: InputDecoration(hintText: '휴대폰 번호'),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text("인증번호 전송", style: TextStyle(color: Colors.white, fontSize: 15)),
                      style: ButtonStyle(
                        backgroundColor : MaterialStateProperty.all(Color(0xff18a4f0)),
                        minimumSize: MaterialStateProperty.all(Size(80, 50)),
                      ),
                    ),
                  ],
                ),
                Padding(
                    child: TextField(
                      decoration: InputDecoration(hintText: '인증번호'),
                    ),
                    padding: EdgeInsets.all(20)),
              ],
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(

        ),
      ),
    );
  }
}

