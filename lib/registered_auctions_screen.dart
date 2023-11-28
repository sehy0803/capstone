import 'package:capstone/community_auction_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RegisteredAuctionsScreen extends StatefulWidget {
  final String userID;

  RegisteredAuctionsScreen({
    required this.userID,
  });

  @override
  _RegisteredAuctionsScreenState createState() => _RegisteredAuctionsScreenState();
}

class _RegisteredAuctionsScreenState extends State<RegisteredAuctionsScreen> {
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text('등록한 경매', style: TextStyle(color: Colors.black, fontSize: 20)),
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.close),
          iconSize: 30,
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        child: // 등록한 경매
        StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('User/${widget.userID}/registeredAuctions')
              .orderBy('timestamp', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {return Center(child: CircularProgressIndicator());}
            if (snapshot.hasError) {return Center(child: Text('데이터를 불러올 수 없습니다.'));}
            var auctions = snapshot.data!.docs;
            if (auctions == null || auctions.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(child: Text('아직 경매를 등록하지 않았습니다.',
                    style: TextStyle(fontSize: 16, color: Colors.grey))),
              );
            }
            return ListView.builder(
                shrinkWrap: true,
                itemCount: auctions.length,
                itemBuilder: (context, index)
                {
                  String auctionId = auctions![index]['auctionId'] as String;

                  return StreamBuilder<DocumentSnapshot>(
                      stream: _firestore.collection('AuctionCommunity').doc(auctionId).snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {return Center(child: CircularProgressIndicator());}

                        var auctionData = snapshot.data!.data() as Map<String, dynamic>;

                        // 경매 정보
                        String photoURL = auctionData['photoURL'] as String;
                        String title = auctionData['title'] as String;
                        int winningBid = auctionData['winningBid'] as int;
                        String status = auctionData['status'] as String;

                        // 시간 정보
                        Timestamp endTime = auctionData['endTime'] as Timestamp;
                        int remainingTime = auctionData['remainingTime'] as int;

                        return GestureDetector(
                          onTap: () {
                            increaseViews(
                                auctionId, 'AuctionCommunity'); // 조회수 증가
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) {
                                      return CommunityAuctionDetailScreen(
                                          documentId: auctionId);
                                    }));
                          },
                          child: Column(
                            children: [
                              Card(
                                elevation: 0,
                                child: Row(
                                  children: [
                                    _buildAuctionImage(photoURL),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              // 경매 상태
                                              Container(
                                                  decoration: BoxDecoration(
                                                    color: _getStatusColor(status),
                                                    borderRadius: BorderRadius
                                                        .circular(10.0),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey,
                                                        offset: Offset(0, 2),
                                                        blurRadius: 4.0,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .all(6.0),
                                                    child: Text(status,
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white)
                                                    ),
                                                  )
                                              ),
                                              SizedBox(width: 10),
                                              Text(title, style: TextStyle(fontSize: 16)),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text((status == '낙찰')
                                                  ? '낙찰가'
                                                  : (status == '경매 실패')
                                                  ? '경매 실패'
                                                  : '최소 입찰가',
                                                  style: TextStyle(fontSize: 16)),
                                              Text('$winningBid원',
                                                  style: TextStyle(fontSize: 16, color: Colors.blue)),
                                            ],
                                          ),
                                          // 남은 시간 표시
                                          buildRemainingTime(status, endTime, remainingTime),

                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(height: 1, color: Colors.grey[200])
                            ],
                          ),
                        );
                      }
                  );
                }
            );
          },
        ),
      )
    );
  }

  // 사진 표시 위젯
  Widget _buildAuctionImage(String auctionImageURL) {
    double _imageSize = 100.0;
    return Center(
      child: Container(
        color: Colors.black,
        width: _imageSize,
        height: _imageSize,
        child: Image.network(auctionImageURL, width: _imageSize, height: _imageSize, fit: BoxFit.cover),
      ),
    );
  }

  // 남은 시간을 표시하는 조건
  String getFormattedRemainingTime(status, endTime, remainingTime) {
    Duration remainingTimeInSeconds = Duration(seconds: remainingTime);
    if (status == '대기중') {
      return '${remainingTimeInSeconds.inMinutes}분 후 시작';
    } else if (remainingTime < 60) {
      // 10분 미만
      return '잠시 후 종료';
    } else if (remainingTime < 3600) {
      // 10분 이상, 1시간 미만
      return '${remainingTimeInSeconds.inMinutes}분 후 종료';
    } else {
      // 1시간 이상
      return '${remainingTimeInSeconds.inHours}시간 후 종료';
    }
  }

  // 남은 시간 표시 위젯
  Widget buildRemainingTime(String status, Timestamp endTime, int remainingTime) {
    if (status == '낙찰' || status == '경매 실패') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('경매 종료', style: TextStyle(fontSize: 16, color: Colors.grey)),
          Text('${DateFormat('MM월 dd일 HH시 mm분').format(endTime.toDate())}',
              style: TextStyle(fontSize: 16, color: Colors.grey))
        ],
      );
    } else {
      return Center(
        child: Text(
          getFormattedRemainingTime(status, endTime, remainingTime),
          style: TextStyle(fontSize: 16, color: Colors.redAccent),
        ),
      );
    }
  }

  // Firestore에서 조회수를 증가시키는 함수
  Future<void> increaseViews(String auctionId, String collectionName) async {
    final document = await _firestore.collection(collectionName).doc(auctionId).get();
    final currentViews = document['views'] as int;
    final updatedViews = currentViews + 1;
    await _firestore.collection(collectionName).doc(auctionId).update({'views': updatedViews});
  }

  // 상태에 따라 다른 색상 적용
  Color _getStatusColor(String status) {
    if (status == '진행중') {
      return Colors.green; // 녹색
    } else if (status == '낙찰') {
      return Colors.blue; // 파란색
    } else if (status == '경매 실패') {
      return Colors.grey; // 회색
    } else {
      return Colors.black; // 기본값 (다른 상태일 때)
    }
  }

}
