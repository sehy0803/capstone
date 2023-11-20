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

              // 각 문서에서 필요한 정보를 가져와서 화면에 표시
              // 예: 게시글의 제목, 내용 등
              return ListTile(
                title: Text('경매 게시글 ID: $postId'),
                // 추가 정보 표시 또는 탭 선택 시 상세화면으로 이동 등 필요한 기능 추가
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
      stream: _getUserLikesStream(), // 사용자가 좋아요한 유저게시글 스트림 가져오기
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
              final postId = documents[index].id; // 좋아요한 유저 게시글의 ID

              // 각 문서에서 필요한 정보를 가져와서 화면에 표시
              // 예: 게시글의 제목, 내용 등
              return ListTile(
                title: Text('유저 게시글 ID: $postId'),
                // 추가 정보 표시 또는 탭 선택 시 상세화면으로 이동 등 필요한 기능 추가
              );
            },
          );
        } else {
          return Text('좋아하는 유저 게시글이 없습니다.');
        }
      },
    );
  }

  // 사용자가 좋아요한 경매게시글을 가져오는 함수
  Stream<QuerySnapshot> _getAuctionLikesStream() {
    return _firestore.collection('User').doc(_userID).collection('auctionLikes').snapshots();
  }  // auctionLikes 라는 서브컬렉션을 만들어야함. 그리고 서브컬렉션마다 각 게시물 ID가 들어가야함.

  // 사용자가 좋아요한 유저게시글을 가져오는 함수
  Stream<QuerySnapshot> _getUserLikesStream() {
    return _firestore.collection('User').doc(_userID).collection('userLikes').snapshots();
  }
}