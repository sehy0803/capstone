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

  List<String> checkList = [];

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
                Text( "약관 전체동의",
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
                    });
                  },
                ),
                Text( "(필수)이용약관 동의",
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
                    });
                  },
                ),
                Text( "(필수)개인정보 수집 및 이용 동의",
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterScreen()),
              );
            },
            child: Text("다음", style: TextStyle(color: Colors.white, fontSize: 20)),
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
