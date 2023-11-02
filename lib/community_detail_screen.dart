import 'package:flutter/material.dart';

class CommunityDetailScreen extends StatelessWidget {
  final String title; // 제목
  final String content; // 내용
  final String uploaderImageURL; // 사용자 프로필 사진 URL
  final String uploadernickname; // 사용자 닉네임
  final String createDate; // 글을 올린 날짜와 시간

  const CommunityDetailScreen({
    required this.title,
    required this.content,
    required this.uploaderImageURL,
    required this.uploadernickname,
    required this.createDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            Text('유저 게시판', style: TextStyle(color: Colors.black, fontSize: 20)),
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
          iconSize: 30,
          color: Colors.black,
        ),
        // 게시물 신고 기능
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.black, size: 30),
            offset: Offset(0, 60),
            onSelected: (value) {
              if (value == 'report') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('신고하기'),
                      content: Text('이 게시물을 신고하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            // 여기에 신고 처리 로직 추가
                            Navigator.of(context).pop();
                          },
                          child: Text('예'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('아니오'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'report',
                  child: Text('신고하기'),
                ),
              ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 게시글 제목
            Text(title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

            SizedBox(height: 20),

            // 유저 정보
            Row(
              children: [
                // 글을 올린 유저의 프로필 사진
                Container(
                  width: 60,
                  height: 60,
                  child: ClipOval(
                    child: Image.network(
                      uploaderImageURL,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 글을 올린 유저의 닉네임
                    Text(uploadernickname, style: TextStyle(fontSize: 18)),

                    // 글을 올린 날짜와 시간
                    Text(createDate,
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                )
              ],
            ),

            // 구분선
            Divider(
              color: Colors.grey,
              height: 30,
            ),

            // 게시글 내용
            Text(content, style: TextStyle(fontSize: 18)),

            // 구분선
            Divider(
              color: Colors.grey[350],
              height: 30,
            ),

            // 댓글
            Row(
              children: [Text('댓글'), SizedBox(width: 10), Text('댓글개수')],
            ),

            // 구분선
            Divider(
              color: Colors.grey,
              height: 30,
            ),

            // 댓글 리스트 표시
          ],
        ),
      )),
      bottomNavigationBar: BottomAppBar(
          // 검색어 입력창
          child: Row(
        children: [
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  ),
                  hintText: '댓글 달기',
                  hintStyle: TextStyle(fontSize: 16, color: Colors.grey[400]!),
                  contentPadding: EdgeInsets.all(10)),
            ),
          ),
          SizedBox(
            width: 80,
            height: 50,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  elevation: 5,
                  shape: StadiumBorder()),
              child: Text('등록'),
            ),
          )
        ],
      )),
    );
  }
}

// ========================================== 커스텀 위젯 ==========================================
