import 'package:capstone/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _authentication = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('채팅', style: TextStyle(color: Colors.black, fontSize: 20)),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('User')
            .doc(userID)
            .collection('chat')
            .snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (userSnapshot.hasError) {
            return Center(child: Text('데이터를 불러올 수 없습니다.'));
          }

          List<String> chatIds = [];
          var userDocs = userSnapshot.data?.docs;

          if (userDocs != null && userDocs.isNotEmpty) {
            for (var doc in userDocs) {
              var chatId = doc['chatId'] as String?;
              if (chatId != null) {
                chatIds.add(chatId);
              }
            }
          } else {
            return Center(
                child: Text('채팅이 없습니다.',
                    style: TextStyle(fontSize: 16, color: Colors.grey)));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('Chat')
                .where(FieldPath.documentId, whereIn: chatIds)
                .snapshots(),
            builder: (context, chatSnapshot) {
              if (!chatSnapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              if (chatSnapshot.hasError) {
                return Center(child: Text('데이터를 불러올 수 없습니다.'));
              }

              final chatDocuments = chatSnapshot.data?.docs;

              if (chatDocuments == null || chatDocuments.isEmpty) {
                return Center(
                    child: Text('데이터가 없습니다.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey)));
              }

              return ListView.builder(
                itemCount: chatDocuments.length,
                itemBuilder: (context, index) {
                  String documentId = chatDocuments[index].id;
                  String auctionId =
                      chatDocuments[index]['auctionId'] as String;
                  String chatStatus =
                      chatDocuments[index]['chatStatus'] as String;

                  return StreamBuilder<DocumentSnapshot>(
                    stream: _firestore
                        .collection('AuctionCommunity')
                        .doc(auctionId)
                        .snapshots(),
                    builder: (context, auctionSnapshot) {
                      if (!auctionSnapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      var auctionData =
                          auctionSnapshot.data!.data() as Map<String, dynamic>;

                      String photoURL = auctionData['photoURL'] ?? '';
                      String title = auctionData['title'] ?? '';

                      return StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('Chat')
                              .doc(documentId)
                              .collection('messages')
                              .orderBy('timestamp', descending: true)
                              .limit(1)
                              .snapshots(),
                          builder: (context, messageSnapshot) {
                            if (!messageSnapshot.hasData) {return Center(child: CircularProgressIndicator());}

                            var messages = messageSnapshot.data!.docs;

                            if (messages.isNotEmpty) {
                              var lastMessage = messages.first;
                              var lastMessageText =
                                  lastMessage['text'] as String? ?? '';
                              var lastMessageTimestamp =
                                  lastMessage['timestamp'] as Timestamp;
                              var formattedTimestamp = DateFormat('HH:mm').format(lastMessageTimestamp.toDate());

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return ChatScreen(
                                            chatId: documentId,
                                            auctionId: auctionId,
                                            chatStatus: chatStatus);
                                      },
                                    ),
                                  );
                                },
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Container(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildAuctionImage(photoURL),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        // 경매 상태
                                                        Container(
                                                            decoration: BoxDecoration(
                                                              color: _getStatusColor(chatStatus),
                                                              borderRadius: BorderRadius.circular(10.0),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors.grey, // 그림자 색상
                                                                  offset: Offset(0, 2), // 그림자의 위치 (가로, 세로)
                                                                  blurRadius: 4.0, // 그림자의 흐림 정도
                                                                ),
                                                              ],
                                                            ),
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(4.0),
                                                              child: Text(chatStatus,
                                                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)
                                                              ),
                                                            )
                                                        ),
                                                        SizedBox(width: 10),
                                                        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                      ],
                                                    ),
                                                    Text(formattedTimestamp, style: TextStyle(fontSize: 12, color: Colors.black26)),
                                                  ],
                                                ),
                                                SizedBox(height: 5),
                                                Text(lastMessageText, style: TextStyle(fontSize: 14, color: Colors.black45)),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return SizedBox();
                            }
                          });
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // ===========================================================================

  // 경매 상품 사진을 표시하는 함수
  Widget _buildAuctionImage(String auctionImageURL) {
    double _imageSize = 60.0;
    return Center(
      child: ClipOval(
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
      ),
    );
  }

  // 상태에 따라 다른 색상 적용
  Color _getStatusColor(String chatStatus) {
    if (chatStatus == '진행중') {
      return Colors.green; // 녹색
    } else {
      return Colors.blue; // 파란색
    }
  }
}
