import 'package:flutter/material.dart';
import 'register_screen.dart';

void main() {
  runApp(TermsScreen());
}

class TermsScreen extends StatefulWidget {
  const TermsScreen({Key? key}) : super(key: key);

  @override
  _TermsScreenState createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _isCheckAll = false; // 체크박스의 초기 상태
  bool _isCheckFirst = false;
  bool _isCheckSecond = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
              onPressed: () {Navigator.pop(context);},
              icon: Icon(Icons.clear),
              iconSize: 30,
              color: Colors.black
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Padding(padding: EdgeInsets.fromLTRB(30, 60, 0, 10),
              child: Text('Logo',
                  style: TextStyle(color: Colors.black, fontSize: 80, fontWeight: FontWeight.bold)),
            ),
            Padding(padding: EdgeInsets.fromLTRB(30, 0, 0, 5),
              child: Text('환영합니다!',
                  style: TextStyle(color: Colors.black, fontSize: 25)),
            ),
            Padding(padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
              child: Text('서비스 이용을 위하여 \n약관 동의가 필요합니다.',
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
            ),
            SizedBox(height: 225),

            // 약관 전체동의
            Row(
              children: [
                Checkbox(
                  value: _isCheckAll,
                  onChanged: (value) {
                    setState(() {
                      _isCheckAll = value!;
                      _isCheckFirst = value!;
                      _isCheckSecond = value!;
                    });
                  },
                ),
                Text(
                  "약관 전체동의",
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),

            // 구분선
            Line(),

            // 첫번째 약관
            Row(
              children: [
                Checkbox(
                  value: _isCheckFirst,
                  onChanged: (value) {
                    setState(() {
                      _isCheckFirst = value!;
                      // 첫 번째 약관 체크박스가 변경될 때 '약관 전체동의' 업데이트
                      _isCheckAll = _isCheckFirst && _isCheckSecond;
                    });
                  },
                ),
                Text(
                  "(필수)이용약관 동의",
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),

            // 두번째 약관
            Row(
              children: [
                Checkbox(
                  value: _isCheckSecond,
                  onChanged: (value) {
                    setState(() {
                      _isCheckSecond = value!;
                      // 두 번째 약관 체크박스가 변경될 때 '약관 전체동의' 업데이트
                      _isCheckAll = _isCheckFirst && _isCheckSecond;
                    });
                  },
                ),
                Text(
                  "(필수)개인정보 수집 및 이용 동의",
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: ElevatedButton(
            onPressed: () {
              // '약관 전체동의'가 체크되어 있고, 모든 약관 동의 체크박스도 체크되어 있을 때만 '다음' 버튼이 눌릴 수 있도록 설정
              if (_isCheckAll && _isCheckFirst && _isCheckSecond) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              } else {
                // 모든 약관을 동의해야 다음으로 진행할 수 있음을 알려주는 메시지
                // 버튼 뒤에 가려지는 버그 있음
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("모든 약관에 동의해야 합니다."),
                ));
              }
            },
            child: Text("다음", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Color(0xff18a4f0)),
              minimumSize: MaterialStateProperty.all(Size(400, 60)),
            ),
          ),
        ),
      ),
    );
  }
}

// 구분선
class Line extends StatelessWidget {
  const Line({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 400,
        height: 2,
        color: Colors.black12,
      ),
    );
  }
}


