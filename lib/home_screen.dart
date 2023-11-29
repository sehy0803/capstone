import 'package:capstone/community_auction_detail_screen.dart';
import 'package:capstone/search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firestore = FirebaseFirestore.instance;

  PageController _pageController = PageController(initialPage: 0);
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Image.asset('assets/images/logo.png', width: 150),
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchScreen()),
                );
              },
              icon: Icon(Icons.search),
              iconSize: 30,
              color: Colors.black,
            ),
          ]),
      body: SingleChildScrollView(
          child: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('AuctionCommunity').orderBy('likes', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('데이터를 불러올 수 없습니다.'));
              }

              var auctions = snapshot.data!.docs;

              if (auctions == null || auctions.isEmpty) {
                return Image.asset('assets/images/logo.png', height: 180);
              }

              // 최대 3개의 항목만 표시
              int itemCount = auctions.length > 3 ? 3 : auctions.length;

              return Container(
                height: 180,
                child: PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.horizontal,
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    String documentId = auctions[index].id;

                    // 경매 정보
                    String title = auctions[index]['title'] as String;
                    String photoURL = auctions[index]['photoURL'] as String;
                    int winningBid = auctions[index]['winningBid'] as int;

                    return GestureDetector(
                      onTap: () {
                        increaseViews(documentId, 'AuctionCommunity');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return CommunityAuctionDetailScreen(documentId: documentId);
                            },
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          Container(
                            color: Colors.black,
                            width: MediaQuery.of(context).size.width,
                            height: 180,
                            child: Image.network(photoURL, fit: BoxFit.contain),
                          ),
                          Positioned(
                            bottom: 10.0,
                            right: 10.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(' ${currentPage + 1}/$itemCount ',
                                  style: TextStyle(color: Colors.white, fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
          SizedBox(height: 10),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite, size: 25, color: Colors.amber),
                SizedBox(width: 10),
                Text('실시간 인기 경매', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(width: 10),
                Icon(Icons.favorite, size: 25, color: Colors.amber),
              ],
            ),
          ),
          SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('최근 경매 결과', style: TextStyle(fontSize: 20)),
                  ],
                ),

                // 경매 상태(status)가 '낙찰' 또는 '경매 실패' 인 경매만 가져오는 스트림
                StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('AuctionCommunity')
                        .where('status', whereIn: ['낙찰', '경매 실패'])
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('데이터를 불러올 수 없습니다.'));
                      }
                      var auctions = snapshot.data!.docs;
                      if (auctions == null || auctions.isEmpty) {
                        return Center(child: Text('아직 종료된 경매가 없습니다.',
                            style: TextStyle(fontSize: 16, color: Colors.grey)));
                      }

                      // 최대 3개의 항목만 표시
                      int itemCount = auctions.length > 3 ? 3 : auctions.length;

                      return ListView.builder(
                        physics: NeverScrollableScrollPhysics(), // 스크롤 방지
                        shrinkWrap: true,
                        itemCount: itemCount,
                        itemBuilder: (context, index) {
                          String documentId = getDocumentId(
                              auctions[index]); // 이건 전달해야할 정보

                          // 경매 정보
                          String title = auctions[index]['title'] as String;
                          String photoURL = auctions[index]['photoURL'] as String;
                          int winningBid = auctions[index]['winningBid'] as int;
                          String status = auctions[index]['status'] as String;

                          // 시간 정보
                          Timestamp endTime = auctions[index]['endTime'] as Timestamp;
                          int remainingTime = auctions[index]['remainingTime'] as int;

                          // 경매 커뮤니티 게시물 표시
                          return GestureDetector(
                            onTap: () {
                              increaseViews(
                                  documentId, 'AuctionCommunity'); // 조회수 증가
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) {
                                        return CommunityAuctionDetailScreen(
                                            documentId: documentId);
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
                                          mainAxisAlignment: MainAxisAlignment
                                              .spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            Row(
                                              children: [
                                                // 경매 상태
                                                Container(
                                                    decoration: BoxDecoration(
                                                      color: _getStatusColor(
                                                          status),
                                                      borderRadius: BorderRadius
                                                          .circular(10.0),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey,
                                                          // 그림자 색상
                                                          offset: Offset(0, 2),
                                                          // 그림자의 위치 (가로, 세로)
                                                          blurRadius: 4.0, // 그림자의 흐림 정도
                                                        ),
                                                      ],
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .all(6.0),
                                                      child: Text(status,
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight
                                                                  .bold,
                                                              color: Colors.white)
                                                      ),
                                                    )
                                                ),
                                                SizedBox(width: 10),
                                                Text(title, style: TextStyle(
                                                    fontSize: 16)),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Text((status == '낙찰')
                                                    ? '낙찰가'
                                                    : (status == '경매 실패')
                                                    ? '경매 실패'
                                                    : '최소 입찰가',
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                                Text('$winningBid원',
                                                    style: TextStyle(fontSize: 16,
                                                        color: Colors.blue)),
                                              ],
                                            ),
                                            // 남은 시간 표시
                                            buildRemainingTime(
                                                status, endTime, remainingTime),

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
                        },
                      );
                    }),



              ],
            ),
          ),
        ],
      )),
    );
  }

  // ===========================================================================

  // 게시물의 documentID를 가져오는 함수
    String getDocumentId(QueryDocumentSnapshot document) {
                    return document.id;
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

