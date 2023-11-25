import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'custom_widget.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _authentication = FirebaseAuth.instance;
  int _currentTabIndex = 0; // 현재 선택된 탭을 저장하는 변수

  String _userID = '';

  @override
  void initState() {
    super.initState();
    _getUserID(); // 사용자 ID 가져오기
  }

  void _getUserID() async {
    final user = _authentication.currentUser;
    if (user != null) {
      setState(() {
        _userID = user.uid;
      });
    }
  }

  Future<void> createAuctionLikesSubcollection(String userUID) async {
    try {
      // 사용자 UID를 기반으로 해당 사용자의 문서를 가져옵니다.
      final userDocument = _firestore.collection('User').doc(userUID);

      // auctionLikes 서브컬렉션을 추가합니다.
      await userDocument.collection('auctionLikes').add({
        'liked': true
      });

      print('auctionLikes 서브컬렉션이 생성되었습니다.');
    } catch (e) {
      print('auctionLikes 서브컬렉션 생성 중 오류 발생: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title:
          Text('관심목록', style: TextStyle(color: Colors.black, fontSize: 20)),
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 0,
          bottom: TabBar(
            tabs: [
              Tab(text: '경매 게시글'),
              Tab(text: '유저 게시글'),
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
        body: TabBarView(
          children: [
            _buildAuctionFavoriteList(), // 경매 게시글 탭
            _buildUserFavoriteList(), // 유저 게시글 탭
          ],
        ),
      ),
    );
  }

  Widget _buildAuctionFavoriteList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getAuctionLikesStream(), // 사용자가 좋아요한 경매게시글 스트림 가져오기
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('데이터를 불러올 수 없습니다.');
        }

        final documents = snapshot.data?.docs;

        if (documents != null && documents.isNotEmpty) {
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final postId = documents[index].id; // 좋아요한 경매 게시글의 ID

              return FutureBuilder<DocumentSnapshot>(
                future: getAuctionPostDetails(postId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return Text('게시물을 불러올 수 없습니다.');
                  }

                  final postDocument = snapshot.data;

                  if (postDocument != null && postDocument.exists) {
                    final postTitle = postDocument['title'];
                    final postContent = postDocument['content'];
                    final postPhoto = postDocument['photoURL'];

                    return ListTile(
                      title: Text('게시글 제목: $postTitle'),
                      subtitle: Text('게시글 내용: $postContent'),
                      leading: postPhoto != null
                          ? SizedBox(
                        width: 100,
                        height: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            postPhoto,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                          : SizedBox(
                        width: 100,
                        height: 100,
                        child: Container(
                          color: Colors.grey[200],
                        ),
                      ),
                    );
                  } else {
                    return Text('해당 게시물을 찾을 수 없습니다.');
                  }
                },
              );
            },
          );
        } else {
          return Text('좋아하는 경매 게시글이 없습니다.');
        }
      },
    );
  }

  Widget _buildUserFavoriteList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getUserLikesStream(),   // 사용자가 좋아요한 유저게시글 스트림 가져오기
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('데이터를 불러올 수 없습니다.');
        }

        final documents = snapshot.data?.docs;

        if (documents != null && documents.isNotEmpty) {
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final postId = documents[index].id;    // 좋아요한 유저 게시글의 ID

              return FutureBuilder<DocumentSnapshot>(
                future: getUserPostDetails(postId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return Text('게시물을 불러올 수 없습니다.');
                  }

                  final postDocument = snapshot.data;

                  if (postDocument != null && postDocument.exists) {
                    final postTitle = postDocument['title'];
                    final postContent = postDocument['content'];

                    return ListTile(
                      title: Text('게시글 제목: $postTitle'),
                      subtitle: Text('게시글 내용: $postContent'),
                    );
                  } else {
                    return Text('해당 게시물을 찾을 수 없습니다.');
                  }
                },
              );
            },
          );
        } else {
          return Text('좋아하는 유저 게시글이 없습니다.');
        }
      },
    );
  }



// AuctionCommunity에서 경매게시글ID를 사용
  Future<DocumentSnapshot> getAuctionPostDetails(String postId) async {
    try {
      final postDocument = await _firestore.collection('AuctionCommunity').doc(postId).get();
      return postDocument;
    } catch (e) {
      throw Exception('게시물을 불러오는 중에 오류가 발생했습니다: $e');
    }
  }

  // UserCommunity에서 유저게시글ID를 사용
  Future<DocumentSnapshot> getUserPostDetails(String postId) async {
    try {
      final postDocument = await _firestore.collection('UserCommunity').doc(postId).get();
      return postDocument;
    } catch (e) {
      throw Exception('게시물을 불러오는 중에 오류가 발생했습니다: $e');
    }
  }

  // 사용자가 좋아요한 경매게시글을 가져오는 함수
  Stream<QuerySnapshot> _getAuctionLikesStream() {
    return _firestore.collection('User').doc(_userID).collection('auctionLikes').snapshots();
  }

  // 사용자가 좋아요한 유저게시글을 가져오는 함수
  Stream<QuerySnapshot> _getUserLikesStream() {
    return _firestore.collection('User').doc(_userID).collection('userLikes').snapshots();
  }
}