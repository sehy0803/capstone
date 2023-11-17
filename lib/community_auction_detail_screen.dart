import 'dart:async';
import 'package:capstone/custom_widget.dart';
import 'package:capstone/edit_auction_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommunityAuctionDetailScreen extends StatefulWidget {
  final String documentId; // 게시물 고유 ID

  CommunityAuctionDetailScreen({
    required this.documentId,
  });

  @override
  State<CommunityAuctionDetailScreen> createState() =>
      _CommunityAuctionDetailScreenState();
}

class _CommunityAuctionDetailScreenState extends State<CommunityAuctionDetailScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _authentication = FirebaseAuth.instance;
  TextEditingController bidController = TextEditingController();

  String uploaderUID = '';
  String status = '';
  int bid = 0;
  bool isLiked = false;

  Timer? _timer;
  Timer? waitingTimer;
  Timer? remainingTimer;

  Duration remainingTime = Duration.zero;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getUploaderUID();
    getLikeStatus();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    String userUID = _authentication.currentUser!.uid;
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
          // 게시물 삭제 및 수정 기능
          actions: isCheckUploader(userUID)
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
                    PopupMenuItem<String>(value: 'edit', child: Text('수정하기'),),
                    PopupMenuItem<String>(value: 'delete', child: Text('삭제하기'))];})] : [],
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection('AuctionCommunity').doc(widget.documentId).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {return Center(child: CircularProgressIndicator());}

            var auctionData = snapshot.data!.data() as Map<String, dynamic>;

            // 유저 정보
            String uploaderUID = auctionData['uploaderUID'] as String;
            String winningBidderUID = auctionData['winningBidderUID'] ?? '';

            // 경매 정보
            String photoURL = auctionData['photoURL'] as String;
            String title = auctionData['title'] as String;
            String content = auctionData['content'] as String;
            int views = auctionData['views'] + 1 as int;
            int like = auctionData['like'] as int;
            int startBid = auctionData['startBid'] as int;
            int winningBid = auctionData['winningBid'] as int;
            String status = auctionData['status'] as String;

            // 시간 정보
            Timestamp createDate = auctionData['createDate'] as Timestamp;
            String formattedCreateDate = DateFormat('yyyy.MM.dd HH:mm').format(createDate.toDate());
            Timestamp startTime = auctionData['startTime'] as Timestamp;
            Timestamp endTime = auctionData['endTime'] as Timestamp;
            int remainingTime = auctionData['remainingTime'] as int;
            Duration remainingTimeSeconds = Duration(seconds: remainingTime);

            
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
                                        children: [
                                          // 경매 상품 이미지
                                          _buildAuctionImage(photoURL),
                                          Padding(
                                              padding: const EdgeInsets.all(20.0),
                                              child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    // 유저 정보 및 좋아요
                                                    Row(
                                                        children: [
                                                          // 글을 올린 유저의 프로필 사진
                                                          _buildUploaderImage(uploaderImageURL),
                                                          SizedBox(width: 10),
                                                          Expanded(
                                                              child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    // 글을 올린 유저의 닉네임
                                                                    Text(uploaderNickname,
                                                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                                                    SizedBox(height: 5),
                                                                    Row(
                                                                        children: [
                                                                          Text(formattedCreateDate,
                                                                              style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.5)),
                                                                          SizedBox(width: 3),
                                                                          Text('조회',
                                                                              style: TextStyle(fontSize: 12, color: Colors.grey)),
                                                                          SizedBox(width: 3),
                                                                          Text('$views',
                                                                              style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.5))])])),

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
                                                                  iconSize: 35,
                                                                  padding: EdgeInsets.zero,
                                                                  constraints: BoxConstraints(),
                                                                ),
                                                                // 좋아요 수 표시
                                                                Text('$like', style: TextStyle(fontSize: 12))])])])),

                                          Container(height: 1, color: Colors.grey[300]),
                                          Padding(
                                              padding: const EdgeInsets.all(20.0),
                                              child: SizedBox(
                                                  width: double.infinity,
                                                  child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(title,
                                                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                                        Text(content, style: TextStyle(fontSize: 14))]))),
                                          SizedBox(height: 50),
                                          Text('최고 입찰자', style: TextStyle(fontSize: 14)),
                                          StreamBuilder<DocumentSnapshot>(
                                            stream: winningBidderUID.isNotEmpty
                                                ? _firestore.collection('User').doc(winningBidderUID).snapshots()
                                                : null,
                                            builder: (context, snapshot) {
                                              if (winningBidderUID.isEmpty) {
                                                return Text('아직 입찰자가 없습니다.',
                                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber));
                                              }

                                              if (!snapshot.hasData) {return Center(child: CircularProgressIndicator());}

                                              var winningBidderData = snapshot.data!.data() as Map<String, dynamic>;
                                              String winningBidderNickname = winningBidderData['nickname'] ?? '';

                                              return Text(winningBidderNickname,
                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
                                              );
                                            },
                                          ),
                                        ]
                                    ))),

                            // 입찰가 입력
                            Stack(
                                children: [
                                  Column(
                                      children: [
                                        Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(color: Color(0xffeeeeee), offset: Offset(0, -10), blurRadius: 10.0,),
                                              ],
                                            ),
                                            child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      _buildStatusText(status, createDate, startTime, remainingTimeSeconds),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text('시작가',
                                                              style: TextStyle(fontSize: 16, color: Colors.grey)),
                                                          Text('$startBid원',
                                                              style: TextStyle(fontSize: 16, color: Colors.grey)),
                                                        ],
                                                      ),
                                                      Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text((status == '낙찰') ? '낙찰가'
                                                                : (status == '경매 실패') ? '경매 실패'
                                                                : '최소 입찰가',
                                                                style: TextStyle(fontSize: 20)),
                                                            Text('$winningBid원', style: TextStyle(fontSize: 20, color: Colors.blue))])]))),

                                        Visibility(
                                            visible: status == '진행중' && !isCheckUploader(userUID),
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
                                                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white),
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
                                                      child: ElevatedButton(
                                                          onPressed: () {
                                                            if (bid >= winningBid) {
                                                              showDialogBid(context);
                                                            } else {
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackBar(content: Text('최소 입찰가 이상부터 입찰이 가능합니다.',
                                                                      style: TextStyle(fontSize: 16, color: Colors.white)),
                                                                    dismissDirection: DismissDirection.up,
                                                                    duration: Duration(milliseconds: 1500),
                                                                    backgroundColor: Colors.black,
                                                                  ));
                                                            }
                                                          },
                                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue,
                                                            shape: RoundedRectangleBorder(
                                                              side: BorderSide(color: Colors.blue),
                                                              borderRadius: BorderRadius.circular(0.0),
                                                            ),
                                                          ),
                                                          child: Text('입찰', style: TextStyle(fontSize: 16))))])
                                        )
                                      ]
                                  )
                                ])
                          ]
                      )
                  );
                }
            );}),
        bottomNavigationBar: BottomAppBar());
  }

  //============================================================================

  // 남은 시간을 가져오는 스트림
  Stream<int> getRemainingTimeStream() {
    String postPath = 'AuctionCommunity/${widget.documentId}';
    return FirebaseFirestore.instance
        .doc(postPath)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return doc.get('remainingTime') as int;
      } else {
        return 0;
      }
    });
  }

  // 입찰을 수행할 함수
  void _saveBidData() async {
    // 현재 로그인한 사용자의 UID 가져오기
    String userUID = _authentication.currentUser!.uid;

    // Firestore에서 사용자 정보 가져오기
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('User')
        .doc(userUID)
        .get();

    String winningBidderNickname = userDoc.get('nickname');
    String postPath = 'AuctionCommunity/${widget.documentId}';
    await FirebaseFirestore.instance.doc(postPath).update({
      'winningBid': bid,
      'winningBidderUID': userUID,
      'winningBidderNickname': winningBidderNickname,
    });

    // 입력 필드 지우기
    bidController.clear();
  }

  // 최고 입찰자를 가져오는 함수
  Future<String> getWinningBidderUID() async {
    final document = await _firestore
        .collection('AuctionCommunity')
        .doc(widget.documentId)
        .get();
    final data = document.data();

    if (data != null && data['winningBidderUID'] != null) {
      return data['winningBidderUID'] as String;
    } else {
      return '';
    }
  }

  // 경매 종료시 경매 상태를 업데이트 하는 함수
  void updateAuctionEndStatus() async {
    String postPath = 'AuctionCommunity/${widget.documentId}';
    final winningBidderUID = await getWinningBidderUID();
    if (winningBidderUID.isNotEmpty) {
      // 최고 입찰자가 있는 경우
      await _firestore.doc(postPath).update({
        'status': '낙찰',
      });
    } else {
      // 최고 입찰자가 없는 경우
      await _firestore.doc(postPath).update({
        'status': '경매 실패',
      });
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

  // 시간에 따라 경매 상태를 업데이트 하는 함수
  void updateAuctionStatus() async {
    final postPath = _firestore.collection('AuctionCommunity').doc(widget.documentId);
    Map<String, dynamic> times = await getAuctionTimes();
    DateTime startTime = times['startTime'];

    if (DateTime.now().isAfter(startTime)) {
      await postPath.update({'status': '진행중'});
    }
  }

  // 경매 상태에 따라 경매 상태 또는 남은 시간을 표시
  Widget _buildStatusText(String status, Timestamp createDate, Timestamp startTime, Duration remainingTimeSeconds) {
    Duration waitingTime = startTime.toDate().difference(createDate.toDate());

    if (status == '낙찰') {
      return Text(
        '낙찰되었습니다!',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
      );
    } else if (status == '경매 실패') {
      return Text(
        '입찰자가 나오지 않은 경매입니다.',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      );
    } else if (status == '대기중'){
      return Text(
        // 경매 시작까지 남은 시간
        '대기 시간 ${waitingTime.inHours}:${(waitingTime.inMinutes % 60).toString().padLeft(2, '0')}:${(waitingTime.inSeconds % 60).toString().padLeft(2, '0')}',
        style: TextStyle(fontSize: 16, color: Colors.redAccent),
      );
    } else {
      return Text(
        // 경매 종료까지 남은 시간
        '남은 시간 ${remainingTimeSeconds.inHours}:${(remainingTimeSeconds.inMinutes % 60).toString().padLeft(2, '0')}:${(remainingTimeSeconds.inSeconds % 60).toString().padLeft(2, '0')}',
        style: TextStyle(fontSize: 16, color: Colors.redAccent),
      );
    }
  }

  // firestore에서 시간 정보를 가져오는 함수
  Future<Map<String, dynamic>> getAuctionTimes() async {
    final document = await _firestore.collection('AuctionCommunity').doc(widget.documentId).get();
    final data = document.data();

    final createDate = (data!['createDate'] as Timestamp).toDate();
    final waitingTime = (data['waitingTime'] as Timestamp).toDate();
    final startTime = (data['startTime'] as Timestamp).toDate();
    final endTime = (data['endTime'] as Timestamp).toDate();
    final remainingTime = data['remainingTime'] as int;

    return {
      'createDate': createDate,
      'waitingTime': waitingTime,
      'startTime': startTime,
      'endTime': endTime,
      'remainingTime': remainingTime,
    };
  }

  // 경매 상품 사진을 표시하는 함수
  Widget _buildAuctionImage(String auctionImageURL) {
    double _imageSize = 200.0;
    return Center(
      child: Container(
        color: Colors.black,
        width: double.infinity,
        height: _imageSize,
        child: Image.network(auctionImageURL,
            width: _imageSize, height: _imageSize, fit: BoxFit.contain),
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
          child: Image.network(
            uploaderImageURL,
            width: _imageSize,
            height: _imageSize,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      // uploaderImageURL이 공백 또는 null일 경우 기본 이미지 표시
      return SizedBox(
        width: _imageSize,
        height: _imageSize,
        child: ClipOval(
          child: Image.asset(
            'assets/images/defaultImage.png',
            width: _imageSize,
            height: _imageSize,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
  }

  // 게시물 삭제 함수
  Future<void> deletePost() async {
    Navigator.pop(context);
    try {
      // Firestore에서 경매 삭제하기 전에 해당 경매의 DocumentSnapshot을 가져오기
      final postSnapshot = await _firestore
          .collection('AuctionCommunity')
          .doc(widget.documentId)
          .get();

      if (postSnapshot.exists) {
        // DocumentSnapshot이 존재하는 경우에만 게시물을 삭제
        await _firestore
            .collection('AuctionCommunity')
            .doc(widget.documentId)
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
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deletePost();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '경매가 삭제되었습니다.',
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

  // uploaderUID를 가져오는 함수
  void getUploaderUID() async {
    final document = await _firestore
        .collection('AuctionCommunity')
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
  bool isCheckUploader(String userUID) {
    return userUID == uploaderUID;
  }

  // Firestore에서 사용자의 좋아요 상태를 가져오는 함수
  void getLikeStatus() async {
    String userUID = _authentication.currentUser!.uid;
    final likeDocument = await _firestore
        .collection('AuctionCommunity')
        .doc(widget.documentId)
        .collection('Like')
        .doc(userUID)
        .get();
    if (likeDocument.exists) {
      setState(() {
        isLiked = likeDocument.data()!['liked'] ?? false;
      });
    } else {
      setState(() {
        isLiked = false;
      });
    }
  }

  // Firestore에 좋아요 수를 업데이트하는 함수
  Future<void> updateLikeCount(bool isLiked) async {
    final postRef = _firestore.collection('AuctionCommunity').doc(widget.documentId);
    if (isLiked) {
      await postRef.update({
        'like': FieldValue.increment(1), // 좋아요 수를 1 증가시킴
      });
    } else {
      await postRef.update({
        'like': FieldValue.increment(-1), // 좋아요 수를 1 감소시킴
      });
    }
  }

  // 사용자의 좋아요 여부를 저장하는 함수
  void saveLikeStatus(bool isLiked) {
    // 사용자의 UID 가져오기
    String userUID = _authentication.currentUser!.uid;

    // 사용자별 좋아요 정보를 저장
    _firestore.collection('AuctionCommunity/${widget.documentId}/Like').doc(userUID).set({
      'liked': isLiked
    });

    // 좋아요를 누르면 사용자의 "좋아요" 목록에 게시물 ID를 추가
    if (isLiked) {
      addPostToUserLikes(userUID, widget.documentId);
    } else {
      // 좋아요를 취소하면 사용자의 "좋아요" 목록에서 게시물 ID를 제거
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
    // User 컬렉션에서 사용자의 UID로 업로더 문서 가져오기
    final userDocument = _firestore.collection('User').doc(userUID);

    // userLikes 컬렉션 참조 가져오기
    final userLikesCollection = userDocument.collection('userLikes');

    // 사용자의 "좋아요" 목록에서 게시물 ID를 제거
    await userLikesCollection.doc(postID).delete();
  }

  //===================================================

  // 게시물 수정 확인 AlertDialog 표시
  void showDialogEditPost(BuildContext context) async {
    // 경매 상태가 '대기중' 일때
    if (status == '대기중') {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('수정하기'),
            content: Text('경매 내용을 수정하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // 수정 버튼을 눌렀을 때 게시물 수정 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditAuctionScreen(documentId: widget.documentId),
                    ),
                  );
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('경매가 시작된 후에는 수정할 수 없습니다.',
              style: TextStyle(fontSize: 16, color: Colors.white)),
          dismissDirection: DismissDirection.up,
          duration: Duration(milliseconds: 1500),
          backgroundColor: Colors.black,
        ),
      );
    }
  }

  // 남은 시간을 업데이트하는 함수
  void _updateRemainingTime() async {
    Map<String, dynamic> times = await getAuctionTimes();
    DateTime endTime = times['endTime'];
    int waitingTime = times['waitingTime'];

    if (DateTime.now().isBefore(endTime)) {
      _firestore.collection('AuctionCommunity').doc(widget.documentId).update({'remainingTime': remainingTime.inSeconds});

      if (waitingTime > 0 && waitingTimer == null) {
        waitingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
          if (waitingTime > 0) {
            setState(() {
              waitingTime--;
            });
          } else {
            waitingTimer?.cancel();
            _startRemainingTimer();
          }
        });
      }
    } else {
      _timer?.cancel();
      updateAuctionEndStatus();
    }
  }

  // 타이머 시작 - 1초마다 남은 시간 업데이트
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateRemainingTime();
    });
  }

  // 남은 시간 타이머
  void _startRemainingTimer() {
    remainingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime.inSeconds > 0) {
        setState(() {
          remainingTime = remainingTime - Duration(seconds: 1);
        });
      } else {
        remainingTimer?.cancel();
        updateAuctionEndStatus();
      }
    });
  }
}
