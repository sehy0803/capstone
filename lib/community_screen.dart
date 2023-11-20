import 'package:capstone/community_auction_register_screen.dart';
import 'package:capstone/community_auction_detail_screen.dart';
import 'package:capstone/community_user_detail_screen.dart';
import 'package:capstone/community_user_register_screen.dart';
import 'package:capstone/custom_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _firestore = FirebaseFirestore.instance;

  int _currentTabIndex = 0; // 현재 선택된 탭을 저장하는 변수
  String collectionName = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title:
          Text('커뮤니티', style: TextStyle(color: Colors.black, fontSize: 20)),
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 0,
          bottom: TabBar(
            tabs: [
              Tab(text: '경매 게시판'),
              Tab(text: '유저 게시판'),
            ],
            labelColor: Colors.black,
            labelStyle: TextStyle(fontSize: 18),
            indicatorColor: DarkColors.basic,
            onTap: (index) {
              setState(() {
                _currentTabIndex = index;
              });
            },
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection(getCollectionName())
              .orderBy('createDate', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {return Center(child: CircularProgressIndicator());}
            if (snapshot.hasError) {return Center(child: Text('데이터를 불러올 수 없습니다.'));}
            final documents = snapshot.data?.docs;
            if (documents == null || documents.isEmpty) {
              // 경매 게시글이 없을 때
              if (getCollectionName() == 'AuctionCommunity') {
                return Center(child: Text('아직 등록된 경매가 없습니다.\n경매를 등록해보세요!',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)));
              }
              // 유저 게시글이 없을 때
              else {
                return Center(child: Text('게시글이 없습니다.', style: TextStyle(fontSize: 16, color: Colors.grey)));
              }
            }

            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                // 유저 정보
                String uploaderUID = documents![index]['uploaderUID'] as String;

                // 경매 정보
                String documentId = getDocumentId(documents[index]); // 이건 전달해야할 정보
                String title = documents[index]['title'] as String;

                if (getCollectionName() == 'AuctionCommunity') {
                  String photoURL = documents[index]['photoURL'] as String;
                  int winningBid = documents[index]['winningBid'] as int;
                  String status = documents[index]['status'] as String;

                  // 시간 정보
                  Timestamp endTime = documents[index]['endTime'] as Timestamp;
                  int remainingTime = documents[index]['remainingTime'] as int;

                  // 경매 커뮤니티 게시물 표시

                  return GestureDetector(
                    onTap: () {
                      increaseViews(documentId, getCollectionName()); // 조회수 증가
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) {
                                return CommunityAuctionDetailScreen(documentId: documentId);}));
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
                                              borderRadius: BorderRadius.circular(10.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey, // 그림자 색상
                                                  offset: Offset(0, 2), // 그림자의 위치 (가로, 세로)
                                                  blurRadius: 4.0, // 그림자의 흐림 정도
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(6.0),
                                              child: Text(status,
                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
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
                                        Text('$winningBid원', style: TextStyle(fontSize: 16, color: Colors.blue)),
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
                } else {
                  final views = documents[index]['views'] as int;
                  final like = documents[index]['like'] as int;
                  final comments = documents[index]['comments'] as int;
                  final createDate = documents[index]['createDate'] as Timestamp;
                  final formattedCreatedDate = DateFormat('yyyy.MM.dd HH:mm').format(createDate.toDate());
                  // 유저 커뮤니티 게시물 표시
                  return StreamBuilder<DocumentSnapshot>(
                      stream: _firestore.collection('User').doc(uploaderUID).snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {return Center(child: CircularProgressIndicator());}

                        var uploaderData = snapshot.data!.data() as Map<String, dynamic>;

                        // 업로더 정보
                        String uploaderNickname = uploaderData['nickname'] ?? '';

                        return Column(
                          children: [
                            Card(
                              elevation: 0,
                              child: ListTile(
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title, style: TextStyle(fontSize: 16)),
                                    SizedBox(height: 10),
                                  ],
                                ),
                                subtitle: Row(
                                  children: [
                                    Text(uploaderNickname, style: TextStyle(fontSize: 12)),
                                    SizedBox(width: 5),
                                    Text(formattedCreatedDate, style: TextStyle(fontSize: 12, height: 1.3)),
                                    SizedBox(width: 5),
                                    Text('조회 $views', style: TextStyle(fontSize: 12)),
                                    SizedBox(width: 5),
                                    Text('좋아요 $like', style: TextStyle(fontSize: 12)),
                                    SizedBox(width: 5),
                                    Text('댓글 $comments', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                                onTap: () {
                                  increaseViews(documentId, getCollectionName()); // 조회수 증가
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return CommunityUserDetailScreen(
                                          documentId: documentId,
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                            CommentLine()
                          ],
                        );
                      }
                  );
                }
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_currentTabIndex == 0) {
              // 경매 게시판 탭이 선택된 상태면 경매 게시글 등록 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AuctionRegisterScreen(boardType: '경매 게시판')),
              );
            } else {
              // 유저 게시판 탭이 선택된 상태면 유저 게시글 등록 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CommunityRegisterScreen(boardType: '유저 게시판')),
              );
            }
          },
          backgroundColor: DarkColors.basic,
          child: Icon(Icons.edit),
        ),
      ),
    );
  }
  //============================================================================

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

  // ================================================

  // 선택된 게시판 이름
  String getCollectionName() {
    return collectionName =
    (_currentTabIndex == 0) ? 'AuctionCommunity' : 'UserCommunity';
  }

  // 게시물의 documentID를 가져오는 함수
  String getDocumentId(QueryDocumentSnapshot document) {
    return document.id;
  }

  // Firestore에서 조회수를 증가시키는 함수
  Future<void> increaseViews(String documentId, String collectionName) async {
    final document = await _firestore.collection(collectionName).doc(documentId).get();
    final currentViews = document['views'] as int;
    final updatedViews = currentViews + 1;
    await _firestore.collection(collectionName).doc(documentId).update({'views': updatedViews});
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