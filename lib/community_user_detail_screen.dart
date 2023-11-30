import 'package:capstone/custom_widget.dart';
import 'package:capstone/edit_post_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommunityUserDetailScreen extends StatefulWidget {
  final String documentId; // 게시물 고유 ID

  CommunityUserDetailScreen({
    required this.documentId,
  });

  @override
  State<CommunityUserDetailScreen> createState() =>
      _CommunityUserDetailScreenState();
}

class _CommunityUserDetailScreenState extends State<CommunityUserDetailScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _authentication = FirebaseAuth.instance;

  // 댓글 컨트롤러
  TextEditingController commentController = TextEditingController();

  // 좋아요 초기값
  bool isLiked = false;

  String userID = '';
  String uploaderUID = '';

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getUploaderUID();
    getLikeStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('유저 게시판', style: TextStyle(color: Colors.white, fontSize: 20)),
          backgroundColor: Colors.black87,
          leading: IconButton(
            onPressed: () {Navigator.pop(context);},
            icon: Icon(Icons.arrow_back_ios),
            iconSize: 30,
            color: Colors.white,
          ),
          // 게시물 삭제 기능
          actions: isCheckUploader(uploaderUID)
              ? [
            PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey, size: 30),
                offset: Offset(0, 60),
                onSelected: (value) {
                  if (value == 'delete') {
                    showDialogDeletePost(context);
                  } else if (value == 'edit') {
                    showDialogEditPost(context);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('수정하기'),
                    ),
                    PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('삭제하기'))];})]
              : [],
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection('UserCommunity').doc(widget.documentId).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {return Center(child: CircularProgressIndicator());}

            var data = snapshot.data!.data() as Map<String, dynamic>;

            // 유저 정보
            String uploaderUID = data['uploaderUID'] as String;

            // 경매 정보
            String title = data['title'] as String;
            String content = data['content'] as String;
            int views = data['views'] as int;
            int likes = data['likes'] as int;
            int comments = data['comments'] as int;

            // 시간 정보
            Timestamp createDate = data['createDate'] as Timestamp;
            String formattedCreateDate = DateFormat('yyyy.MM.dd HH:mm').format(createDate.toDate());

            return StreamBuilder<DocumentSnapshot>(
                stream: _firestore.collection('User').doc(uploaderUID).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {return Center(child: CircularProgressIndicator());}

                  var uploaderData = snapshot.data!.data() as Map<String, dynamic>;

                  // 업로더 정보
                  String uploaderImageURL = uploaderData['imageURL'] ?? '';
                  String uploaderNickname = uploaderData['nickname'] ?? '';

                  return GestureDetector(
                    // 빈 곳 터치시 키패드 사라짐
                    onTap: () {FocusScope.of(context).unfocus();},
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                      ),
                                      // 유저 정보
                                      Row(
                                          children: [
                                            // 글을 올린 유저의 프로필 사진
                                            _buildUploaderImage(uploaderImageURL),
                                            SizedBox(width: 5),
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      // 글을 올린 유저의 닉네임
                                                      Text(uploaderNickname,
                                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                                      SizedBox(height: 2),
                                                      Row(
                                                          children: [
                                                            Text(formattedCreateDate,
                                                                style: TextStyle(fontSize: 12, color: Colors.grey)),
                                                            SizedBox(width: 3),
                                                            Text('조회',
                                                                style: TextStyle(fontSize: 12, color: Colors.grey)),
                                                            SizedBox(width: 3),
                                                            Text('$views',
                                                                style: TextStyle(fontSize: 12, color: Colors.grey))])])),

                                            // 좋아요 버튼
                                            Column(
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      setState(() {isLiked = !isLiked;});
                                                      saveLikeStatus(isLiked);
                                                      updateLikeCount(isLiked);
                                                    },
                                                    icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border,
                                                      color: isLiked ? Colors.red : Colors.grey,
                                                    ),
                                                    iconSize: 30,
                                                    padding: EdgeInsets.zero,
                                                    constraints: BoxConstraints(),
                                                  ),
                                                  // 좋아요 수 표시
                                                  Text('$likes', style: TextStyle(fontSize: 12))
                                                ]
                                            )
                                          ]
                                      ),
                                    ],
                                  ),
                                ),
                                Container(height: 1, color: Colors.grey[300]),
                                // 게시글 내용
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Text(content, style: TextStyle(fontSize: 16)),
                                    ),
                                    Container(color: Colors.black12, height: 1),
                                    Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Text('댓글 $comments', style: TextStyle(fontSize: 14)),
                                    ),
                                    // 댓글창을 표시하는 부분
                                    StreamBuilder<QuerySnapshot>(
                                      stream: _firestore.collection('UserCommunity/${widget.documentId}/Comment')
                                          .orderBy('timestamp', descending: false).snapshots(),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {return Center(child: CircularProgressIndicator());}

                                        // 댓글이 있는 경우
                                        var comments = snapshot.data!.docs;

                                        return Column(
                                          children: comments.asMap().entries.map((entry) {
                                            final index = entry.key;
                                            final commentData = entry.value.data() as Map<String, dynamic>;

                                            // 코맨터 정보
                                            String commenterUID = commentData['commenterUID'] as String;
                                            String text = commentData['text'] as String;
                                            Timestamp timestamp = commentData['timestamp'] as Timestamp;
                                            String formattedTimestamp = DateFormat('yyyy.MM.dd HH:mm').format(timestamp.toDate());

                                            return StreamBuilder<DocumentSnapshot>(
                                                stream: _firestore.collection('User').doc(commenterUID).snapshots(),
                                                builder: (context, snapshot) {
                                                  if (!snapshot.hasData) {return Center(child: CircularProgressIndicator());}

                                                  var commenterData = snapshot.data!.data() as Map<String, dynamic>;

                                                  // 업로더 정보
                                                  String commenterImageURL = commenterData['imageURL'] ?? '';
                                                  String commenterNickname = commenterData['nickname'] ?? '';

                                                  return Column(
                                                    children: [
                                                      Card(
                                                        elevation: 0,
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(10.0),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Row(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  _buildCommenterImage(commenterImageURL),
                                                                  SizedBox(width: 10),
                                                                  Column(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      SizedBox(
                                                                        width: MediaQuery.of(context).size.width- 100,
                                                                        child: Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text(commenterNickname, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                                                            // 댓글 삭제 버튼
                                                                            _buildDeleteCommenterButton(commenterUID, comments[index].id)
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: 5),
                                                                      SizedBox(
                                                                          width: MediaQuery.of(context).size.width - 100,
                                                                          child: Text(text, style: TextStyle(fontSize: 14), maxLines: 5, overflow: TextOverflow.ellipsis)),
                                                                      SizedBox(height: 5),
                                                                      Text(formattedTimestamp, style: TextStyle(fontSize: 12, color: Colors.grey)),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Container(color: Colors.black12, height: 1)
                                                    ],
                                                  );
                                                }
                                            );
                                          }).toList(),
                                        );
                                      },
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 댓글 입력 버튼
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: commentController,
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(0.0)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(0.0)),
                                    ),
                                    hintText: '댓글을 남겨보세요',
                                    hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
                                    contentPadding: EdgeInsets.all(15)),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: () {
                                  if(commentController.text.isEmpty){
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('댓글을 입력해주세요.',
                                              style: TextStyle(fontSize: 16, color: Colors.white)),
                                          dismissDirection: DismissDirection.up,
                                          duration: Duration(milliseconds: 1500),
                                          backgroundColor: Colors.black,
                                        )
                                    );
                                  } else {
                                    showDialogAddComment(context);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: DarkColors.basic,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0.0)),
                                ),
                                child: Text('등록', style: TextStyle(fontSize: 16)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
            );
          },
        ),
        bottomNavigationBar: BottomAppBar());
  }

  // ===========================================================================

  // 현재 로그인한 유저의 UID 저장
  void getCurrentUser() async {
    final user = _authentication.currentUser;
    if (user != null) {
      setState(() {
        userID = user.uid;
      });
    }
  }

  // uploaderUID를 가져오는 함수
  void getUploaderUID() async {
    final document = await _firestore
        .collection('UserCommunity')
        .doc(widget.documentId)
        .get();
    final data = document.data();

    if (data != null && data['uploaderUID'] != null) {
      setState(() {
        uploaderUID = data['uploaderUID'] as String;
      });
    }
  }

  // 업로더의 uid와 현재 로그인한 사용자의 uid 비교
  bool isCheckUploader(String uploaderUID) {
    return userID == uploaderUID;
  }

  // 코멘터의 uid와 현재 로그인한 사용자의 uid 비교
  bool isCheckCommenter(String commenterUID) {
    return userID == commenterUID;
  }

  //============================================================================

  // 게시물 수정 확인 AlertDialog 표시
  void showDialogEditPost(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('수정하기'),
          content: Text('게시물을 수정하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {Navigator.pop(context);},
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPostScreen(documentId: widget.documentId),
                  ),
                );
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 댓글을 등록하는 함수
  void addComment() async {
    final commentText = commentController.text;
    if (commentText.isNotEmpty) {
      // Firestore에서 사용자 정보 가져오기
      String commenterUID = userID;
      Timestamp timestamp = Timestamp.fromDate(DateTime.now());

      // Firestore에 추가할 댓글 정보 묶음
      final commentData = {
        'text': commentText,
        'commenterUID': commenterUID,
        'timestamp': timestamp
      };

      await FirebaseFirestore.instance
          .collection('UserCommunity')
          .doc(widget.documentId)
          .collection('Comment')
          .add(commentData);

      await updateCommentCount();

      // 입력 필드 지우기
      commentController.clear();
    }
  }

  // 댓글 등록 버튼 클릭시 다이얼로그를 표시하는 함수
  void showDialogAddComment(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('댓글 등록 확인'),
          content: Text('댓글을 등록하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                addComment();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '댓글이 등록되었습니다.',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    dismissDirection: DismissDirection.up,
                    duration: Duration(milliseconds: 1500),
                    backgroundColor: Colors.black,
                  ),
                );
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 댓글 수 업데이트 함수
  Future<void> updateCommentCount() async {
    try {
      final postRef = _firestore.collection('UserCommunity').doc(widget.documentId);
      final commentsQuery = await postRef.collection('Comment').get();
      int comments = commentsQuery.docs.length;
      await postRef.update({'comments': comments});
    } catch (e) {
      print('댓글 수 업데이트 오류: $e');
    }
  }

  // 댓글 삭제 버튼
  IconButton _buildDeleteCommenterButton(String commenterUID, String commentId) {
    if (isCheckCommenter(commenterUID)) {
      return IconButton(
        onPressed: () {
          showDialogDeleteComment(context, commentId);
        },
        icon: Icon(Icons.more_horiz, color: Colors.black26),
        iconSize: 20,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(),
      );
    } else {
      // 만약 현재 로그인한 사용자와 댓글 작성자가 다르다면 버튼을 숨김
      return IconButton(
        onPressed: () {},
        icon: Icon(Icons.close),
        iconSize: 25,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(),
        color: Colors.transparent,
      );
    }
  }

  // 댓글 삭제 확인 AlertDialog 표시
  void showDialogDeleteComment(BuildContext context, String commentId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('삭제하기'),
          content: Text('댓글을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {Navigator.pop(context);},
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                // 댓글 삭제하고 AlertDialog 닫기
                deleteComment(commentId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('댓글이 삭제되었습니다.', style: TextStyle(fontSize: 16, color: Colors.white),),
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

  // 댓글 삭제 함수
  Future<void> deleteComment(String commentId) async {
    String commentPath = 'UserCommunity/${widget.documentId}/Comment';
    try {
      await _firestore.collection(commentPath).doc(commentId).delete();
      updateCommentCount();
    } catch (e) {
      print('댓글 삭제 중 오류 발생: $e');
    }
  }

  // 댓글 작성자의 프로필 사진을 표시하는 함수
  Widget _buildCommenterImage(String commenterImageURL) {
    double _imageSize = 30.0;
    if (commenterImageURL != null && commenterImageURL.isNotEmpty) {
      return SizedBox(
        width: _imageSize,
        height: _imageSize,
        child: ClipOval(
          child: Image.network(commenterImageURL, width: _imageSize, height: _imageSize, fit: BoxFit.cover,),
        ),
      );
    } else {
      // commenterImageURL이 공백 또는 null일 경우 기본 이미지 표시
      return SizedBox(
        width: _imageSize,
        height: _imageSize,
        child: ClipOval(
          child: Image.asset('assets/images/defaultImage.png', width: _imageSize, height: _imageSize, fit: BoxFit.cover,),
        ),
      );
    }
  }

  // 업로더의 프로필 사진을 표시하는 함수
  Widget _buildUploaderImage(String uploaderImageURL) {
    double _imageSize = 40.0;
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

  //============================================================================
  // 게시물 삭제 함수
  Future<void> deletePost(String documentId, BuildContext context) async {
    try {
      // Firestore에서 게시물 삭제
      await _firestore
          .collection('UserCommunity')
          .doc(documentId)
          .delete();

      // 삭제된 게시글과 관련된 데이터 삭제
      await _deleteRelatedData(widget.documentId);

      Navigator.pop(context);
    } catch (e) {
      print('게시물 삭제 중 오류 발생: $e');
    }
  }

  // 게시글과 관련된 데이터 삭제 함수
  Future<void> _deleteRelatedData(String postId) async {
    // 컬렉션에서 해당 게시글의 ID를 가진 문서를 찾아 삭제
    var userSnapshots = await _firestore.collection('User').get();
    for (var userSnapshot in userSnapshots.docs) {
      String userUID = userSnapshot.id;

      var userLikesDocument  = await _firestore
          .collection('User')
          .doc(userUID)
          .collection('userLikes')
          .doc(postId)
          .get();

      if (userLikesDocument.exists) {
        await userLikesDocument.reference.delete();
      }
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
  // Firestore에서 사용자의 좋아요 상태를 가져오는 함수
  void getLikeStatus() async {
    String userUID = _authentication.currentUser!.uid;
    final likeDocument = await _firestore
        .collection('UserCommunity')
        .doc(widget.documentId)
        .collection('Like')
        .doc(userUID)
        .get();

    if (likeDocument.exists) {
      setState(() {
        isLiked = likeDocument.data()!['liked'] ??
            false;
      });
    } else {
      setState(() {
        isLiked = false;
      });
    }
  }

  // 사용자의 좋아요 여부를 저장하는 함수
  void saveLikeStatus(bool isLiked) {
    // Firestore에 저장된 게시물 문서의 경로
    String postDocumentPath = '${'UserCommunity'}/${widget.documentId}';

    // 좋아요 상태를 저장할 컬렉션 경로
    String likeCollectionPath = '$postDocumentPath/Like';

    // 사용자별 좋아요 정보를 저장
    _firestore.collection(likeCollectionPath).doc(userID).set({
      'liked': isLiked, // 사용자의 좋아요 상태
    });

    // 만약 좋아요를 눌렀다면, 사용자의 "좋아요" 목록에 게시물 ID를 추가
    if (isLiked) {
      addPostToUserLikes(widget.documentId);
    } else {
      // 만약 좋아요를 취소했다면, 사용자의 "좋아요" 목록에서 게시물 ID를 제거
      removePostFromUserLikes(widget.documentId);
    }
  }

  // Firestore에서 좋아요 수를 업데이트하는 함수
  Future<void> updateLikeCount(bool isLiked) async {
    try {
      final postRef = _firestore.collection('UserCommunity').doc(widget.documentId);

      // 사용자의 동작에 따라 좋아요 수를 업데이트합니다.
      if (isLiked) {
        await postRef.update({
          'likes': FieldValue.increment(1), // 좋아요 수를 1 증가시킴
        });
      } else {
        await postRef.update({
          'likes': FieldValue.increment(-1), // 좋아요 수를 1 감소시킴
        });
      }
    } catch (e) {
      print('좋아요 수 업데이트 오류: $e');
    }
  }

  // 사용자의 "좋아요" 목록에 게시물 ID를 추가하는 함수 (UserCommunity에 추가)
  Future<void> addPostToUserLikes(String postID) async {
    // User 컬렉션에서 사용자의 UID로 업로더 문서 가져오기
    final userDocument = _firestore.collection('User').doc(userID);

    // userLikes 컬렉션 참조 가져오기
    final userLikesCollection = userDocument.collection('userLikes');

    // 사용자가 게시물에 좋아요를 누른 경우, 해당 게시물의 ID로 새로운 문서 추가
    await userLikesCollection.doc(postID).set({
      'postId': widget.documentId,
      'liked': true,
      'postType': 'UserCommunity' // 유저 게시글임을 나타내는 특정 필드 추가
    });
  }

  // 사용자의 "좋아요" 목록에 게시물 ID를 삭제하는 함수
  Future<void> removePostFromUserLikes(String postID) async {
    // User 컬렉션에서 사용자의 UID로 업로더 문서 가져오기
    final userDocument = _firestore.collection('User').doc(userID);

    // userLikes 컬렉션 참조 가져오기
    final userLikesCollection = userDocument.collection('userLikes');

    // 사용자의 "좋아요" 목록에서 게시물 ID를 제거
    await userLikesCollection.doc(postID).delete();
  }

}