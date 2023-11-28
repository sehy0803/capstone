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
    fetchAuctionData();
  }

  // firestore에서 경매 정보를 가져오는 함수
  Future<Map<String, dynamic>> getAuctionData() async {
    final document = await _firestore.collection('AuctionCommunity').doc(widget.auctionId).get();
    final data = document.data();

    final auctionPhotoURL = data!['photoURL'] as String;
    final auctionTitle = data!['title'] as String;
    final winningBid = data['winningBid'] as int;

    return {
      'auctionPhotoURL': auctionPhotoURL,
      'auctionTitle': auctionTitle,
      'winningBid': winningBid,
    };
  }

  Future<void> fetchAuctionData() async {
    final auctionData = await getAuctionData();
    setState(() {
      auctionPhotoURL = auctionData['auctionPhotoURL'];
      auctionTitle = auctionData['auctionTitle'];
      winningBid = auctionData['winningBid'];
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
                  blurRadius: 4, // how blurry the shadow should be
                )
              ]
            ),
            child: Column(
                children: [
                  AppBar(
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
                    actions: [
                      IconButton(
                        onPressed: () { },
                        icon: Icon(Icons.more_vert),
                        iconSize: 30,
                        color: Colors.black,
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
                          Icon(Icons.photo, color: Colors.blue[100], size: 80),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(auctionTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

}
