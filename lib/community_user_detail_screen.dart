import 'package:capstone/custom_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommunityUserDetailScreen extends StatefulWidget {
  final String title; // 제목
  final String content; // 내용
  final String uploaderImageURL; // 사용자 프로필 사진 URL
  final String uploadernickname; // 사용자 닉네임
  final String createDate; // 글을 올린 날짜와 시간
  final String collectionName; // 커뮤니티 종류
  final String documentId; // 게시물 고유 ID
  final int views; // 조회수
  final int like; // 좋아요
  final int comments; // 댓글 수
  final String photoURL; // 게시물 사진

  CommunityUserDetailScreen({
    required this.title,
    required this.content,
    required this.uploaderImageURL,
    required this.uploadernickname,
    required this.createDate,
    required this.collectionName,
    required this.documentId,
    required this.views,
    required this.like,
    required this.comments,
    required this.photoURL,
  });


  @override
  State<CommunityUserDetailScreen> createState() => _CommunityUserDetailScreenState();
}


class _CommunityUserDetailScreenState extends State<CommunityUserDetailScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _authentication = FirebaseAuth.instance;

  // 좋아요 초기값
  bool isLiked = false;

  // 현재 로그인한 사용자의 UID 가져오기
  String? userUID;

  void getCurrentUserUID() {
    final User? user = _authentication.currentUser;
    if (user != null) {
      userUID = user.uid;
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUserUID();
    getLikeStatus();
  }

  // Firestore에서 사용자의 좋아요 상태를 가져오는 함수
  void getLikeStatus() async {
    final likeDocument = await _firestore
        .collection(widget.collectionName)
        .doc(widget.documentId)
        .collection('Like')
        .doc(userUID)
        .get();

    if (likeDocument.exists) {
      setState(() {
        isLiked = likeDocument.data()!['liked'] ?? false; // Check if 'liked' field exists, set to false if not
      });
    } else {
      setState(() {
        isLiked = false; // Set to false if the document doesn't exist
      });
    }
  }


  // 사용자의 좋아요 여부를 저장하는 함수
  void saveLikeStatus(bool isLiked) {
    // Firestore에 저장된 게시물 문서의 경로
    String postDocumentPath = '${widget.collectionName}/${widget.documentId}';

    // 사용자의 UID 가져오기
    String userUID = FirebaseAuth.instance.currentUser!.uid;

    // 좋아요 상태를 저장할 컬렉션 경로
    String likeCollectionPath = '$postDocumentPath/Like';

    // 사용자별 좋아요 정보를 저장
    _firestore.collection(likeCollectionPath).doc(userUID).set({
      'liked': isLiked, // 사용자의 좋아요 상태
    });
  }


  // 게시물 삭제 함수
  Future<void> deletePost(String documentId, BuildContext context) async {
    try {
      // Firestore에서 게시물 삭제
      await _firestore.collection(widget.collectionName).doc(documentId).delete();
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
          title: Text('유저 게시판',
              style: TextStyle(color: Colors.white, fontSize: 20)),
          backgroundColor: Colors.black87,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios),
            iconSize: 30,
            color: Colors.white,
          ),
          // 게시물 신고 기능
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.white, size: 30),
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
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus(); // 빈 곳 터치시 키패드 사라짐
          },
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 게시글 제목
                            Text(widget.title,
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
                                      widget.uploaderImageURL,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // 글을 올린 유저의 닉네임
                                      Text(widget.uploadernickname,
                                          style: TextStyle(fontSize: 18)),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Text(widget.createDate,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey)),
                                          SizedBox(width: 3),
                                          Text('조회수',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey)),
                                          SizedBox(width: 3),
                                          Text('${widget.views}',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                  height: 1.5))
                                        ],
                                      )
                                      // 글을 올린 날짜와 시간
                                    ],
                                  ),
                                ),

                                // 좋아요 버튼
                                IconButton(
                                  onPressed: () {
                                    // Toggle the like status
                                    setState(() {
                                      isLiked = !isLiked;
                                    });

                                    // Save the like status to Firestore
                                    saveLikeStatus(isLiked);

                                    // Update the like count in Firestore
                                    updateLikeCount(isLiked);
                                  },
                                  icon: Icon(
                                    isLiked ? Icons.favorite : Icons.favorite_border,
                                    color: isLiked ? Colors.red : Colors.grey,
                                  ),
                                  iconSize: 40,
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                )

                              ],
                            ),

                            Line(),

                            // 게시글 내용
                            Text(widget.content, style: TextStyle(fontSize: 18)),

                            Line(),

                            Row(
                              children: [
                                Text(
                                  '댓글',
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '${widget.comments}',
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
                    ],
                  ),
                ),
              ),

              // 댓글 입력 버튼
              Stack(children: [
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
                      backgroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    child: Text('등록', style: TextStyle(fontSize: 16)),
                  ),
                )
              ]),
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
                deletePost(widget.documentId, context);
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

  // Firestore에서 좋아요 수를 업데이트하는 함수
  Future<void> updateLikeCount(bool isLiked) async {
    try {
      final postRef = _firestore.collection(widget.collectionName).doc(widget.documentId);

      // 사용자의 동작에 따라 좋아요 수를 업데이트합니다.
      if (isLiked) {
        await postRef.update({
          'like': FieldValue.increment(1), // 좋아요 수를 1 증가시킴
        });
      } else {
        await postRef.update({
          'like': FieldValue.increment(-1), // 좋아요 수를 1 감소시킴
        });
      }
    } catch (e) {
      print('좋아요 수 업데이트 오류: $e');
    }
  }
}
