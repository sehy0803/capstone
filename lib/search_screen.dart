import 'package:capstone/community_auction_detail_screen.dart';
import 'package:capstone/custom_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _firestore = FirebaseFirestore.instance;
  TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];
  List<String> documentIds = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 빈 곳 터치시 키패드 사라짐
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            // 검색어 입력창
            title: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: DarkColors.basic),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  hintText: '검색어를 입력해주세요',
                  hintStyle: TextStyle(fontSize: 16, color: Colors.grey[400]!),
                  contentPadding: EdgeInsets.all(10)),
            ),
            backgroundColor: Colors.white,
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios),
                iconSize: 30,
                color: Colors.black,
                padding: EdgeInsets.all(0)),
            actions: [
              // 검색 버튼
              IconButton(
                onPressed: () {
                  _performSearch(_searchController.text);
                },
                icon: Icon(Icons.search),
                iconSize: 30,
                color: Colors.black,
              ),
            ]),
        body: ListView.builder(
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            // 경매 정보
            String documentId = _searchResults[index].id;
            String photoURL = _searchResults[index]['photoURL'];
            String title = _searchResults[index]['title'];
            int winningBid = _searchResults[index]['winningBid'];
            String status = _searchResults[index]['status'];

            // 시간 정보
            Timestamp endTime = _searchResults[index]['endTime'];
            int remainingTime = _searchResults[index]['remainingTime'];

            return GestureDetector(
              onTap: () {
                increaseViews(documentId, 'AuctionCommunity'); // 조회수 증가
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return CommunityAuctionDetailScreen(documentId: documentId);
                    },
                  ),
                );
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
                                  Container(
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status),
                                      borderRadius: BorderRadius.circular(10.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey,
                                          offset: Offset(0, 2),
                                          blurRadius: 4.0,
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(title, style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    (status == '낙찰')
                                        ? '낙찰가'
                                        : (status == '경매 실패')
                                        ? '경매 실패'
                                        : '최소 입찰가',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text('$winningBid원', style: TextStyle(fontSize: 16, color: Colors.blue)),
                                ],
                              ),
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
          },
        ),
      )
    );
  }
  // ===========================================================================
  // 검색을 수행할 함수
  Future<void> _performSearch(String query) async {
    if (query.isNotEmpty) {
      QuerySnapshot querySnapshot = await _firestore
          .collection('AuctionCommunity')
          .where('title', isEqualTo: query)
          .get();

      setState(() {
        _searchResults = querySnapshot.docs;
      });
    }
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

