import 'package:capstone/auction_register_screen.dart';
import 'package:capstone/community_detail_screen.dart';
import 'package:capstone/community_register_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _firestore = FirebaseFirestore.instance;
  int _currentTabIndex = 0; // 현재 선택된 탭을 저장하는 변수

  @override
  void initState() {
    super.initState();
  }

  // 선택된 게시판 이름
  String getCollectionName() {
    return (_currentTabIndex == 0) ? 'AuctionCommunity' : 'UserCommunity';
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black12,
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
            indicatorColor: Colors.black,
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
                final uploaderImageURL =
                    documents[index]['uploaderImageURL'] as String;
                final uploadernickname =
                    documents[index]['uploadernickname'] as String;
                final createDate = documents[index]['createDate'] as String;
                final documentId = getDocumentId(documents![index]);
                final views = documents[index]['views'] as int;
                final favorite = documents[index]['favorite'] as int;
                final comments = documents[index]['comments'] as int;

                return Card(
                  child: ListTile(
                    title: Text(title, style: TextStyle(fontSize: 18)),
                    subtitle: Row(
                      children: [
                        Text(uploadernickname, style: TextStyle(fontSize: 14)),
                        SizedBox(width: 10),
                        Text(createDate, style: TextStyle(fontSize: 14)),
                        Text('조회수: $views, 찜 횟수: $favorite, 댓글 수: $comments'),
                      ],
                    ),
                    onTap: () {
                      increaseViews(documentId, getCollectionName()); // 조회수 증가
                      try {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CommunityDetailScreen(
                                      // 제목
                                      title: title,
                                      // 내용
                                      content: content,
                                      // 게시글을 작성한 유저의 프로필 사진 URL
                                      uploaderImageURL: uploaderImageURL,
                                      // 게시글을 작성한 유저의 닉네임
                                      uploadernickname: uploadernickname,
                                      // 게시글이 업로드된 날짜
                                      createDate: createDate,
                                      // collectionName 전달
                                      collectionName: (_currentTabIndex == 0)
                                          ? 'AuctionCommunity'
                                          : 'UserCommunity',
                                      documentId: documentId,
                                      views: views + 1,
                                      favorite: favorite,
                                      comments: comments,
                                    )));
                      } catch (e) {
                        print('================================== $e');
                      }
                    },
                  ),
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
          backgroundColor: Colors.black,
          child: Icon(Icons.edit),
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getCommunityStream() {
    final collectionName = getCollectionName();
    return _firestore
        .collection(collectionName)
        .orderBy('createDate', descending: true)
        .snapshots();
  }
}
