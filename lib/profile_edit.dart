import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// void main() {
//   runApp(const ProfileEdit());
// }

class ProfileEdit extends StatelessWidget {
  const ProfileEdit({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            title: Text('마이페이지', style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.white),
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(50, 30, 50, 10),
              child: Column(

                children: [
                  Image.asset('profile.jpg', width: 150, height: 150),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,


                    children: [
                      TextField(style: TextStyle(fontSize: 15, height: 3), inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[가-힣]')),] // 이름은 한글만 입력 가능
                        , decoration: InputDecoration(labelText: '이름'),),
                      TextField(style: TextStyle(fontSize: 15, height: 3), obscureText: true, decoration: InputDecoration(labelText: '비밀번호'),),
                      TextField(style: TextStyle(fontSize: 15, height: 3), decoration: InputDecoration(labelText: '이메일'),),
                      TextField(
                        style: TextStyle(fontSize: 15, height: 3),
                        decoration: InputDecoration(labelText: '휴대폰 번호'),
                        keyboardType: TextInputType.phone,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')) // 휴대폰 번호는 숫자만 입력 가능
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 회원탈퇴 버튼을 바텀앱바 바로 위 가운데에 배치
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: TextButton(onPressed: (){}, child: Text('회원탈퇴', style: TextStyle(color : Color(0xff18a4f0)))),

              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(onPressed: (){}, icon: Icon(Icons.home)),
              IconButton(onPressed: (){}, icon: Icon(Icons.launch)),
              IconButton(onPressed: (){}, icon: Icon(Icons.chat)),
              IconButton(onPressed: (){}, icon: Icon(Icons.favorite)),
              IconButton(onPressed: (){}, icon: Icon(Icons.person)),
            ],
          ),
        ),
      ),
    );
  }
}
