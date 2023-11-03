import 'package:capstone/custom_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommunityAuctionDetailScreen extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;

  final String title; // 제목
  final String content; // 내용
  final String uploaderImageURL; // 사용자 프로필 사진 URL
  final String uploadernickname; // 사용자 닉네임
  final String createDate; // 글을 올린 날짜와 시간
  final String collectionName; // 커뮤니티 종류
  final String documentId; // 게시물 고유 ID
  final int views; // 조회수
  final int favorite; // 찜 횟수
  final int comments; // 댓글 수
  final String photoURL; // 게시물 사진
  final String endTime; //
  final String nowPrice; //

  CommunityAuctionDetailScreen({
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
    required this.photoURL,
    required this.endTime,
    required this.nowPrice,
  });

  // 게시물 삭제 함수
  Future<void> deletePost(String documentId, BuildContext context) async {
    try {
      // Firestore에서 게시물 삭제
      await _firestore.collection(collectionName).doc(documentId).delete();
      Navigator.pop(context);
    } catch (e) {
      print('게시물 삭제 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('경매 게시판',
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
                  showConfirmationDialog(context);
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

                    // 경매 상품 사진
                    Center(
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        color: Colors.black,
                        child: photoURL == null || photoURL.isEmpty
                            ? Icon(
                                Icons.image,
                                color: Colors.grey,
                                size: 100,
                              )
                            : Image.network(
                                photoURL,
                              ),
                      ),
                    ),

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

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 글을 올린 유저의 닉네임
                              Text(uploadernickname,
                                  style: TextStyle(fontSize: 18)),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(createDate,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey)),
                                      SizedBox(width: 3),
                                      Text('조회수',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey)),
                                      SizedBox(width: 5),
                                      Text('$views',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                              height: 1.5))
                                    ],
                                  ),
                                ],
                              )
                            ],
                            // 글을 올린 날짜와 시간
                          ),
                        ),

                        // 찜 버튼
                        IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.favorite),
                            iconSize: 40,
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints())
                      ],
                    ),

                    Line(),

                    // 게시글 내용
                    Text(content, style: TextStyle(fontSize: 18)),

                    SizedBox(height: 50),


                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('경매종료일', style: TextStyle(fontSize: 18)),
                        Text(endTime, style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('즉시낙찰가', style: TextStyle(fontSize: 18)),
                        Text(nowPrice,
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange)),
                      ],
                    ),

                    Line(),

                    Row(
                      children: [
                        Text(
                          '댓글',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(width: 10),
                        Text(
                          '$comments',
                          style: TextStyle(fontSize: 14, height: 1.4),
                        )
                      ],
                    ),

                    Line(),
                    // 댓글
                    Column(
                      children: [Card()],
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

  // 게시물 삭제 확인 AlertDialog 표시
  void showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('삭제하기'),
          content: Text('게시물을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // AlertDialog 닫기
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                // 게시물을 삭제하고 AlertDialog 닫기
                deletePost(documentId, context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                        '게시물이 삭제되었습니다.',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      dismissDirection: DismissDirection.up,
                      duration: Duration(milliseconds: 1500),
                      backgroundColor: Colors.black),
                );
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }
}
