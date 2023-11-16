import 'package:capstone/community_auction_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _firestore = FirebaseFirestore.instance;

  int startBid = 0;
  int winningBid = 0;
  String winningBidder = '';
  String winningBidderUID = '';
  String status = '';
  Timestamp endTime = Timestamp(0, 0);


  // 남은 시간
  int remainingTime = 0;


  bool isButton1Selected = true;
  bool isButton2Selected = false;
  bool isButton3Selected = false;
  bool isButton4Selected = false;

  void changePage(bool button1, bool button2, bool button3, bool button4) {
    setState(() {
      isButton1Selected = button1;
      isButton2Selected = button2;
      isButton3Selected = button3;
      isButton4Selected = button4;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  // 남은 시간을 받아와서 표시하는 함수
  String getFormattedRemainingTime(int remainingTime, String status, endTime) {
    // 남은 시간이 0 이거나 경매 상태가 낙찰 또는 경매 실패일 경우(경매가 종료됐을 때)
    if (remainingTime <= 0 || status == '낙찰' || status == '경매 실패') {
      return '경매 종료 ${DateFormat('MM월 dd일 HH시 mm분').format(endTime.toDate())}';
    } else if (remainingTime < 60) {
      // 남은 시간이 1분 미만일 경우
      return '잠시 후 종료';
    } else {
      // 남은 시간 표시
      Duration remainingDuration = Duration(seconds: remainingTime);

      if (remainingDuration.inHours >= 1) {
        return '${remainingDuration.inHours}시간 후 종료';
      } else {
        return '${remainingDuration.inMinutes}분 후 종료';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            Text('카테고리', style: TextStyle(color: Colors.black, fontSize: 20)),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: CategoryButtons(
                isButton1Selected: isButton1Selected,
                isButton2Selected: isButton2Selected,
                isButton3Selected: isButton3Selected,
                isButton4Selected: isButton4Selected,
                changePage: changePage,
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _getAuctionStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('데이터를 불러올 수 없습니다.'));
                }

                final documents = snapshot.data?.docs;

                // 선택한 카테고리를 기준으로 경매 게시글 가져옴
                final filteredAuctions = documents?.where((document) {
                  String category = document['category'];
                  return (category == "1" && isButton1Selected) ||
                      (category == "2" && isButton2Selected) ||
                      (category == "3" && isButton3Selected) ||
                      (category == "4" && isButton4Selected);
                }).toList();

                if (filteredAuctions == null || filteredAuctions.isEmpty) {
                  // 해당하는 경매가 없는 경우
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                        child: Text('아직 해당하는 경매가 없습니다.\n경매를 등록해보세요!',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center)),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: filteredAuctions?.length ?? 0,
                    itemBuilder: (context, index) {
                      final title = filteredAuctions![index]['title'] as String;
                      final content =
                          filteredAuctions[index]['content'] as String;
                      final uploaderUID =
                          filteredAuctions[index]['uploaderUID'] as String;
                      final uploaderEmail =
                          filteredAuctions[index]['uploaderEmail'] as String;
                      final uploaderImageURL =
                          filteredAuctions[index]['uploaderImageURL'] as String;
                      final uploaderNickname =
                          filteredAuctions[index]['uploaderNickname'] as String;
                      final documentId = getDocumentId(filteredAuctions![index]);
                      final views = filteredAuctions[index]['views'] as int;
                      final like = filteredAuctions[index]['like'] as int;
                      final comments = filteredAuctions[index]['comments'] as int;
                      final photoURL =
                          filteredAuctions[index]['photoURL'] as String;
                      final createDate =
                          filteredAuctions[index]['createDate'] as Timestamp;
                      final startBid = filteredAuctions[index]['startBid'] as int;
                      final winningBid =
                          filteredAuctions[index]['winningBid'] as int;
                      final winningBidder =
                          filteredAuctions[index]['winningBidder'] as String;
                      final winningBidderUID =
                          filteredAuctions[index]['winningBidderUID'] as String;
                      final status = filteredAuctions[index]['status'] as String;
                      final endTime =
                          filteredAuctions[index]['endTime'] as Timestamp;
                      final category =
                          filteredAuctions[index]['category'] as String;

                      // 남은 시간
                      final remainingTime = filteredAuctions[index]['remainingTime'] as int;


                      return GestureDetector(
                        onTap: () {
                          increaseViews(getDocumentId(filteredAuctions[index]), 'AuctionCommunity');
                          try {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return CommunityAuctionDetailScreen(
                                    title: title,
                                    content: content,
                                    uploaderUID: uploaderUID,
                                    uploaderEmail: uploaderEmail,
                                    uploaderImageURL: uploaderImageURL,
                                    uploaderNickname: uploaderNickname,
                                    collectionName: 'AuctionCommunity',
                                    documentId: documentId,
                                    views: views + 1,
                                    like: like,
                                    comments: comments,
                                    photoURL: photoURL,
                                    startBid: startBid,
                                    winningBid: winningBid,
                                    winningBidder: winningBidder,
                                    winningBidderUID: winningBidderUID,
                                    status: status,
                                    createDate: createDate,
                                    endTime: endTime,
                                    category: category,

                                    // 남은 시간
                                    remainingTime: remainingTime,
                                  );
                                },
                              ),
                            );
                          } catch (e) {
                            print('$e');
                          }
                        },
                        child: Column(
                          children: [
                            Card(
                              elevation: 0,
                              child: Row(
                                children: [
                                  _buildAuctionImage(
                                      filteredAuctions[index]['photoURL']),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(
                                                    filteredAuctions[index]
                                                        ['status']),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey, // 그림자 색상
                                                    offset: Offset(0, 2), // 그림자의 위치 (가로, 세로)
                                                    blurRadius: 4.0, // 그림자의 흐림 정도
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(6.0),
                                                child: Text(
                                                  filteredAuctions[index]
                                                      ['status'],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Text(title,
                                                style: TextStyle(fontSize: 16)),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            // 경매 상태에 따라 Text 위젯의 텍스트를 동적으로 변경
                                            StreamBuilder<String>(
                                              stream: getAuctionStatusStream(documentId),
                                              builder: (context, snapshot) {
                                                if (!snapshot.hasData) {
                                                  return Center(child: CircularProgressIndicator());
                                                }
                                                String status = snapshot.data ?? '경매 상태 없음';

                                                // Text 위젯의 텍스트를 동적으로 변경
                                                String textToShow = (status == '낙찰')
                                                    ? '낙찰가'
                                                    : (status == '경매 실패')
                                                    ? '경매 실패'
                                                    : '최소 입찰가';

                                                return Text(
                                                  textToShow,
                                                  style: TextStyle(fontSize: 16),
                                                );
                                              },
                                            ),
                                            Text('$winningBid원', style: TextStyle(fontSize: 16, color: Colors.blue)),
                                          ],
                                        ),
                                        // 남은 시간 표시
                                        buildRemainingTime(remainingTime, status, endTime),

                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(height: 1, color: Colors.grey[200])
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
    );
  }

  // =========================================================

  // 남은 시간 표시
  Widget buildRemainingTime(int remainingTime, String status, Timestamp endTime) {
    if (remainingTime <= 0 || status == '낙찰' || status == '경매 실패') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('경매 종료', style: TextStyle(fontSize: 16, color: Colors.grey)),
          Text('${DateFormat('MM월 dd일 HH시 mm분').format(endTime.toDate())}',
              style: TextStyle(fontSize: 16, color: Colors.grey))
        ],
      );
    } else if (remainingTime < 60) {
      return Center(
        child: Text(
          '잠시 후 종료',
          style: TextStyle(fontSize: 16, color: Colors.redAccent),
        ),
      );
    } else {
      return Center(
        child: Text(
          getFormattedRemainingTime(remainingTime, status, endTime),
          style: TextStyle(fontSize: 16, color: Colors.redAccent),
        ),
      );
    }
  }

  // 경매 상태를 가져오는 스트림
  Stream<String> getAuctionStatusStream(String documentId) {
    String postDocumentPath = 'AuctionCommunity/$documentId';
    return FirebaseFirestore.instance
        .doc(postDocumentPath)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return doc.get('status') as String; // 'status' 필드의 값을 반환
      } else {
        return '경매 상태 없음'; // 문서가 존재하지 않을 때의 기본값 설정
      }
    });
  }

  // 경매 게시판의 게시물을 가져오는 스트림
  Stream<QuerySnapshot> _getAuctionStream() {
    return _firestore
        .collection('AuctionCommunity')
        .orderBy('createDate', descending: true)
        .snapshots();
  }

  // _getStatusColor 함수
  Color _getStatusColor(String status) {
    if (status == '진행중') {
      return Colors.green; // 녹색
    } else if (status == '낙찰') {
      return Colors.red; // 빨간색
    } else if (status == '경매 실패') {
      return Colors.grey; // 회색
    } else {
      return Colors.black; // 기본값 (다른 상태일 때)
    }
  }

  // 경매 상품 사진을 표시하는 함수
  Widget _buildAuctionImage(String auctionImageURL) {
    double _imageSize = 100.0;
    return Center(
      child: Container(
        color: Colors.black,
        width: _imageSize,
        height: _imageSize,
        child: Image.network(auctionImageURL,
            width: _imageSize, height: _imageSize, fit: BoxFit.cover),
      ),
    );
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

// 카테고리 버튼
class CategoryButtons extends StatelessWidget {
  final bool isButton1Selected;
  final bool isButton2Selected;
  final bool isButton3Selected;
  final bool isButton4Selected;
  final Function(bool, bool, bool, bool) changePage;

  CategoryButtons({
    required this.isButton1Selected,
    required this.isButton2Selected,
    required this.isButton3Selected,
    required this.isButton4Selected,
    required this.changePage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        buildCategoryButton("의류/패션", isButton1Selected),
        buildCategoryButton("전자제품", isButton2Selected),
        buildCategoryButton("가전제품", isButton3Selected),
        buildCategoryButton("기타", isButton4Selected),
      ],
    );
  }

  Widget buildCategoryButton(String text, bool isSelected) {
    return TextButton(
      onPressed: () {
        // changePage 함수를 호출하여 페이지를 변경
        if (text == "의류/패션") {
          changePage(
            true,
            false,
            false,
            false,
          );
        } else if (text == "전자제품") {
          changePage(
            false,
            true,
            false,
            false,
          );
        } else if (text == "가전제품") {
          changePage(
            false,
            false,
            true,
            false,
          );
        } else if (text == "기타") {
          changePage(
            false,
            false,
            false,
            true,
          );
        }
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.all(15),
        backgroundColor: isSelected ? Colors.black12 : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
      child: Text(text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: isSelected ? Colors.black : Colors.grey,
          )),
    );
  }
}
