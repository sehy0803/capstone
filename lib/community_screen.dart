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
                final uploaderImageURL = documents[index]['uploaderImageURL'] as String;
                final uploadernickname = documents[index]['uploadernickname'] as String;
                final createDate = documents[index]['createDate'] as String;

                return Card(
                  child: ListTile(
                    title: Text(title),
                    subtitle: Text(content),
                    onTap: () {
                      try {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CommunityDetailScreen(
                                title: title, // 제목
                                content: content, // 내용
                                uploaderImageURL: uploaderImageURL, // 게시글을 작성한 유저의 프로필 사진 URL
                                uploadernickname: uploadernickname, // 게시글을 작성한 유저의 닉네임
                                createDate: createDate, // 게시글이 업로드된 날짜
                              ),
                            ));
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
    String collectionName =
        (_currentTabIndex == 0) ? 'AuctionCommunity' : 'UserCommunity';
    return _firestore.collection(collectionName).snapshots();
  }
}
