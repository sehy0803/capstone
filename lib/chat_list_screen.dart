import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

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
            itemExtent: 100.0,
            itemBuilder: (context, index) {
              return ChatListItem(
                chatRoomInfo: chatRooms[index],
                onExitChatRoom: exitChatRoom,
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

        if ((uploaderUID == currentUserId ||
            winningBidderUID == currentUserId) &&
            uploaderUID.isNotEmpty &&
            auctionTitle.isNotEmpty &&
            endTime != null) {
          if (endTime.toDate().isBefore(DateTime.now())) {
            // 고유한 채팅방 ID 생성
            String chatRoomId = generateChatRoomId(
                uploaderUID, winningBidderUID, auctionTitle);

            // 이미 존재하는 채팅방인지 확인
            ChatRoomInfo existingChatRoom = chatRooms.firstWhere(
                  (chatRoom) => chatRoom.chatRoomId == chatRoomId,
              orElse: () =>
                  ChatRoomInfo(
                    chatRoomId: '',
                    chatTitle: '',
                    uploaderUID: '',
                    winningBidderUID: '',
                    auctionImageURL: '',
                  ),
            );

            chatRooms.add(ChatRoomInfo(
              chatRoomId: chatRoomId,
              chatTitle: auctionTitle,
              uploaderUID: uploaderUID,
              winningBidderUID: winningBidderUID,
              auctionImageURL: auctionImageURL,
            ).copyWith(chatTitle: auctionTitle));

            if (existingChatRoom.chatRoomId.isEmpty) {
              await createChatMessagesDocument(
                chatRoomId,
                currentUserId,
                uploaderUID,
                winningBidderUID,
                auctionTitle,
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

  String generateChatRoomId(String uploaderUID, String winningBidderUID,
      String auctionTitle) {
    // 적절한 로직으로 고유한 채팅방 ID 생성
    // 여기서는 uploaderUID, winningBidderUID, auctionTitle을 조합하여 생성
    return '$uploaderUID$winningBidderUID$auctionTitle';
  }

  Future<void> createChatMessagesDocument(String chatRoomId,
      String currentUserId,
      String uploaderUID, String winningBidderUID, String auctionTitle) async {
    DocumentReference chatMessagesDocRef =
    FirebaseFirestore.instance.collection('chat_messages').doc(chatRoomId);

    try {
      await _firestore.collection('Chat').doc(chatRoomId).set({
        'chatRoomId': chatRoomId,
        'auctionTitle': auctionTitle,
        'uploaderUID': uploaderUID,
        'winningBidderUID': winningBidderUID,
      });
    } catch (e) {
      print('Chat 문서 생성 중 오류 발생: $e');
    }
  }

  String createRandomChatRoomId() {
    return Uuid().v4(); // Uuid 패키지를 사용하여 랜덤한 ID 생성
  }

  void exitChatRoom(String chatRoomId) async {
    try {
      print('채팅방 나가기: $chatRoomId');

      // Chat 컬렉션에서 해당 채팅방 문서 삭제
      await FirebaseFirestore.instance.collection('Chat')
          .doc(chatRoomId)
          .delete();
      print('채팅방 문서 삭제 성공');

      // Chat 메시지 컬렉션에서 해당 채팅방 ID를 가진 모든 메시지 문서 삭제
      QuerySnapshot<Map<String, dynamic>> messagesSnapshot =
      await FirebaseFirestore.instance.collection('chat_messages').doc(
          chatRoomId).collection('messages').get();

      for (QueryDocumentSnapshot<
          Map<String, dynamic>> messageDoc in messagesSnapshot.docs) {
        await messageDoc.reference.delete();
      }
      print('채팅 메시지 문서 삭제 성공');

      // 해당 채팅방을 chatRooms 리스트에서 제거
      setState(() {
        chatRooms.removeWhere((chatRoom) => chatRoom.chatRoomId == chatRoomId);
      });
    } catch (e) {
      print('채팅방 나가기 중 오류 발생: $e');
    }
  }
}

class ChatRoomInfo {
  final String chatRoomId;
  final String chatTitle;
  final String uploaderUID;
  final String winningBidderUID;
  final String auctionImageURL;

  ChatRoomInfo({
    required this.chatRoomId,
    required this.chatTitle,
    required this.uploaderUID,
    required this.winningBidderUID,
    required this.auctionImageURL,
  });

  ChatRoomInfo copyWith({String? chatTitle}) {
    return ChatRoomInfo(
      chatRoomId: this.chatRoomId,
      chatTitle: chatTitle ?? this.chatTitle,
      uploaderUID: this.uploaderUID,
      winningBidderUID: this.winningBidderUID,
      auctionImageURL: this.auctionImageURL,
    );
  }
}

class ChatListItem extends StatelessWidget {
  final ChatRoomInfo chatRoomInfo;
  final Function(String) onExitChatRoom;

  ChatListItem({
    required this.chatRoomInfo,
    required this.onExitChatRoom,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
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
                chatRoomId: chatRoomInfo.chatRoomId,
                chatTitle: chatRoomInfo.chatTitle,
                uploaderUID: chatRoomInfo.uploaderUID,
                winningBidderUID: chatRoomInfo.winningBidderUID,
                auctionImageURL: chatRoomInfo.auctionImageURL,
              ),
            ),
          );
        },
        onLongPress: () {
          showExitChatDialog(context, chatRoomInfo.chatRoomId);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(chatRoomInfo.auctionImageURL),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${chatRoomInfo.chatTitle}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    FutureBuilder(
                      future: getLastMessage(chatRoomInfo.chatRoomId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text('로딩 중...');
                        }

                        if (snapshot.hasError) {
                          return Text('오류');
                        }

                        var lastMessage = snapshot.data as String?;
                        return Text(
                          lastMessage ?? '',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        );
                      },
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onLongPress: () {
                  showExitChatDialog(context, chatRoomInfo.chatRoomId);
                },
                child: Icon(Icons.more_vert),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> getLastMessage(String chatRoomId) async {
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

          print('마지막 메시지 가져오기 성공: $messageText');

          return '$messageText';
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

  void showExitChatDialog(BuildContext context, String chatRoomId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('채팅방 나가기'),
          content: Text('정말로 이 채팅방을 나가시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                // 채팅방 나가기 함수 호출
                onExitChatRoom(chatRoomId);

                // 다이얼로그 닫기
                Navigator.of(context).pop();
              },
              child: Text('나가기'),
            ),
          ],
        );
      },
    );
  }
}
