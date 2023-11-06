import 'package:capstone/custom_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';


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
class CombinedData {
  final String title;
  final String content;
  final String uploaderEmail;
  final String uploaderImageURL;
  final String uploaderNickname;
  final String createDate;
  final String collectionName;
  final String documentId;
  final int views;
  final int like;
  final int comments;
  final String photoURL;
  final String endTime;
  final String nowPrice;
  final List<CommentData> commentsData;

  int get likeCount => like; // likeCount를 가져올 getter 메서드
  int get commentsCount => comments; // commentsCount를 가져올 getter 메서드

  CombinedData({
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
    required this.commentsData,
  });
}

class CommentData {
  final String commenterImageURL;
  final String commenterNickname;
  final String commentText;
  final String timestamp;

  CommentData({
    required this.commenterImageURL,
    required this.commenterNickname,
    required this.commentText,
    required this.timestamp,
  });
}
class _CommunityAuctionDetailScreenState extends State<CommunityAuctionDetailScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _authentication = FirebaseAuth.instance;
  final commentController = TextEditingController();
  // 좋아요 초기값
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    getCurrentUserUID();
    getCurrentUserEmail();
    getLikeStatus();
    getCommentCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('경매 게시판',
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
          // 게시물 삭제 기능
          actions: isCheckUploader()
              ? [
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.white, size: 30),
                    offset: Offset(0, 60),
                    onSelected: (value) {
                      if (value == 'delete') {showConfirmationDialog(context);}
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
                ]
              : [],
        ),
        body: SingleChildScrollView(
          child: StreamBuilder<CombinedData>(
            stream: _combineStreams(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('데이터를 불러올 수 없습니다.'));
              }
              final combinedData = snapshot.data;
              int likeCount = combinedData!.likeCount;
              int commentsCount = combinedData!.commentsCount;

              return Column(
                children: [
                  // 게시물 정보를 표시하는 부분
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 게시글 제목
                        Text(widget.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        SizedBox(height: 20),
                        // 경매 상품 사진
                        Center(
                          child: Container(
                            width: double.infinity,
                            height: 150,
                            color: Colors.black12,
                            child: (widget.photoURL == null || widget.photoURL.isEmpty)
                                ? Icon(Icons.photo, color: Colors.grey, size: 100)
                                : Image.network(widget.photoURL, fit: BoxFit.contain),
                          ),
                        ),
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
                                  Text(widget.uploaderNickname, style: TextStyle(fontSize: 18)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(widget.createDate, style: TextStyle(fontSize: 14, color: Colors.grey)),
                                          SizedBox(width: 3),
                                          Text('조회', style: TextStyle(fontSize: 14, color: Colors.grey)),
                                          SizedBox(width: 3),
                                          Text('${widget.views}', style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5)),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                                // 글을 올린 날짜와 시간
                              ),
                            ),
                            // 좋아요 버튼
                            Column(
                              children: [
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
                                    isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isLiked ? Colors.red : Colors.grey,
                                  ),
                                  iconSize: 40,
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),
                                // 좋아요 수 표시
                                Text('$likeCount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        Line(),
                        // 게시글 내용
                        Text(widget.content, style: TextStyle(fontSize: 18)),
                        SizedBox(height: 50),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('경매종료일', style: TextStyle(fontSize: 18)),
                            Text(widget.endTime, style: TextStyle(fontSize: 18)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('즉시낙찰가', style: TextStyle(fontSize: 18)),
                            Text(widget.nowPrice, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
                          ],
                        ),
                        Line(),
                        Row(
                          children: [
                            Text('댓글', style: TextStyle(fontSize: 14)),
                            SizedBox(width: 10),
                            // 댓글 수 표시
                            Text('$commentsCount', style: TextStyle(fontSize: 14, height: 1.4),
                            ),
                          ],
                        ),
                        Line(),
                      ],
                    ),
                  ),

                  // 댓글 목록을 표시하는 부분
                  Column(
                    children: combinedData.commentsData.map((comment) {
                      return Card(
                        elevation: 0,
                        margin: EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCommenterImage(comment.commenterImageURL),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(comment.commenterNickname, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Text(comment.commentText, style: TextStyle(fontSize: 16)),
                                Text(comment.timestamp, style: TextStyle(fontSize: 14, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  )



                ],
              );
            },
          ),
        ),

        bottomNavigationBar: BottomAppBar()
    );
  }

  // 게시물 정보, 댓글 정보를 가져오는 두 개의 스트림을 하나로 합침
  Stream<CombinedData> _combineStreams() {
    final postStream = _firestore.collection(widget.collectionName).doc(widget.documentId).snapshots();
    final commentsStream = _firestore.collection('${widget.collectionName}/${widget.documentId}/comments').orderBy('timestamp', descending: true).snapshots();

    return CombineLatestStream.combine2(postStream, commentsStream, (postSnapshot, commentsSnapshot) {
      final postData = postSnapshot.data();
      final commentsData = commentsSnapshot.docs.map((doc) {
        return CommentData(
          commenterImageURL: doc['commenterImageURL'] as String,
          commenterNickname: doc['commenterNickname'] as String,
          commentText: doc['text'] as String,
          timestamp: doc['timestamp'] as String,
        );
      }).toList();

      return CombinedData(
        title: widget.title,
        content: widget.content,
        uploaderEmail: widget.uploaderEmail,
        uploaderImageURL: widget.uploaderImageURL,
        uploaderNickname: widget.uploaderNickname,
        createDate: widget.createDate,
        collectionName: widget.collectionName,
        documentId: widget.documentId,
        views: widget.views,
        like: widget.like,
        comments: widget.comments,
        photoURL: widget.photoURL,
        endTime: widget.endTime,
        nowPrice: widget.nowPrice,
        commentsData: commentsData,
      );
    });
  }

  // 업로더의 프로필 사진을 표시하는 함수
  Widget _buildUploaderImage(String uploaderImageURL) {
    double _imageSize = 60.0;
    if (uploaderImageURL != null && uploaderImageURL.isNotEmpty) {
      return Container(
        width: _imageSize,
        height: _imageSize,
        child: ClipOval(
          child: Image.network(uploaderImageURL, width: _imageSize, height: _imageSize, fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      // uploaderImageURL이 공백 또는 null일 경우 기본 이미지 표시
      return Container(
        width: _imageSize,
        height: _imageSize,
        child: ClipOval(
          child: Image.asset('assets/images/defaultImage.png', width: _imageSize, height: _imageSize, fit: BoxFit.cover,
          ),
        ),
      );
    }
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

  // Firestore에서 좋아요 수를 업데이트하는 함수
  Future<void> updateLikeCount(bool isLiked) async {
    try {
      final postRef = _firestore.collection(widget.collectionName).doc(widget.documentId);

      // 사용자의 동작에 따라 좋아요 수를 업데이트합니다.
      if (isLiked) {
        await postRef.update({'like': FieldValue.increment(1),}); // 좋아요 수를 1 증가시킴
      } else {
        await postRef.update({'like': FieldValue.increment(-1),}); // 좋아요 수를 1 감소시킴
      }
    } catch (e) {
      print('좋아요 수 업데이트 오류: $e');
    }
  }

  //============================================================================

  // 현재 시간으로 createDate 설정
  String timestamp = '';
  void setTimestamp() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    timestamp = formatter.format(now);
  }

  // 댓글 등록 함수
  Future<void> addComment(String commentText, String commenterNickname,
      String commenterImageURL) async {
    try {
      // 댓글을 추가할 게시물의 경로
      String postDocumentPath = '${widget.collectionName}/${widget.documentId}';

      // 댓글 컬렉션 경로
      String commentsCollectionPath = '$postDocumentPath/comments';

      // 댓글을 Firestore에 추가
      await _firestore.collection(commentsCollectionPath).add({
        'text': commentText, // 댓글 내용
        'commenterNickname': commenterNickname, // 댓글 작성자의 닉네임
        'commenterImageURL': commenterImageURL, // 댓글 작성자의 프로필사진
        'timestamp': timestamp, // 댓글 작성 시간
      });

      // 댓글이 추가되면 해당 게시물의 댓글 수도 업데이트할 수 있습니다.
      await updateCommentCount(); // 댓글 수 업데이트 함수 호출
    } catch (e) {
      print('댓글 등록 중 오류 발생: $e');
    }
  }

  // 댓글 수 업데이트 함수
  Future<void> updateCommentCount() async {
    try {
      final postRef = _firestore.collection(widget.collectionName).doc(widget.documentId);

      // 댓글 컬렉션에 있는 댓글 문서 수를 가져옵니다.
      final commentsQuery = await postRef.collection('comments').get();

      int commentCount = commentsQuery.docs.length;

      // 게시물 문서의 'comments' 필드를 업데이트하여 댓글 수를 반영합니다.
      await postRef.update({'comments': commentCount});
    } catch (e) {
      print('댓글 수 업데이트 오류: $e');
    }
  }

  // 댓글 등록 버튼 클릭 시
  Future<void> onCommentButtonClicked(String commentText) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // 현재 로그인한 사용자의 UID 가져오기
      String userUID = user.uid;

      // Firestore에서 사용자 정보 가져오기
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('User').doc(userUID).get();

      if (userDoc.exists) {
        // Firestore에서 사용자 정보를 가져옴
        String commenterNickname = userDoc.get('nickname');
        String commenterImageURL = userDoc.get('imageURL');

        // 댓글 작성 시간 설정
        setTimestamp();

        // 댓글 등록 함수 호출
        addComment(commentText, commenterNickname, commenterImageURL);
      } else {
        print('사용자 정보를 찾을 수 없습니다.');
      }
    }
  }

  // 댓글 작성자의 프로필 사진을 표시하는 함수
  Widget _buildCommenterImage(String commenterImageURL) {
    double _imageSize = 40.0;
    if (commenterImageURL != null && commenterImageURL.isNotEmpty) {
      return Container(
        width: _imageSize,
        height: _imageSize,
        child: ClipOval(
          child: Image.network(commenterImageURL, width: _imageSize, height: _imageSize, fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      // commenterImageURL이 공백 또는 null일 경우 기본 이미지 표시
      return Container(
        width: _imageSize,
        height: _imageSize,
        child: ClipOval(
          child: Image.asset('assets/images/defaultImage.png', width: _imageSize, height: _imageSize, fit: BoxFit.cover,
          ),
        ),
      );
    }
  }

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
  // 사용자의 좋아요 여부를 저장하는 함수
  void saveLikeStatus(bool isLiked) {
    // Firestore에 저장된 게시물 문서의 경로
    String postDocumentPath = '${widget.collectionName}/${widget.documentId}';
    // 사용자의 UID 가져오기
    String userUID = FirebaseAuth.instance.currentUser!.uid;
    // 좋아요 상태를 저장할 컬렉션 경로
    String likeCollectionPath = '$postDocumentPath/Like';
    // 사용자별 좋아요 정보를 저장
    _firestore.collection(likeCollectionPath).doc(userUID).set({'liked': isLiked,});
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

  // 댓글 개수 가져옴
  Future<void> getCommentCount() async {
    int _commentsCount = 0;

    final querySnapshot = await _firestore
        .collection('${widget.collectionName}/${widget.documentId}/comments')
        .get();
    setState(() {
      _commentsCount = querySnapshot.docs.length;
    });
  }



}
