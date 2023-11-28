import 'package:capstone/community_auction_detail_screen.dart';
import 'package:capstone/community_user_detail_screen.dart';
import 'package:capstone/custom_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final _authentication = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String collectionName = '';

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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title:
          Text('관심목록', style: TextStyle(color: Colors.black, fontSize: 20)),
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
          ),
        ),
        body: TabBarView(
          children: [
          _buildAuctionFavoriteList(), // 경매 게시글 탭
          _buildUserFavoriteList(), // 유저 게시글 탭
          ],
        ),
      )
    );
  }
  //============================================================================

  Widget _buildAuctionFavoriteList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getAuctionLikesStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {return Center(child: CircularProgressIndicator());}
        if (snapshot.hasError) {return Center(child: Text('데이터를 불러올 수 없습니다.'));}
        var auctions = snapshot.data!.docs;
        if (auctions == null || auctions.isEmpty) {
          return Center(child: Text('좋아요 한 게시물이 없습니다.',
              style: TextStyle(fontSize: 16, color: Colors.grey)));
        }
        return ListView.builder(
            itemCount: auctions.length,
            itemBuilder: (context, index)
            {
              String auctionId = auctions[index].id;

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
                        increaseViews(auctionId, 'AuctionCommunity'); // 조회수 증가
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) {
                                  return CommunityAuctionDetailScreen(documentId: auctionId);
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
    );
  }

  Widget _buildUserFavoriteList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getUserLikesStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {return Center(child: CircularProgressIndicator());}
        if (snapshot.hasError) {return Center(child: Text('데이터를 불러올 수 없습니다.'));}
        var posts = snapshot.data!.docs;
        if (posts == null || posts.isEmpty) {
          return Center(child: Text('좋아요 한 게시물이 없습니다.',
              style: TextStyle(fontSize: 16, color: Colors.grey)));
        }
        return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {

              String postId = posts[index].id;

              return StreamBuilder<DocumentSnapshot>(
                  stream: _firestore.collection('UserCommunity').doc(postId).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {return Center(child: CircularProgressIndicator());}

                    var postData = snapshot.data!.data() as Map<String, dynamic>;

                    String uploaderUID = postData['uploaderUID'] as String;
                    String title = postData['title'] as String;
                    int views = postData['views'] as int;
                    int likes = postData['likes'] as int;
                    int comments = postData['comments'] as int;
                    Timestamp createDate = postData['createDate'] as Timestamp;
                    String formattedCreatedDate = DateFormat('yyyy.MM.dd HH:mm').format(createDate.toDate());

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
                                      Text('좋아요 $likes', style: TextStyle(fontSize: 12)),
                                      SizedBox(width: 5),
                                      Text('댓글 $comments', style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                  onTap: () {
                                    increaseViews(postId, 'UserCommunity'); // 조회수 증가
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return CommunityUserDetailScreen(documentId: postId,);
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
              );
            }
        );
      },
    );
  }

  // 사용자가 좋아요한 경매게시글을 가져오는 함수
  Stream<QuerySnapshot> _getAuctionLikesStream() {
    return _firestore.collection('User').doc(userID).collection('auctionLikes').snapshots();
  }

  // 사용자가 좋아요한 유저게시글을 가져오는 함수
  Stream<QuerySnapshot> _getUserLikesStream() {
    return _firestore.collection('User').doc(userID).collection('userLikes').snapshots();
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