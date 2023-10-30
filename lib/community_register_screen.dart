import 'package:flutter/material.dart';

class CommunityRegisterScreen extends StatefulWidget {
  const CommunityRegisterScreen({super.key, required String boardType});

  @override
  State<CommunityRegisterScreen> createState() => _CommunityRegisterScreenState();
}

class _CommunityRegisterScreenState extends State<CommunityRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // 유저가 입력한 게시글 정보를 저장할 변수
  String title = '';
  String content = '';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.close),
          iconSize: 30,
          color: Colors.black,
        ),
        actions: [
          // 게시글 등록 버튼
          TextButton(
            onPressed: () {},
            child: Text('등록',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue)),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // 제목 텍스트필드
                    TextFormField(
                      key: ValueKey(1),
                      validator: (value) {
                        if (value!.isEmpty || value.length < 20) {
                          return '제목은 20글자 이하만 입력할 수 있습니다.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        title = value!;
                      },
                      onChanged: (value) {
                        title = value;
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

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
