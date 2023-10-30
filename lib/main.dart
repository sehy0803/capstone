import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:capstone/register_screen.dart';
import 'package:capstone/tab_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Capstone App',
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot){
            if(snapshot.hasData){
              return TabScreen();
            }
            return LoginScreen();
          },
        )
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authentication = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  // 유저가 입력한 로그인 정보를 저장할 변수
  String email = '';
  String password = '';

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
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 120, 30, 120),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MainText(), // 글씨 부분
            Column(
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
                    ],
                  ),
                ),

                // 이메일, 비밀번호 찾기
                EmailPassFindButton(),

                SizedBox(height: 10),

                //로그인 버튼
                ElevatedButton(
                    onPressed: () async {
                      _tryValidation();

                      try {
                        final newUser =
                            await _authentication.signInWithEmailAndPassword(
                                email: email, password: password);

                        // 로그인 성공시 TabScreen으로 이동
                        if (newUser.user != null) {

                        }
                      } catch (e) {
                        print(e);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('이메일 또는 비밀번호 확인해주세요.')));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: Size(double.infinity, 55),
                        elevation: 5,
                        shape: StadiumBorder()),
                    child: Text(
                      "로그인",
                      style: TextStyle(fontSize: 18),
                    )),

                SizedBox(height: 50),

                // 회원가입 화면으로 이동하는 버튼
                MoveRegisterScreenButton()
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================== 커스텀 위젯 ==========================================

// 글씨 부분
class MainText extends StatelessWidget {
  const MainText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("쉽고 빠른", style: TextStyle(fontSize: 24, color: Colors.black)),
        Text("경매의 시작", style: TextStyle(fontSize: 24, color: Colors.black)),
        Text("Logo",
            style: TextStyle(
                fontSize: 44,
                color: Colors.lightBlue,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// 이메일, 비밀번호 찾기 버튼
class EmailPassFindButton extends StatelessWidget {
  const EmailPassFindButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            "이메일 찾기",
            style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.normal),
          ),
        ),
        SizedBox(width: 5),
        Text("|", style: TextStyle(fontSize: 10, color: Colors.grey)),
        SizedBox(width: 5),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text("비밀번호 찾기",
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.normal)),
        ),
      ],
    );
  }
}

// 회원가입 버튼
class MoveRegisterScreenButton extends StatelessWidget {
  const MoveRegisterScreenButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Logo가 처음이신가요?",
            style: TextStyle(fontSize: 16, color: Colors.grey)),
        TextButton(
          onPressed: () {
            // 버튼 클릭 시
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterScreen()),
            );
          },
          child: Text("회원가입",
              style: TextStyle(fontSize: 16, color: Colors.lightBlue)),
        )
      ],
    );
  }
}
