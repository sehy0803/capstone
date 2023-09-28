import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'terms_screen.dart';

// void main() {
//   runApp(const MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScreen()
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff18a4f0),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(50, 150, 50, 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("쉽고 빠른", style: TextStyle(color: Colors.white, fontSize: 30)),
            Text("경매의 시작", style: TextStyle(color: Colors.white, fontSize: 30)),
            Text("Logo", style: TextStyle(color: Colors.white, fontSize: 80, fontWeight: FontWeight.bold)),
            SizedBox( height: 200),
            Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text("로그인", style: TextStyle(color: Colors.black, fontSize: 15)),
                    style: ButtonStyle(
                      backgroundColor : MaterialStateProperty.all(Colors.white),
                      minimumSize: MaterialStateProperty.all(Size(300, 60)),
                    ),
                  ),
                  SizedBox( height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TermsScreen()),
                      );
                    },
                    child: Text("회원가입", style: TextStyle(color: Colors.white, fontSize: 15)),
                    style: ButtonStyle(
                      backgroundColor : MaterialStateProperty.all(Colors.black),
                      minimumSize: MaterialStateProperty.all(Size(300, 60)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
