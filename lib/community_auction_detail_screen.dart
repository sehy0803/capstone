import 'dart:async';
import 'package:capstone/custom_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class CommunityAuctionDetailScreen extends StatefulWidget {
  final String title; // 제목
  final String content; // 내용
  final String uploaderUID; // 업로더 uid
  final String uploaderEmail; // 업로더 이메일
  final String uploaderImageURL; // 업로더 프로필 사진 URL
  final String uploaderNickname; // 업로더 닉네임
  final String collectionName; // 커뮤니티 종류
  final String documentId; // 게시물 고유 ID
  final int views; // 조회수
  final int like; // 좋아요 횟수
  final int comments; // 댓글 수
  final String photoURL; // 게시물 사진
  final int startBid; // 시작가
  final int winningBid; // 낙찰가
  final String winningBidder; // 낙찰자 닉네임
  final String winningBidderUID; // 낙찰자 uid
  final String status; // 경매 상태
  final Timestamp createDate; // 글을 올린 날짜와 시간
  final Timestamp endTime; // 경매 종료까지 남은 시간

  CommunityAuctionDetailScreen({
    required this.title,
    required this.content,
    required this.uploaderUID,
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
    required this.startBid,
    required this.winningBid,
    required this.winningBidder,
    required this.winningBidderUID,
    required this.status,
    required this.endTime,

  });
  @override
  State<CommunityAuctionDetailScreen> createState() =>
      _CommunityAuctionDetailScreenState();
}

class _CommunityAuctionDetailScreenState extends State<CommunityAuctionDetailScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _authentication = FirebaseAuth.instance;
  // 경매 종료까지 남은 시간을 저장하는 변수
  Duration _timeRemaining = Duration();
  // 입찰가 컨트롤러
  TextEditingController bidController = TextEditingController();
  // 입찰가 초기값
  int bid = 0;
  // 좋아요 초기값
  bool isLiked = false;
  // 타이머
  late Timer _timer; // _timer를 선언하고 초기화

  @override
  void dispose() {
    _timer.cancel(); // State가 소멸될 때 타이머도 종료
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getCurrentUserUID();
    getLikeStatus();
    getAuctionEndTime();

    // 1초마다 시간을 업데이트하는 타이머 설정
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      updateRemainingTime();
    });
  }

  // firestore에서 endTime을 가져오는 함수
  Future<DateTime?> getAuctionEndTime() async {
    final document = await FirebaseFirestore.instance
        .collection(widget.collectionName)
        .doc(widget.documentId)
        .get();

    final data = document.data();
    if (data != null && data['endTime'] != null) {
      // Firestore에서 endTime 가져오기
      final endTimeTimestamp = data['endTime'] as Timestamp;
      return endTimeTimestamp.toDate();
    }
    return null;
  }

  // 남은 시간을 업데이트하고, 타이머를 종료하는 함수
  void updateRemainingTime() async {
    DateTime? endTime = await getAuctionEndTime();
    if (endTime != null) {
      final now = DateTime.now();
      _timeRemaining = endTime.difference(now);

      if (_timeRemaining.isNegative) {
        _timer.cancel();
        _timeRemaining = Duration(); // 타이머가 종료되면 _timeRemaining을 0으로 설정

        updateAuctionStatus();
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy.MM.dd HH:mm').format(widget.createDate.toDate());
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('경매 게시판', style: TextStyle(color: Colors.white, fontSize: 20)),
          backgroundColor: DarkColors.basic,
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
                    icon: Icon(Icons.more_vert, color: Colors.grey, size: 30),
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
            if (!snapshot.hasData) {return Center(child: CircularProgressIndicator());}
            // 좋아요 수 가져오기
            int likeCount = snapshot.data!.get('like') ?? 0;
            // 시작가 가져오기
            int startBid = snapshot.data!.get('startBid') ?? 0;
            // 최고 입찰자 가져오기
            String winningBidder = snapshot.data!.get('winningBidder') ?? '';
            return GestureDetector(
              // 빈 곳 터치시 키패드 사라짐
              onTap: () {FocusScope.of(context).unfocus();},
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // 경매 상품 이미지
                          _buildAuctionImage(widget.photoURL),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 유저 정보 및 좋아요
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
                                              Text(formattedDate, style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.5)),
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
                                            setState(() {isLiked = !isLiked;});
                                            saveLikeStatus(isLiked);
                                            updateLikeCount(isLiked);
                                          },
                                          icon: Icon(
                                            isLiked ? Icons.favorite : Icons.favorite_border,
                                            color: isLiked ? Colors.red : Colors.grey,
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
                              ],
                            ),
                          ),
                          Container(height: 1, color: Colors.grey[300]),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Center(
                              child: Column(
                                children: [
                                  // 게시글 제목
                                  Text(widget.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  // 게시글 내용
                                  Text(widget.content, style: TextStyle(fontSize: 14)),
                                  SizedBox(height: 20),
                                  Text('최고 입찰자', style: TextStyle(fontSize: 14)),
                                  Text(winningBidder.isEmpty ? '아직 입찰자가 없습니다.' : winningBidder,
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
                                  Text('남은 시간 ${_timeRemaining.inHours}시간 ${(_timeRemaining.inMinutes % 60)}분 ${(_timeRemaining.inSeconds % 60)}초',
                                      style: TextStyle(fontSize: 14, color: Colors.redAccent)),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  // 입찰가 입력
                  StreamBuilder<int>(
                    stream: getWinningBidStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {return Center(child: CircularProgressIndicator());}
                      int winningBid = snapshot.data ?? widget.startBid;

                      return Stack(
                          children: [
                            Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xffeeeeee), // 그림자 색상
                                        offset: Offset(0, -10), // 그림자의 위치 (가로, 세로)
                                        blurRadius: 10.0, // 그림자의 흐림 정도
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('시작가', style: TextStyle(fontSize: 16, color: Colors.grey)),
                                            Text('$startBid원', style: TextStyle(fontSize: 16, color: Colors.grey)),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            // 경매 상태에 따라 Text 위젯의 텍스트를 동적으로 변경
                                            StreamBuilder<String>(
                                              stream: getAuctionStatusStream(),
                                              builder: (context, snapshot) {
                                                if (!snapshot.hasData) {
                                                  return Center(child: CircularProgressIndicator());
                                                }
                                                String status = snapshot.data ?? '경매 상태 없음';

                                                // Text 위젯의 텍스트를 동적으로 변경
                                                String textToShow = (status == '낙찰')
                                                    ? '낙찰가'
                                                    : (status == '경매 실패')
                                                    ? '경매 실패'
                                                    : '최소 입찰가';

                                                return Text(
                                                  textToShow,
                                                  style: TextStyle(fontSize: 20),
                                                );
                                              },
                                            ),
                                            Text('$winningBid원', style: TextStyle(fontSize: 20, color: Colors.blue))
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                StreamBuilder<String>(
                                  stream: getAuctionStatusStream(),
                                  builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                      return Center(child: CircularProgressIndicator());
                                      }
                                      String status = snapshot.data ?? '경매 상태 없음';
                                      return Visibility(
                                        visible: !(status == '낙찰' || status == '경매 실패' || isCheckUploader()),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller: bidController,
                                                onChanged: (value) {bid = int.tryParse(value) ?? 0;},
                                                keyboardType: TextInputType.number,
                                                decoration: InputDecoration(
                                                    enabledBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(color: Colors.white),
                                                      borderRadius: BorderRadius.all(Radius.circular(0.0)),
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(color: Colors.white),
                                                      borderRadius: BorderRadius.all(Radius.circular(0.0)),
                                                    ),
                                                    hintText: '입찰가 입력',
                                                    hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
                                                    contentPadding: EdgeInsets.all(15)),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 80,
                                              height: 55,
                                              child:ElevatedButton(
                                                onPressed: () {
                                                  if (bid >= widget.winningBid) {
                                                    showDialogBid(context);
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text('최소 입찰가 이상부터 입찰이 가능합니다.', style: TextStyle(fontSize: 16, color: Colors.white)),
                                                          dismissDirection: DismissDirection.up,
                                                          duration: Duration(milliseconds: 1500),
                                                          backgroundColor: Colors.black,
                                                        )
                                                    );
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(color: Colors.blue),
                                                    borderRadius: BorderRadius.circular(0.0),
                                                  ),
                                                ),
                                                child: Text('입찰', style: TextStyle(fontSize: 16)),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                  }
                                )
                              ],
                            ),
                          ]);
                    },
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

  // 경매 상태를 가져오는 함수
  Stream<String> getAuctionStatusStream() {
    String postDocumentPath = '${widget.collectionName}/${widget.documentId}';
    return FirebaseFirestore.instance
        .doc(postDocumentPath)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return doc.get('status') as String; // 'status' 필드의 값을 반환
      } else {
        return '경매 상태 없음'; // 문서가 존재하지 않을 때의 기본값 설정
      }
    });
  }

  // 경매 종료시 경매 상태를 업데이트 하는 함수
  void updateAuctionStatus() async {
    String postDocumentPath = '${widget.collectionName}/${widget.documentId}';
    final winningBidder = await getWinningBidder();
    if (winningBidder.isNotEmpty) {
      // 최고 입찰자가 있는 경우
      await FirebaseFirestore.instance.doc(postDocumentPath).update({
        'status': '낙찰',
      });

    } else {
      // 최고 입찰자가 없는 경우
      await FirebaseFirestore.instance.doc(postDocumentPath).update({
        'status': '경매 실패',
      });
    }
  }

  // 최고 입찰자를 가져오는 함수
  Future<String> getWinningBidder() async {
    final document = await _firestore
        .collection(widget.collectionName)
        .doc(widget.documentId)
        .get();
    final data = document.data();

    if (data != null && data['winningBidder'] != null) {
      return data['winningBidder'] as String;
    } else {
      return '';
    }
  }

  // 최소 입찰가를 가져올 스트림
  Stream<int> getWinningBidStream() {
    return _firestore
        .collection(widget.collectionName)
        .doc(widget.documentId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return doc.get('winningBid') as int;
      } else {
        // 문서가 존재하지 않을 때 처리
        return 0;
      }
    });
  }
  
  // 입찰을 수행할 함수
  void _saveBidData() async {

    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // 현재 로그인한 사용자의 UID 가져오기
      String userUID = user.uid;

      // Firestore에서 사용자 정보 가져오기
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('User').doc(userUID).get();

      if (userDoc.exists) {
        String bidderNickname = userDoc.get('nickname');

        // 입찰 정보를 추가할 게시물의 경로
        String postDocumentPath = '${widget.collectionName}/${widget.documentId}';

        // 현재 최소 입찰가, 최고 입찰자를 업데이트
        await FirebaseFirestore.instance.doc(postDocumentPath).update({
          'winningBid': bid,
          'winningBidder': bidderNickname,
          'winningBidderUID': userUID
        });

        // 입력 필드 지우기
        bidController.clear();
      }
    }
  }

  // 입찰 버튼 클릭시 다이얼로그를 표시하는 함수
  void showDialogBid(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('입찰 확인'),
          content: Text('입찰하시겠습니까?'),
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
                _saveBidData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '입찰 완료',
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

  //============================================================================

  // 경매 상품 사진을 표시하는 함수
  Widget _buildAuctionImage(String auctionImageURL) {
    double _imageSize = 200.0;
    return Center(
      child: Container(
        color: Colors.black,
        width: double.infinity,
        height: _imageSize,
        child: Image.network(auctionImageURL, width: _imageSize, height: _imageSize, fit: BoxFit.contain),
      ),
    );
  }

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
    Navigator.pop(context);
    try {
      // Firestore에서 경매 삭제하기 전에 해당 경매의 DocumentSnapshot을 가져오기
      final postSnapshot = await _firestore
          .collection(widget.collectionName)
          .doc(documentId)
          .get();

      if (postSnapshot.exists) {
        // DocumentSnapshot이 존재하는 경우에만 게시물을 삭제
        await _firestore
            .collection(widget.collectionName)
            .doc(documentId)
            .delete();
      } else {
        // DocumentSnapshot이 존재하지 않는 경우에 대한 처리
        print('경매가 이미 삭제되었습니다.');
      }
    } catch (e) {
      print('경매 삭제 중 오류 발생: $e');
    }
  }

  // 게시물 삭제 확인 AlertDialog 표시
  void showDialogDeletePost(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('삭제하기'),
          content: Text('경매를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {Navigator.pop(context);},
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deletePost(widget.documentId, context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('경매가 삭제되었습니다.', style: TextStyle(fontSize: 16, color: Colors.white),),
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

  // 현재 로그인한 사용자의 UID 가져오기
  String? userUID;
  void getCurrentUserUID() {
    final User? user = _authentication.currentUser;
    if (user != null) {userUID = user.uid;}
  }

  // 업로더의 uid와 현재 로그인한 사용자의 uid 비교
  bool isCheckUploader() {
    return userUID == widget.uploaderUID;
  }

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
