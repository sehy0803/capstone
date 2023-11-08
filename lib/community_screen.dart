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

  int startBid = 0;
  int winningBid = 0;
  String winningBidder = '';
  Timestamp endTime = Timestamp(0, 0);

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
          stream: _getCommunityStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('데이터를 불러올 수 없습니다.'));
            }

            final documents = snapshot.data?.docs;

            return ListView.builder(
              itemCount: documents?.length ?? 0,
              itemBuilder: (context, index) {
                final title = documents![index]['title'] as String;
                final content = documents[index]['content'] as String;
                final uploaderEmail =
                documents[index]['uploaderEmail'] as String;
                final uploaderImageURL =
                    documents[index]['uploaderImageURL'] as String;
                final uploaderNickname =
                    documents[index]['uploaderNickname'] as String;
                final documentId = getDocumentId(documents![index]);
                final views = documents[index]['views'] as int;
                final like = documents[index]['like'] as int;
                final comments = documents[index]['comments'] as int;
                final photoURL = documents[index]['photoURL'] as String;
                final createDate = documents[index]['createDate'] as Timestamp;
                final formattedDate = DateFormat('yyyy.MM.dd HH:mm').format(createDate.toDate());

                if (getCollectionName() == 'AuctionCommunity') {
                  startBid = documents[index]['startBid'] as int;
                  winningBid = documents[index]['winningBid'] as int;
                  winningBidder = documents[index]['winningBidder'] as String;
                  endTime = documents[index]['endTime'] as Timestamp;
                }

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
                            Text(formattedDate, style: TextStyle(fontSize: 12, height: 1.3)),
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
                          try {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  if (getCollectionName() == 'AuctionCommunity') {
                                    return CommunityAuctionDetailScreen(
                                      title: title,
                                      content: content,
                                      uploaderEmail: uploaderEmail,
                                      uploaderImageURL: uploaderImageURL,
                                      uploaderNickname: uploaderNickname,
                                      collectionName: getCollectionName(),
                                      documentId: documentId,
                                      views: views + 1,
                                      like: like,
                                      comments: comments,
                                      photoURL: photoURL,
                                      startBid: startBid,
                                      winningBid: winningBid,
                                      winningBidder: winningBidder,
                                      createDate: createDate,
                                      endTime: endTime,
                                    );
                                  } else {
                                    return CommunityUserDetailScreen(
                                      title: title,
                                      content: content,
                                      uploaderEmail: uploaderEmail,
                                      uploaderImageURL: uploaderImageURL,
                                      uploaderNickname: uploaderNickname,
                                      createDate: createDate,
                                      collectionName: getCollectionName(),
                                      documentId: documentId,
                                      views: views + 1,
                                      like: like,
                                      comments: comments,
                                      photoURL: photoURL,
                                    );
                                  }
                                },
                              ),
                            );
                          } catch (e) {
                            print('$e');
                          }
                        },
                      ),
                    ),
                    CommentLine()
                  ],
                );
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
  Stream<QuerySnapshot> _getCommunityStream() {
    return _firestore
        .collection(getCollectionName())
        .orderBy('createDate', descending: true)
        .snapshots();
  }

  // 선택된 게시판 이름
  String getCollectionName() {
    return collectionName =
    (_currentTabIndex == 0) ? 'AuctionCommunity' : 'UserCommunity';
  }

  // 게시물의 Document ID를 가져오는 함수
  String getDocumentId(QueryDocumentSnapshot document) {
    return document.id;
  }

  // Firestore에서 조회수를 증가시키는 함수
  Future<void> increaseViews(String documentId, String collectionName) async {
    final documentReference =
    _firestore.collection(collectionName).doc(documentId);
    final document = await documentReference.get();

    if (document.exists) {
      final currentViews = document['views'] as int;
      final updatedViews = currentViews + 1;
      await documentReference.update({'views': updatedViews});
    }
  }
}
