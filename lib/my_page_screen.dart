import 'package:capstone/community_auction_detail_screen.dart';
import 'package:capstone/custom_widget.dart';
import 'package:capstone/participated_in_auctions_screen.dart';
import 'package:capstone/profile_edit_screen.dart';
import 'package:capstone/profile_setting_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  _MyPageScreenState createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final _authentication = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String userID = '';

  // 현재 로그인한 유저의 UID 저장
  void getCurrentUser() async {
    final user = _authentication.currentUser;
    if (user != null) {
      setState(() {
        userID = user.uid;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            Text('마이페이지', style: TextStyle(color: Colors.black, fontSize: 20)),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          // 프로필 설정 버튼
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileSettingScreen(userID: userID)
                  ),
                );
              },
              icon: Icon(Icons.settings, color: Colors.grey, size: 30))
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('User').doc(userID).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {return Center(child: CircularProgressIndicator());}
        if (snapshot.hasError) {return Center(child: Text('데이터를 불러올 수 없습니다.'));}

        var userData = snapshot.data!.data() as Map<String, dynamic>;

        String imageURL = userData['imageURL'] as String;
        String nickname = userData['nickname'] as String;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // 유저 프로필 사진 표시
                        _buildUserProfileImage(imageURL),
                        SizedBox(width: 10),
                        // 닉네임 표시
                        Text(
                          nickname,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    // 프로필 수정 버튼
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ProfileEditScreen(userID: userID,);
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DarkColors.basic,
                      ),
                      child: Text('프로필 수정', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
                Line(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('내가 참여한 경매', style: TextStyle(fontSize: 20)),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return ParticipatedInAuctionsScreen(userID: userID);
                              },
                            ),
                          );
                        },
                        child: Text('더보기'))
                  ],
                ),
                // 내가 참여한 경매
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('User/$userID/participatedInAuctions')
                      .orderBy('timestamp', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {return Center(child: CircularProgressIndicator());}
                    if (snapshot.hasError) {return Center(child: Text('데이터를 불러올 수 없습니다.'));}
                    var auctions = snapshot.data!.docs;
                    if (auctions == null || auctions.isEmpty) {
                      return Center(child: Text('아직 경매에 참여하지 않았습니다.',
                          style: TextStyle(fontSize: 16, color: Colors.grey)));
                    }
                    // 최대 3개의 항목만 표시
                    int itemCount = auctions.length > 3 ? 3 : auctions.length;
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: itemCount,
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
                Line(),
                // 낙찰된 경매
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('낙찰된 경매', style: TextStyle(fontSize: 20)),
                    TextButton(
                        onPressed: () {
                        },
                        child: Text('더보기'))
                  ],
                ),

              ],
            ),
          ),
        );
      },
    ),
    );
  }
  //============================================================================

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

  // 사용자의 프로필사진을 표시하는 함수
  Widget _buildUserProfileImage(String imageURL) {
    double _imageSize = 80.0;
    if (imageURL != null && imageURL.isNotEmpty) {
      return Container(
        width: _imageSize,
        height: _imageSize,
        child: ClipOval(
          child: Image.network(
            imageURL,
            width: _imageSize,
            height: _imageSize,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      // imageURL이 공백 또는 null일 경우 기본 이미지 표시
      return Container(
        width: _imageSize,
        height: _imageSize,
        child: ClipOval(
          child: Image.asset(
            'assets/images/defaultImage.png', // 기본 이미지 파일 경로
            width: _imageSize,
            height: _imageSize,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
  }

}
