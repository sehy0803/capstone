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
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  // 유저의 회원가입 정보를 저장할 변수
  String email = '';
  String password = '';
  String nickname = '';
  String imageURL = '';

  // 유효성 검사 후 값 저장
  void _tryValidation() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
    }
  }

  // 이메일 중복 검사
  Future<bool> _checkIfEmailExists(String email) async {
    final querySnapshot = await _firestore
        .collection('User')
        .where('email', isEqualTo: email)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
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
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus(); // 빈 곳 터치시 키패드 사라짐
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(children: [
                Image.asset('assets/images/logo.png'),
                SizedBox(height: 50),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: // 이메일 텍스트필드
                                TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              key: ValueKey(1),
                              validator: (value) {
                                if (value!.isEmpty ||
                                    !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                                        .hasMatch(value)) {
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
                                    borderSide:
                                        BorderSide(color: Colors.grey[400]!),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(35.0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.grey[400]!),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(35.0)),
                                  ),
                                  hintText: '이메일',
                                  hintStyle: TextStyle(
                                      fontSize: 16, color: Colors.grey[400]!, height: 1.15),
                                  contentPadding: EdgeInsets.all(15)),
                            ),
                          ),
                          SizedBox(width: 5),

                          // 이메일 중복확인 버튼
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (email.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('이메일을 입력해주세요.',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white)),
                                      margin: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                                  .size
                                                  .height -
                                              90,
                                          left: 10,
                                          right: 10),
                                      dismissDirection: DismissDirection.up,
                                      duration: Duration(milliseconds: 1500),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                  return; // 이메일이 비어있으면 함수 실행 종료
                                }

                                final emailExists =
                                    await _checkIfEmailExists(email);

                                if (emailExists) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('중복된 이메일 주소입니다.',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white)),
                                      margin: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                                  .size
                                                  .height -
                                              90,
                                          left: 10,
                                          right: 10),
                                      dismissDirection: DismissDirection.up,
                                      duration: Duration(milliseconds: 1500),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('사용 가능한 이메일 주소입니다.',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white)),
                                      margin: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                                  .size
                                                  .height -
                                              90,
                                          left: 10,
                                          right: 10),
                                      dismissDirection: DismissDirection.up,
                                      duration: Duration(milliseconds: 1500),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                elevation: 5,
                                shape: StadiumBorder(),
                              ),
                              child: Text(
                                "중복확인",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      // 비밀번호 텍스트필드
                      TextFormField(
                        obscureText: true,
                        key: ValueKey(2),
                        validator: (value) {
                          if (password.length < 6) {
                            return '비밀번호를 6글자 이상 입력해주세요.';
                          } else {
                            int complexity = 0;
                            if (RegExp(r'[a-z]').hasMatch(password)) complexity++;
                            if (RegExp(r'[A-Z]').hasMatch(password)) complexity++;
                            if (RegExp(r'[0-9]').hasMatch(password)) complexity++;
                            if (RegExp(r'[!@#\$%^&*]').hasMatch(password))
                              complexity++;

                            if (complexity < 2) {
                              return '비밀번호는 영어 소문자, 영어 대문자, 숫자, 특수문자 중 적어도 두 가지 이상을 포함해야 합니다.';
                            }
                          }
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
                                fontSize: 16, color: Colors.grey[400]!, height: 1.15),
                            contentPadding: EdgeInsets.all(15)),
                      ),
                      SizedBox(height: 10),
                      // 닉네임 텍스트필드
                      TextFormField(
                        key: ValueKey(3),
                        validator: (value) {
                          if (value!.length < 2) {
                            return '닉네임을 2글자 이상 입력해주세요.';
                          }
                          if (RegExp(r'[!@#\$%^&*]').hasMatch(value)) {
                            return '닉네임에 특수문자를 포함할 수 없습니다.';
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
                                fontSize: 16, color: Colors.grey[400]!, height: 1.15),
                            contentPadding: EdgeInsets.all(15)),
                      ),
                      SizedBox(height: 50),

                      // 회원가입 버튼
                      ElevatedButton(
                        onPressed: () async {
                          _tryValidation(); // 유효성 검사 수행

                          if (_formKey.currentState!.validate()) {
                            // 유효성 검사 통과한 경우에만 회원가입 시도
                            try {
                              final newUser = await _authentication.createUserWithEmailAndPassword(
                                email: email,
                                password: password,
                              );

                              //Firestore 에 사용자 정보 저장
                              await FirebaseFirestore.instance.collection('User').doc(newUser.user!.uid).set({
                                'email': email,
                                'nickname': nickname,
                                'imageURL': imageURL
                              });

                              // 회원가입 성공시 LoginScreen으로 이동
                              if (newUser.user != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '회원가입이 완료되었습니다. 로그인을 해주세요.',
                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                    ),
                                    margin: EdgeInsets.only(
                                      bottom: MediaQuery.of(context).size.height - 90,
                                      left: 10,
                                      right: 10,
                                    ),
                                    dismissDirection: DismissDirection.up,
                                    duration: Duration(milliseconds: 1500),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return LoginScreen();
                                  },
                                ));
                              }
                            } catch (e) {
                              print(e);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '이메일, 비밀번호 또는 닉네임을 확인해주세요.',
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                  margin: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).size.height - 90,
                                    left: 10,
                                    right: 10,
                                  ),
                                  dismissDirection: DismissDirection.up,
                                  duration: Duration(milliseconds: 1500),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: Size(double.infinity, 55),
                          elevation: 5,
                          shape: StadiumBorder(),
                        ),
                        child: Text(
                          "회원가입",
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ));
  }


}

// ========================================== 커스텀 위젯 ==========================================
