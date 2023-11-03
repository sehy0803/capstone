import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommunityDetailScreen extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;

  final String title; // 제목
  final String content; // 내용
  final String uploaderImageURL; // 사용자 프로필 사진 URL
  final String uploadernickname; // 사용자 닉네임
  final String createDate; // 글을 올린 날짜와 시간
  final String collectionName; // 커뮤니티 종류
  final String documentId; // 게시물 고유 ID
  final int views;
  final int favorite;
  final int comments;

  CommunityDetailScreen({
    required this.title,
    required this.content,
    required this.uploaderImageURL,
    required this.uploadernickname,
    required this.createDate,
    required this.collectionName,
    required this.documentId,
    required this.views,
    required this.favorite,
    required this.comments,
  });

  Future<void> deletePost(String documentId) async {
    try {
      // Firestore에서 게시물 삭제
      await _firestore.collection(collectionName).doc(documentId).delete();
    } catch (e) {
      print('게시물 삭제 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('유저 게시판',
              style: TextStyle(color: Colors.black, fontSize: 20)),
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
                if (value == 'delete') {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('삭제하기'),
                        content: Text('이 게시물을 삭제하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              await deletePost(documentId); // 게시물 삭제 함수 호출
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
                    value: 'delete',
                    child: Text('삭제하기'),
                  ),
                ];
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 게시글 제목
                    Text(title,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),

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
                            Text(uploadernickname,
                                style: TextStyle(fontSize: 18)),

                            // 글을 올린 날짜와 시간
                            Text(createDate,
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey)),
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

                    Row(
                      children: [Text('댓글'), SizedBox(width: 10), Text('댓글개수')],
                    ),

                    // 구분선
                    Divider(
                      color: Colors.grey,
                      height: 30,
                    ),

                    // 댓글
                    Column(
                      children: [
                        Card()
                      ],
                    ),

                  ],
                ),
              ),

              // 댓글 입력 버튼
              Align(
                alignment: Alignment.bottomCenter,
                child: Stack(children: [
                  TextFormField(
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                        hintText: '댓글을 남겨보세요',
                        hintStyle:
                            TextStyle(fontSize: 16, color: Colors.grey[400]!),
                        contentPadding: EdgeInsets.all(15)),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      child: Text('등록', style: TextStyle(fontSize: 16)),
                    ),
                  )
                ]),
              )
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar());
  }
}

// ========================================== 커스텀 위젯 ==========================================
