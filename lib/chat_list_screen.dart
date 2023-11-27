import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _firestore = FirebaseFirestore.instance;
  List<ChatRoomInfo> chatRooms = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('채팅', style: TextStyle(color: Colors.black, fontSize: 20)),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<ChatRoomInfo>>(
        future: getChatRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('채팅 목록을 가져오는 도중 오류가 발생했습니다.'));
          }

          chatRooms = snapshot.data ?? [];

          return ListView.builder(
            itemCount: chatRooms.length,
            itemExtent: 110.0,
            itemBuilder: (context, index) {
              return ChatListItem(
                chatRoomInfo: chatRooms[index],
                onExitChatRoom: exitChatRoom,
                documentId: chatRooms[index].chatRoomId,
                refreshChatList: refreshChatList,
              );
            },
          );
        },
      ),
    );
  }



  Future<List<ChatRoomInfo>> getChatRooms() async {
    List<ChatRoomInfo> chatRooms = [];

    try {
      String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance.collection('AuctionCommunity').get();

      querySnapshot.docs.forEach((doc) async {
        String uploaderUID = doc['uploaderUID'];
        String winningBidderUID = doc['winningBidderUID'];
        String auctionTitle = doc['title'];
        String auctionImageURL = doc['photoURL'];
        Timestamp? endTime = doc['endTime'];
        String status = doc['status'] ?? '낙찰';

        if ((uploaderUID == currentUserId ||
            winningBidderUID == currentUserId) &&
            uploaderUID.isNotEmpty &&
            auctionTitle.isNotEmpty &&
            endTime != null) {
          if (endTime.toDate().isBefore(DateTime.now())) {
            String documentId = doc.id;

            ChatRoomInfo existingChatRoom = chatRooms.firstWhere(
                  (chatRoom) => chatRoom.chatRoomId == documentId,
              orElse: () => ChatRoomInfo(
                chatRoomId: '',
                chatTitle: '',
                uploaderUID: '',
                winningBidderUID: '',
                auctionImageURL: '',
                status: '낙',
              ),
            );

            chatRooms.add(ChatRoomInfo(
              chatRoomId: documentId,
              chatTitle: auctionTitle,
              uploaderUID: uploaderUID,
              winningBidderUID: winningBidderUID,
              auctionImageURL: auctionImageURL,
              status: status,
            ));

            if (existingChatRoom.chatRoomId.isEmpty) {
              await createChatMessagesDocument(
                documentId,
                currentUserId,
                uploaderUID,
                winningBidderUID,
                auctionTitle,
                status,
              );
            }
          }
        }
      });
    } catch (e) {
      print('채팅 목록을 가져오는 중 오류 발생: $e');
    }

    return chatRooms;
  }

  Future<void> createChatMessagesDocument(
      String documentId,
      String currentUserId,
      String uploaderUID,
      String winningBidderUID,
      String auctionTitle,
      String status,
      ) async {
    try {
      await _firestore.collection('Chat').doc(documentId).set({
        'chatRoomId': documentId,
        'auctionTitle': auctionTitle,
        'uploaderUID': uploaderUID,
        'winningBidderUID': winningBidderUID,
        'status': status, // '진행중'으로 초기화
      });
      print('Chat 문서 생성 성공!');
    } catch (e) {
      print('Chat 문서 생성 중 오류 발생: $e');
    }
  }

  void exitChatRoom(String chatRoomId) async {
    try {
      await FirebaseFirestore.instance.collection('Chat').doc(chatRoomId).delete();
      print('채팅방 문서 삭제 성공');

      QuerySnapshot<Map<String, dynamic>> messagesSnapshot =
      await FirebaseFirestore.instance.collection('chat_messages').doc(chatRoomId).collection('messages').get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> messageDoc in messagesSnapshot.docs) {
        await messageDoc.reference.delete();
      }
      print('채팅 메시지 문서 삭제 성공');

      setState(() {
        chatRooms.removeWhere((chatRoom) => chatRoom.chatRoomId == chatRoomId);
      });
    } catch (e) {
      print('채팅방 나가기 중 오류 발생: $e');
    }
  }

  void refreshChatList() {
    setState(() {});
  }
}

class ChatRoomInfo {
  final String chatRoomId;
  final String chatTitle;
  final String uploaderUID;
  final String winningBidderUID;
  final String auctionImageURL;
  final String status; // 거래 상태 필드 추가

  ChatRoomInfo({
    required this.chatRoomId,
    required this.chatTitle,
    required this.uploaderUID,
    required this.winningBidderUID,
    required this.auctionImageURL,
    required this.status,
  });
}

class ChatListItem extends StatelessWidget {
  final ChatRoomInfo chatRoomInfo;
  final Function(String) onExitChatRoom;
  final String documentId;
  final VoidCallback refreshChatList;

  ChatListItem({
    required this.chatRoomInfo,
    required this.onExitChatRoom,
    required this.documentId,
    required this.refreshChatList,
  });


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chatRoomId: documentId,
                chatTitle: chatRoomInfo.chatTitle,
                uploaderUID: chatRoomInfo.uploaderUID,
                winningBidderUID: chatRoomInfo.winningBidderUID,
                auctionImageURL: chatRoomInfo.auctionImageURL,
                refreshChatList: refreshChatList,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상태 아이콘 추가
              // 완료 상태 표시
              SizedBox(width: 8), // 아이콘과 제목 사이 간격 조절
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(chatRoomInfo.auctionImageURL),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (chatRoomInfo.status == '낙찰')
                              Icon(Icons.check_circle, color: Colors.green),
                            if (chatRoomInfo.status == '거래 완료')
                              Icon(Icons.check_circle, color: Colors.blue),
                            Text(
                              '${chatRoomInfo.chatTitle}',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        // 마지막으로 보낸 채팅 시간 오른쪽 맨 끝에 표시
                        FutureBuilder<LastMessageData?>(
                          future: getLastMessage(documentId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Text('로딩 중...');
                            }

                            if (snapshot.hasError) {
                              return Text('오류');
                            }

                            LastMessageData? lastMessageData = snapshot.data; // 타입을 정확하게 명시
                            if (lastMessageData != null) {
                              return Align(
                                alignment: Alignment.topRight,
                                child: Text(
                                  lastMessageData.timestamp,
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              );
                            } else {
                              return SizedBox.shrink();
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    FutureBuilder<LastMessageData?>(
                      future: getLastMessage(documentId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text('로딩 중...');
                        }
                        if (snapshot.hasError) {
                          return Text('오류');
                        }
                        LastMessageData? lastMessageData = snapshot.data; // 타입을 정확하게 명시
                        if (lastMessageData != null) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              // 마지막으로 보낸 채팅 최대 두 줄까지 표시
                              Text(
                                lastMessageData.message,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  }

  Future<LastMessageData?> getLastMessage(String chatRoomId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await FirebaseFirestore.instance
          .collection('chat_messages')
          .doc(chatRoomId)
          .get();

      if (documentSnapshot.exists) {
        var data = documentSnapshot.data();
        if (data != null) {
          String sender = data['latest_message_sender'] ?? '';
          String messageText = data['latest_message'] ?? '';
          Timestamp timestamp = data['latest_message_timestamp'] ?? Timestamp.now();

          // 마지막 문자 표시할 때 시간 표기법 설정
          String formattedTimestamp = DateFormat('HH:mm').format(timestamp.toDate());

          return LastMessageData(message: messageText, timestamp: formattedTimestamp);
        }
      } else {
        print('문서가 존재하지 않음');
        print('채팅방 ID: $chatRoomId');
      }

      return null;
    } catch (e) {
      print('마지막 메시지를 가져오는 중 오류 발생: $e');
      return null;
    }
  }




class LastMessageData {
  final String message;
  final String timestamp;

  LastMessageData({required this.message, required this.timestamp});
}