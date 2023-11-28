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
    return Scaffold(
      backgroundColor: Color(0xffCEE3F6),
      appBar: AppBar(
        title: Text('채팅', style: TextStyle(color: Colors.black, fontSize: 20)),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.close),
          iconSize: 30,
          color: Colors.black,
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
                                            padding: EdgeInsets.all(12.0),
                                            decoration: BoxDecoration(
                                              color: isCurrentUser
                                                  ? Colors.blue
                                                  : Colors.grey[200],
                                              borderRadius: BorderRadius.circular(8.0),
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
                          child: IconButton(icon: Icon(Icons.send_rounded),
                              padding: EdgeInsets.zero,
                              onPressed: (){})
                      )
                  )
                ]
            ),
          )



        ],
      )

    );
  }
}
