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

  String userID = '';
  String uploaderUID = '';
  String status = '';
  int bid = 0;
  bool isLiked = false;

  // 타이머
  Timer? _timer;
  Duration remainingTimeInSeconds = Duration.zero;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getUploaderUID();
    getLikeStatus();
    getStatus();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
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
              int views = auctionData['views'] as int;
              int likes = auctionData['likes'] as int;
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
                                                                  Text('$likes', style: TextStyle(fontSize: 12))])])])),

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
                                                        // 남은 시간 표시
                                                        _buildStatusText(status, remainingTimeSeconds),
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
                                              visible: status == '진행중' && !isCheckUploader(uploaderUID),
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
  bool isCheckUploader(String uploaderUID) {
    return userID == uploaderUID;
  }

  //============================================================================

  // 타이머
  // firestore에서 시간 정보를 가져오는 함수
  Future<Map<String, dynamic>> getAuctionTimes() async {
    final document = await _firestore.collection('AuctionCommunity').doc(widget.documentId).get();
    final data = document.data();

    final createDate = (data!['createDate'] as Timestamp).toDate();
    final startTime = (data['startTime'] as Timestamp).toDate();
    final endTime = (data['endTime'] as Timestamp).toDate();
    final remainingTime = data['remainingTime'] as int;

    return {
      'createDate': createDate,
      'startTime': startTime,
      'endTime': endTime,
      'remainingTime': remainingTime,
    };
  }

  // 타이머 시작 - 1초마다 남은 시간 업데이트
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateRemainingTime();
    });
  }

  // 남은 시간을 업데이트하는 함수
  void _updateRemainingTime() async {
    Map<String, dynamic> times = await getAuctionTimes();
    DateTime startTime = times['startTime'];
    DateTime endTime = times['endTime'];

    // 시간에 따라 경매 상태를 업데이트 하는 함수(대기중 -> 진행중)
    updateAuctionStatus();

    // 현재 시간이 경매 시작 시간보다 전일 경우 : 경매 상태가 대기중일 때
    if (DateTime.now().isBefore(startTime)) {
      int remainingTime = startTime.difference(DateTime.now()).inSeconds;
      setState(() {
        remainingTimeInSeconds = Duration(seconds: remainingTime);
      });
      FirebaseFirestore.instance.collection('AuctionCommunity').doc(widget.documentId)
          .update({'remainingTime': remainingTime});
    }
    // 현재 시간이 경매 시작 시간 이후, 종료 시간 이전일 경우 : 경매 상태가 진행중일 때
    else if (DateTime.now().isBefore(endTime)) {
      int remainingTime = endTime.difference(DateTime.now()).inSeconds;
      setState(() {
        remainingTimeInSeconds = Duration(seconds: remainingTime);
      });
      FirebaseFirestore.instance.collection('AuctionCommunity').doc(widget.documentId)
          .update({'remainingTime': remainingTime});
    } else {
      // 경매 종료 시간이 지났을 경우 타이머 종료
      _timer?.cancel();
      updateAuctionEndStatus();
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

      var existingWinningAuction = await _firestore
          .collection('User')
          .doc(winningBidderUID)
          .collection('winningAuctions')
          .where('auctionId', isEqualTo: widget.documentId)
          .get();

      // 낙찰자의 User 컬렉션 > winningAuctions 서브 컬렉션에 낙찰 정보 저장하기
      if(existingWinningAuction.docs.isEmpty){
        await _firestore.collection('User').doc(winningBidderUID)
            .collection('winningAuctions')
            .add({
          'auctionId': widget.documentId,
          'timestamp': Timestamp.now()});
      }

    } else {
      // 최고 입찰자가 없는 경우
      await _firestore.doc(postPath).update({
        'status': '경매 실패',
      });
    }
  }

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
  Widget _buildStatusText(String status, Duration remainingTimeSeconds) {
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
        '대기 시간 ${remainingTimeInSeconds.inHours}:${(remainingTimeInSeconds.inMinutes % 60).toString().padLeft(2, '0')}:${(remainingTimeInSeconds.inSeconds % 60).toString().padLeft(2, '0')}',
        style: TextStyle(fontSize: 16, color: Colors.redAccent),
      );
    } else {
      return Text(
        // 경매 종료까지 남은 시간
        '남은 시간 ${remainingTimeInSeconds.inHours}:${(remainingTimeInSeconds.inMinutes % 60).toString().padLeft(2, '0')}:${(remainingTimeInSeconds.inSeconds % 60).toString().padLeft(2, '0')}',
        style: TextStyle(fontSize: 16, color: Colors.redAccent),
      );
    }
  }

  //============================================================================

  // 입찰을 수행할 함수
  void _saveBidData() async {
    // 경매에 참여한 정보 가져오기
    var participatedAuctionDoc = await _firestore.collection('User').doc(userID)
        .collection('participatedInAuctions')
        .doc(widget.documentId)
        .get();

    // 이미 참여한 경매인 경우
    if (participatedAuctionDoc.exists) {
      // 업데이트 수행
      await _firestore.collection('User').doc(userID)
          .collection('participatedInAuctions')
          .doc(widget.documentId)
          .update({
        'timestamp': Timestamp.now(),
      });
    } else {
      // 참여하지 않은 경우 정보 추가
      await _firestore.collection('User').doc(userID)
          .collection('participatedInAuctions')
          .add({
        'auctionId': widget.documentId,
        'timestamp': Timestamp.now(),
      });
    }

    // 경매 정보 업데이트
    await _firestore.doc('AuctionCommunity/${widget.documentId}').update({
      'winningBid': bid,
      'winningBidderUID': userID,
    });

    // 입력 필드 지우기
    bidController.clear();
  }

  // status를 가져오는 함수
  void getStatus() async {
    final document = await _firestore
        .collection('AuctionCommunity')
        .doc(widget.documentId)
        .get();
    final data = document.data();

    if (data != null && data['status'] != null) {
      setState(() {
        status = data['status'] as String;
      });
    }
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

        // 삭제된 게시글과 관련된 데이터 삭제
        await _deleteRelatedData(widget.documentId);

        Navigator.pop(context);
      } else {
        // DocumentSnapshot이 존재하지 않는 경우에 대한 처리
        print('경매가 이미 삭제되었습니다.');
      }
    } catch (e) {
      print('경매 삭제 중 오류 발생: $e');
    }
  }

  // 게시글과 관련된 데이터 삭제 함수
  Future<void> _deleteRelatedData(String postId) async {
    // 컬렉션에서 해당 게시글의 ID를 가진 문서를 찾아 삭제
    var userSnapshots = await _firestore.collection('User').get();
    for (var userSnapshot in userSnapshots.docs) {
      await _firestore
          .collection('User')
          .doc(userSnapshot.id)
          .collection('participatedInAuctions')
          .doc(postId)
          .delete();

      await _firestore
          .collection('User')
          .doc(userSnapshot.id)
          .collection('winningAuction')
          .doc(postId)
          .delete();

      await _firestore
          .collection('User')
          .doc(userSnapshot.id)
          .collection('auctionLikes')
          .doc(postId)
          .delete();
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

  // Firestore에서 사용자의 좋아요 상태를 가져오는 함수
  void getLikeStatus() async {
    final likeDocument = await _firestore
        .collection('AuctionCommunity')
        .doc(widget.documentId)
        .collection('Like')
        .doc(userID)
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
        'likes': FieldValue.increment(1), // 좋아요 수를 1 증가시킴
      });
    } else {
      await postRef.update({
        'likes': FieldValue.increment(-1), // 좋아요 수를 1 감소시킴
      });
    }
  }

  // 사용자의 좋아요 여부를 저장하는 함수
  void saveLikeStatus(bool isLiked) {
    // 사용자별 좋아요 정보를 저장
    _firestore.collection('AuctionCommunity/${widget.documentId}/Like').doc(userID).set({
      'liked': isLiked
    });


    if (isLiked) {
      addPostToAuctionLikes(widget.documentId);
    } else {
      // 좋아요를 취소하면 사용자의 "좋아요" 목록에서 게시물 ID를 제거
      removePostFromAuctionLikes(widget.documentId);
    }
  }

  // 사용자의 "좋아요" 목록에 게시물 ID를 추가하는 함수 (AuctionCommunity에 추가)
  Future<void> addPostToAuctionLikes(String postID) async {
    // User 컬렉션에서 사용자의 UID로 업로더 문서 가져오기
    final userDocument = _firestore.collection('User').doc(userID);

    // auctionLikes 컬렉션 참조 가져오기
    final auctionLikesCollection = userDocument.collection('auctionLikes');

    // 사용자가 게시물에 좋아요를 누른 경우, 해당 게시물의 ID로 새로운 문서 추가
    await auctionLikesCollection.doc(postID).set({
      'liked': true,
      'postType': 'AuctionCommunity' // 경매 게시글임을 나타내는 특정 필드 추가
    });
  }

  // 사용자의 "좋아요" 목록에 게시물 ID를 삭제하는 함수
  Future<void> removePostFromAuctionLikes(String postID) async {
    // User 컬렉션에서 사용자의 UID로 업로더 문서 가져오기
    final userDocument = _firestore.collection('User').doc(userID);

    // auctionLikes 컬렉션 참조 가져오기
    final auctionLikesCollection = userDocument.collection('auctionLikes');

    // 사용자의 "좋아요" 목록에서 게시물 ID를 제거
    await auctionLikesCollection.doc(postID).delete();
  }

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

}
