import 'package:flutter/material.dart';
import 'terms_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("로그인"),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                }
            )
        ),
        body: Column(
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
              ElevatedButton(
                onPressed: () { }, // 로그인 성공, 실패
                child: Text("로그인", style: TextStyle(color: Colors.white, fontSize: 15)),
                style: ButtonStyle(
                  backgroundColor : MaterialStateProperty.all(Color(0xff18a4f0)),
                  minimumSize: MaterialStateProperty.all(Size(350, 60)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(onPressed: (){}, child: Text("아이디 찾기")),
                  SizedBox(width: 120,),
                  TextButton(onPressed: (){}, child: Text("비밀번호 찾기"))
                ],
              ),
              SizedBox(height: 165,),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TermsScreen()),
                  );
                },
                child: Text("회원가입", style: TextStyle(color: Colors.black, fontSize: 15)),
                style: ButtonStyle(
                  backgroundColor : MaterialStateProperty.all(Colors.white),
                  minimumSize: MaterialStateProperty.all(Size(350, 60)),
                ),
              ),
              ]
          ),
        bottomNavigationBar: BottomAppBar(

        ),
      )
    );
  }
}
