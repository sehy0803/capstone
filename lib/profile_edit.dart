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
          title: Text('마이페이지', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white,centerTitle: false, titleSpacing: 0.0,
        ),
        body: Container(

          child: Column(
            children: [
              Image.asset('profile.jpg', width: 150, height: 150,),

              Column(

                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('이름', style: TextStyle(fontSize: 30)),
                  TextField(style: TextStyle(fontSize: 50),),
                  Text('비밀번호', style: TextStyle(fontSize: 30)),
                  TextField(obscureText: true, style: TextStyle(),),
                  Text('이메일', style: TextStyle(fontSize: 30)),
                  TextField(style: TextStyle(fontSize: 50),),
                  Text('휴대폰 번호', style: TextStyle(fontSize: 30)),
                  TextField(style: TextStyle(fontSize: 50, ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')) // 휴대폰 번호는 숫자만 입력 가능
                  ],),
                ],
              )
            ],
          )
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
