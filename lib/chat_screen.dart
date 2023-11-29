import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String auctionId;
  final String chatStatus;

  ChatScreen({
    required this.chatId,
    required this.auctionId,
    required this.chatStatus,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _authentication = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();

  String userID = '';

  String auctionPhotoURL = '';
  String auctionTitle = '';
  String uploaderUID = '';
  String uploaderNickname = '';
  String winningBidderUID = '';
  String winningBidderNickname = '';
  int winningBid = 0;

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
    fetchAuctionData().then((_) {
      fetchUserData();
    });
  }

  // firestore에서 경매 정보를 가져오는 함수
  Future<Map<String, dynamic>> getAuctionData() async {
    // 경매 정보
    final auctionDocument = await _firestore.collection('AuctionCommunity').doc(widget.auctionId).get();
    final auctionData = auctionDocument.data();

    final auctionPhotoURL = auctionData!['photoURL'] as String;
    final auctionTitle = auctionData!['title'] as String;
    final uploaderUID = auctionData!['uploaderUID'] as String;
    final winningBidderUID = auctionData!['winningBidderUID'] as String;
    final winningBid = auctionData['winningBid'] as int;

    return {
      // 경매 정보
      'auctionPhotoURL': auctionPhotoURL,
      'auctionTitle': auctionTitle,
      'uploaderUID': uploaderUID,
      'winningBidderUID': winningBidderUID,
      'winningBid': winningBid,
    };
  }

  // firestore에서 유저 정보를 가져오는 함수
  Future<Map<String, dynamic>> getUserData() async {
    // 업로더 정보
    final uploaderDocument = await _firestore.collection('User').doc(uploaderUID).get();
    final uploaderData = uploaderDocument.data();

    final uploaderNickname = uploaderData!['nickname'] as String;

    // 낙찰자 정보
    final winningBidderDocument = await _firestore.collection('User').doc(winningBidderUID).get();
    final winningBidderData = winningBidderDocument.data();

    final winningBidderNickname = winningBidderData!['nickname'] as String;

    return {
      // 유저 정보
      'uploaderNickname': uploaderNickname,
      'winningBidderNickname': winningBidderNickname,
    };
  }

  // 정보 업데이트
  Future<void> fetchAuctionData() async {
    final auctionData = await getAuctionData();
    setState(() {
      // 경매 정보
      auctionPhotoURL = auctionData['auctionPhotoURL'];
      auctionTitle = auctionData['auctionTitle'];
      uploaderUID = auctionData['uploaderUID'];
      winningBidderUID = auctionData['winningBidderUID'];
      winningBid = auctionData['winningBid'];
    });
  }

  // 정보 업데이트
  Future<void> fetchUserData() async {
    final userData = await getUserData();
    setState(() {
      // 유저 정보
      uploaderNickname = userData['uploaderNickname'];
      winningBidderNickname = userData['winningBidderNickname'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffCEE3F6),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(137),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 4),
                  blurRadius: 4,
                )
              ]
            ),
            child: Column(
                children: [
                  AppBar(
                    title: Text(userID == uploaderUID ? winningBidderNickname : uploaderNickname,
                      style: TextStyle(color: Colors.black, fontSize: 20)),
                    elevation: 0,
                    backgroundColor: Colors.white,
                    leading: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back_ios_rounded),
                      iconSize: 30,
                      color: Colors.black,
                    ),

                    // 거래 취소하기 버튼
                    actions: [
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: Colors.black, size: 30),
                        offset: Offset(0, 60),
                        onSelected: (value) {
                          if (value == 'cancel') {
                            showDialogCancel(context);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem<String>(
                              value: 'cancel',
                              child: Text('거래 취소하기'),
                            ),
                          ];
                        },
                      ),
                    ],
                  ),
                  Container(
                    color: Colors.black12,
                    height: 1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildAuctionImage(auctionPhotoURL),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                  width: 170,
                                  child: Text(auctionTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                              SizedBox(height: 5),
                              Text('$winningBid', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 10.0),
                        child: SizedBox(
                          width: 80,
                          height: 60,
                          child: OutlinedButton(
                            onPressed: () {},
                            child: Text('거래중', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      )
                    ],
                  )
                ]),
          ),

      ),
      body: Column(
        children: [
          // 채팅방 정보
          Expanded(
            child: GestureDetector(
              // 빈 곳 터치시 키패드 사라짐
              onTap: () {FocusScope.of(context).unfocus();},
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('Chat').doc(widget.chatId).collection('messages')
                    .orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {return Center(child: CircularProgressIndicator());}

                  var messages = snapshot.data!.docs;

                  // 경매 정보
                  return StreamBuilder<DocumentSnapshot>(
                    stream: _firestore.collection('AuctionCommunity').doc(widget.auctionId).snapshots(),
                    builder: (context, auctionSnapshot) {
                      if (!auctionSnapshot.hasData) {return Center(child: CircularProgressIndicator());}

                      var auctionData = auctionSnapshot.data!.data() as Map<String, dynamic>;

                      // 유저 정보
                      String uploaderUID = auctionData['uploaderUID'] ?? '';
                      String winningBidderUID = auctionData['winningBidderUID'] ?? '';

                      // 경매 정보
                      String photoURL = auctionData['photoURL'] ?? '';
                      String title = auctionData['title'] ?? '';
                      String status = auctionData['status'] ?? '';
                      int winningBid = auctionData['winningBid'] ?? 0;

                      return ListView.builder(
                        shrinkWrap: true,
                                reverse: true, // 새로운 메시지가 위로 올라가도록 설정
                                itemCount: messages.length,
                                itemBuilder: (context, index) {
                                  var message = messages[index];

                                  var senderUID = message['senderUid'] ?? ''; // 보낸 사람
                                  var text = message['text'] ?? ''; // 보낸 메시지
                                  var timestamp = message['timestamp'] as Timestamp?; // 보낸 시간

                                  if (senderUID != null && text != null && timestamp != null) {
                                    bool isCurrentUser = senderUID == userID;

                                    return Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment: isCurrentUser
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 100),
                                            padding: EdgeInsets.all(12.0),
                                            decoration: BoxDecoration(
                                              color: isCurrentUser
                                                  ? Colors.yellow
                                                  : Colors.white,
                                              borderRadius: BorderRadius.circular(8.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black12,
                                                    offset: Offset(0, 2),
                                                    blurRadius: 2, // how blurry the shadow should be
                                                  )
                                                ]
                                            ),
                                            child: Text(text, style: TextStyle(fontSize: 16.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return SizedBox(); // 유효하지 않은 메시지는 무시
                                  }
                                },
                              );

                    }
                  );
                }
              ),
            ),
          ),


          // 입찰가 입력
          Visibility(
            visible: widget.chatStatus == '진행중',
            child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 55,
                      color: Colors.white,
                      alignment: Alignment.center,
                      child: TextFormField(
                        controller: _messageController,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.all(Radius.circular(0.0)),
                            ),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.all(Radius.circular(0.0)),
                            ),
                            hintText: '메시지 입력',
                            hintStyle: TextStyle(fontSize: 16, color: Colors.black26),
                            contentPadding: EdgeInsets.all(15)),
                      ),
                    ),
                  ),
                  SizedBox(
                      width: 55,
                      height: 55,
                      child: ElevatedButton(
                          onPressed: () { },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.blue),
                              borderRadius: BorderRadius.circular(0.0),
                            ),
                          ),
                          child: IconButton(
                              onPressed: (){
                                _sendMessage(_messageController.text);
                              },
                              icon: Icon(Icons.send_rounded),
                              padding: EdgeInsets.zero
                          )
                      )
                  )
                ]
            ),
          )



        ],
      )

    );
  }

  //============================================================================
  // 채팅 전송 함수
  void _sendMessage(String text) async {
    _messageController.clear();

    if (text.isNotEmpty) {
      CollectionReference messagesCollection = _firestore.collection('Chat').doc(widget.chatId).collection('messages');

      await messagesCollection.add({
        'senderUid': userID,
        'text': text,
        'timestamp': Timestamp.now(),
      });
    }
  }

  // 경매 상품 사진을 표시하는 함수
  Widget _buildAuctionImage(String auctionImageURL) {
    double _imageSize = 80.0;
    if (auctionImageURL.isNotEmpty) {
      return Center(
        child: Container(
          width: _imageSize,
          height: _imageSize,
          child: Image.network(
            auctionImageURL,
            width: _imageSize,
            height: _imageSize,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Center(
        child: Text("이미지 없음"),
      );
    }
  }

  // 게시물 삭제 확인 AlertDialog 표시
  void showDialogCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('거래 취소하기'),
          content: Text('거래를 취소하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                cancelTransaction();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '거래가 취소되었습니다.',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    dismissDirection: DismissDirection.up,
                    duration: Duration(milliseconds: 1500),
                    backgroundColor: Colors.black,
                  ),
                );
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 채팅방 삭제 함수
  Future<void> cancelTransaction() async {
    Navigator.pop(context);
    try {
      // Firestore에서 채팅방 삭제하기 전에 해당 채팅방의 DocumentSnapshot을 가져오기
      final chatSnapshot = await _firestore
          .collection('Chat')
          .doc(widget.chatId)
          .get();

      if (chatSnapshot.exists) {
        // DocumentSnapshot이 존재하는 경우에만 채팅방을 삭제
        await _firestore
            .collection('Chat')
            .doc(widget.chatId)
            .delete();

        // 삭제된 채팅방과 관련된 데이터 삭제
        await _deleteRelatedData(widget.chatId);

      } else {
        // DocumentSnapshot이 존재하지 않는 경우에 대한 처리
        print('채팅방이 이미 삭제되었습니다.');
      }
    } catch (e) {
      print('채팅방 삭제 중 오류 발생: $e');
    }
  }

  // User 컬렉션에서 채팅방과 관련된 데이터 삭제 함수
  Future<void> _deleteRelatedData(String chatId) async {
    // 컬렉션에서 해당 채팅방의 chatId를 가진 문서를 찾아 삭제
    var userSnapshots = await _firestore.collection('User').get();
    for (var userSnapshot in userSnapshots.docs) {
      String userUID = userSnapshot.id;

      var registeredAuctionsQuery = await _firestore
          .collection('User')
          .doc(userUID)
          .collection('chat')
          .where('chatId', isEqualTo: chatId)
          .get();

      for (var doc in registeredAuctionsQuery.docs) {
        await doc.reference.delete();
      }
    }
  }

}
