import 'package:capstone/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authentication = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  // 유저가 입력한 회원가입 정보를 저장할 변수
  String email = '';
  String password = '';
  String nickname = '';

  // 유효성 검사 후 값 저장
  void _tryValidation() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title:
              Text('회원가입', style: TextStyle(fontSize: 20, color: Colors.black)),
          centerTitle: true,
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_rounded),
            color: Colors.black,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // 이메일 텍스트필드
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        key: ValueKey(1),
                        validator: (value) {
                          if (value!.isEmpty || !value.contains('@')) {
                            return '올바른 이메일 형식을 입력해주세요.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          email = value!;
                        },
                        onChanged: (value) {
                          email = value;
                        },
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.account_circle,
                              color: Colors.grey[400]!,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[400]!),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(35.0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[400]!),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(35.0)),
                            ),
                            hintText: '이메일',
                            hintStyle: TextStyle(
                                fontSize: 16, color: Colors.grey[400]!),
                            contentPadding: EdgeInsets.all(15)),
                      ),
                      SizedBox(height: 10),
                      // 비밀번호 텍스트필드
                      TextFormField(
                        obscureText: true,
                        key: ValueKey(2),
                        validator: (value) {
                          if (value!.isEmpty || value.length < 6) {
                            return '비밀번호를 6글자 이상 입력해주세요.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          password = value!;
                        },
                        onChanged: (value) {
                          password = value;
                        },
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.grey[400]!,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[400]!),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(35.0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[400]!),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(35.0)),
                            ),
                            hintText: '비밀번호',
                            hintStyle: TextStyle(
                                fontSize: 16, color: Colors.grey[400]!),
                            contentPadding: EdgeInsets.all(15)),
                      ),
                      SizedBox(height: 10),
                      // 닉네임 텍스트필드
                      TextFormField(
                        key: ValueKey(3),
                        validator: (value) {
                          if (value!.isEmpty || value.length < 2) {
                            return '닉네임을 2글자 이상 입력해주세요.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          nickname = value!;
                        },
                        onChanged: (value) {
                          nickname = value;
                        },
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.grey[400]!,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[400]!),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(35.0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[400]!),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(35.0)),
                            ),
                            hintText: '닉네임',
                            hintStyle: TextStyle(
                                fontSize: 16, color: Colors.grey[400]!),
                            contentPadding: EdgeInsets.all(15)),
                      ),
                    ],
                  ),
                ),

                // 회원가입 버튼
                ElevatedButton(
                    onPressed: () async {
                      _tryValidation();

                      try {
                        final newUser = await _authentication
                            .createUserWithEmailAndPassword(
                                email: email, password: password);

                        // Cloud Firestore 에 유저 정보 저장
                        await FirebaseFirestore.instance.collection('User').doc(newUser.user!.uid)
                            .set({
                          'email' : email,
                          'nickname' : nickname,
                        });

                        // 회원가입 성공시 TabScreen으로 이동
                        if (newUser.user != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('회원가입이 완료되었습니다. 로그인을 해주세요.',
                                    style: TextStyle(fontSize: 18)),
                                backgroundColor: Colors.blue[200]),
                          );
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return LoginScreen();
                            },
                          ));
                        }
                      } catch (e) {
                        print(e);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('이메일, 비밀번호 또는 닉네임을 확인해주세요.')));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: Size(double.infinity, 55),
                        elevation: 5,
                        shape: StadiumBorder()),
                    child: Text(
                      "회원가입",
                      style: TextStyle(fontSize: 18),
                    )),
              ]),
        ));
  }
}

// ========================================== 커스텀 위젯 ==========================================
