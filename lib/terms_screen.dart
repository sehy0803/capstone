import 'package:flutter/material.dart';
import 'register_screen.dart';

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
          title: Text("약관동의"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Center(
              child: Container(
                width: 400,
                height: 1,
                color: Colors.grey,
              ),
            ),
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
            child: Text("다음", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
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

void main() {
  runApp(TermsScreen());
}
