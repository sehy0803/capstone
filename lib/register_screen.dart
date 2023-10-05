import 'package:capstone/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

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
                    child: TextFormField(
                      decoration: InputDecoration(hintText: '이메일'),
                    ),
                    padding: EdgeInsets.all(20)),

                Padding(
                  child: TextFormField(
                    obscureText: true, // 비밀번호 입력을 '*'로 가리도록 설정
                    decoration: InputDecoration(hintText: '비밀번호'),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9@#$%^&+=]')), // 영문자, 숫자, 특수문자 허용, 최소 8글자, 최대 20글자
                    ],
                  ),
                  padding: EdgeInsets.all(20),
                ),

                Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 210,
                        child: TextFormField(
                          decoration: InputDecoration(hintText: '닉네임'),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z가-힣0-9]')), // 한글, 영문자, 숫자 허용, 최소 2글자, 최대 10글자
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text("중복확인", style: TextStyle(color: Colors.white, fontSize: 15)),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Color(0xff18a4f0)),
                          minimumSize: MaterialStateProperty.all(Size(120, 50)),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 210,
                        child: TextFormField(
                          decoration: InputDecoration(hintText: '휴대폰 번호'),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), // 숫자만 허용
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text("인증요청", style: TextStyle(color: Colors.white, fontSize: 15)),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Color(0xff18a4f0)),
                          minimumSize: MaterialStateProperty.all(Size(120, 50)),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                    child: TextField(
                      decoration: InputDecoration(hintText: '인증번호 입력'),
                    ),
                    padding: EdgeInsets.all(20)),
              ],
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            child: Text("가입완료", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            style: ButtonStyle(
              backgroundColor : MaterialStateProperty.all(Color(0xff18a4f0)),
              minimumSize: MaterialStateProperty.all(Size(400, 60)),
            ),
          ),
        ),
      ),
    );
  }
}

