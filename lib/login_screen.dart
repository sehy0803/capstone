import 'package:capstone/register_screen.dart';
import 'package:flutter/material.dart';
import 'terms_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          resizeToAvoidBottomInset : false,
        appBar: AppBar(
          title: Text("로그인"),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                }
            )
        ),
        body: SingleChildScrollView(
          child: Column(
              children: [
                Container(
                  width: 300,
                  height: 160,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                        child: TextField(
                          decoration: InputDecoration(hintText: '이메일'),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                        child: TextField(
                          decoration: InputDecoration(hintText: '비밀번호'),
                        ),
                      )
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () { }, // 로그인 성공, 실패
                  child: Text("로그인", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  style: ButtonStyle(
                    backgroundColor : MaterialStateProperty.all(Color(0xff18a4f0)),
                    minimumSize: MaterialStateProperty.all(Size(300, 60)),
                  ),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(onPressed: (){}, child: Text("아이디 찾기", style: TextStyle(fontSize: 16))),
                      SizedBox(width: 100),
                      TextButton(onPressed: (){}, child: Text("비밀번호 찾기", style: TextStyle(fontSize: 16)))
                    ]
                ),
                SizedBox(height: 165,)
              ]
          ),
        )
      )
    );
  }
}
