import 'package:capstone/custom_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class CommunityAuctionDetailScreen extends StatefulWidget {
  final String title; // 제목
  final String content; // 내용
  final String uploaderEmail; // 업로더 이메일
  final String uploaderImageURL; // 업로더 프로필 사진 URL
  final String uploaderNickname; // 업로더 닉네임
  final String createDate; // 글을 올린 날짜와 시간
  final String collectionName; // 커뮤니티 종류
  final String documentId; // 게시물 고유 ID
  final int views; // 조회수
  final int like; // 좋아요 횟수
  final int comments; // 댓글 수
  final String photoURL; // 게시물 사진
  final String endTime; // 경매 종료시간
  final String nowPrice; // 즉시낙찰가

  CommunityAuctionDetailScreen({
    required this.title,
    required this.content,
    required this.uploaderEmail,
    required this.uploaderImageURL,
    required this.uploaderNickname,
    required this.createDate,
    required this.collectionName,
    required this.documentId,
    required this.views,
    required this.like,
    required this.comments,
    required this.photoURL,
    required this.endTime,
    required this.nowPrice,

  });
  @override
  State<CommunityAuctionDetailScreen> createState() =>
      _CommunityAuctionDetailScreenState();
}

class _CommunityAuctionDetailScreenState extends State<CommunityAuctionDetailScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _authentication = FirebaseAuth.instance;

  // 좋아요 초기값
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    getCurrentUserUID();
    getCurrentUserEmail();
    getLikeStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('경매 게시판', style: TextStyle(color: Colors.white, fontSize: 20)),
          backgroundColor: Colors.black87,
          leading: IconButton(
            onPressed: () {Navigator.pop(context);},
            icon: Icon(Icons.arrow_back_ios),
            iconSize: 30,
            color: Colors.white,
          ),
          // 게시물 삭제 기능
          actions: isCheckUploader()
              ? [
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.white, size: 30),
                    offset: Offset(0, 60),
                    onSelected: (value) {if (value == 'delete') {showDialogDeletePost(context);}},
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('삭제하기'),
                        ),
                      ];
                    },
                  ),
                ]
              : [],
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection(widget.collectionName).doc(widget.documentId).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            int likeCount = snapshot.data!.get('like') ?? 0;

            return GestureDetector(
              // 빈 곳 터치시 키패드 사라짐
              onTap: () {FocusScope.of(context).unfocus();},
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
                                Text(widget.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                SizedBox(height: 20),
                                // 유저 정보
                                Row(
                                  children: [
                                    // 글을 올린 유저의 프로필 사진
                                    _buildUploaderImage(widget.uploaderImageURL),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // 글을 올린 유저의 닉네임
                                          Text(widget.uploaderNickname, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Text(widget.createDate, style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.5)),
                                              SizedBox(width: 3),
                                              Text('조회', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                              SizedBox(width: 3),
                                              Text('${widget.views}', style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.5))
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // 좋아요 버튼
                                    Column(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              isLiked = !isLiked;
                                            });
                                            saveLikeStatus(isLiked);
                                            updateLikeCount(isLiked);
                                          },
                                          icon: Icon(
                                            isLiked ? Icons.favorite : Icons
                                                .favorite_border,
                                            color: isLiked ? Colors.red : Colors
                                                .grey,
                                          ),
                                          iconSize: 35,
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                        ),
                                        // 좋아요 수 표시
                                        Text('$likeCount', style: TextStyle(fontSize: 12))
                                      ],
                                    ),
                                  ],
                                ),
                                Line(),
                                // 게시글 내용
                                Text(widget.content,
                                    style: TextStyle(fontSize: 16)),
                                SizedBox(height: 10),
                                commentLine(),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),


                ],
              ),
            );
          },
        ),
        bottomNavigationBar: BottomAppBar()
    );
  }

  //============================================================================

  // 업로더의 프로필 사진을 표시하는 함수
  Widget _buildUploaderImage(String uploaderImageURL) {
    double _imageSize = 50.0;
    if (uploaderImageURL != null && uploaderImageURL.isNotEmpty) {
      return SizedBox(
        width: _imageSize,
        height: _imageSize,
        child: ClipOval(
          child: Image.network(uploaderImageURL, width: _imageSize, height: _imageSize, fit: BoxFit.cover,),
        ),
      );
    } else {
      // uploaderImageURL이 공백 또는 null일 경우 기본 이미지 표시
      return SizedBox(
        width: _imageSize,
        height: _imageSize,
        child: ClipOval(
          child: Image.asset('assets/images/defaultImage.png', width: _imageSize, height: _imageSize, fit: BoxFit.cover,),
        ),
      );
    }
  }

  // 게시물 삭제 함수
  Future<void> deletePost(String documentId, BuildContext context) async {
    try {
      // Firestore에서 게시물 삭제
      await _firestore
          .collection(widget.collectionName)
          .doc(documentId)
          .delete();
      Navigator.pop(context);
    } catch (e) {
      print('게시물 삭제 중 오류 발생: $e');
    }
  }

  // 게시물 삭제 확인 AlertDialog 표시
  void showDialogDeletePost(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('삭제하기'),
          content: Text('게시물을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {Navigator.pop(context);},
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                // 게시물을 삭제하고 AlertDialog 닫기
                deletePost(widget.documentId, context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('게시물이 삭제되었습니다.', style: TextStyle(fontSize: 16, color: Colors.white),),
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
  //============================================================================

  // 현재 로그인한 사용자의 UID 가져오기
  String? userUID;
  void getCurrentUserUID() {
    final User? user = _authentication.currentUser;
    if (user != null) {userUID = user.uid;}
  }
  // 현재 로그인한 사용자의 이메일 가져오기
  String? userEmail;
  void getCurrentUserEmail() {
    final User? user = _authentication.currentUser;
    if (user != null) {userEmail = user.email;}
  }
  // 업로더 이메일과 현재 로그인한 사용자의 이메일 비교
  bool isCheckUploader() {return userEmail == widget.uploaderEmail;}
  // Firestore에서 사용자의 좋아요 상태를 가져오는 함수
  void getLikeStatus() async {
    final likeDocument = await _firestore.collection(widget.collectionName).doc(widget.documentId).collection('Like').doc(userUID).get();
    if (likeDocument.exists) {setState(() {isLiked = likeDocument.data()!['liked'] ?? false;});
    } else {setState(() {isLiked = false;});}
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

    // 만약 좋아요를 눌렀다면, 사용자의 "좋아요" 목록에 게시물 ID를 추가
    if (isLiked) {
      addPostToUserLikes(userUID, widget.documentId);
    } else {
      // 만약 좋아요를 취소했다면, 사용자의 "좋아요" 목록에서 게시물 ID를 제거
      removePostFromUserLikes(userUID, widget.documentId);
    }
  }

  // 사용자의 "좋아요" 목록에 게시물 ID를 추가하는 함수
  Future<void> addPostToUserLikes(String userUID, String postID) async {
    // User 컬렉션에서 사용자의 UID로 업로더 문서 가져오기
    final userDocument = _firestore.collection('User').doc(userUID);

    // userLikes 컬렉션 참조 가져오기
    final userLikesCollection = userDocument.collection('userLikes');

    // 사용자가 게시물에 좋아요를 누른 경우, 해당 게시물의 ID로 새로운 문서 추가
    await userLikesCollection.doc(postID).set({
      'liked': true,
    });
  }

  // 사용자의 "좋아요" 목록에 게시물 ID를 삭제하는 함수
  Future<void> removePostFromUserLikes(String userUID, String postID) async {
    try {
      // User 컬렉션에서 사용자의 UID로 업로더 문서 가져오기
      final userDocument = _firestore.collection('User').doc(userUID);

      // userLikes 컬렉션 참조 가져오기
      final userLikesCollection = userDocument.collection('userLikes');

      // 사용자의 "좋아요" 목록에서 게시물 ID를 제거
      await userLikesCollection.doc(postID).delete();
    } catch (e) {
      print('게시물을 사용자 "좋아요" 목록에서 제거 중 오류 발생: $e');
    }
  }

}
