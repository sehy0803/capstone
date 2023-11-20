import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _firestore = FirebaseFirestore.instance;
  List<ChatRoomInfo> chatRooms = [];
  String uploaderUID = ''; // 업로더 uid
  String winningBidderUID = ''; // 낙찰자 uid

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
            itemExtent: 100.0, // 아이템의 높이를 원하는 값으로 조절하세요
            itemBuilder: (context, index) {
              return ChatListItem(
                chatRoomId: chatRooms[index].chatRoomId,
                chatTitle: chatRooms[index].chatTitle,
                uploaderUID: chatRooms[index].uploaderUID,
                winningBidderUID: chatRooms[index].winningBidderUID,
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

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in querySnapshot.docs) {
        String uploaderUID = doc['uploaderUID'];
        String winningBidderUID = doc['winningBidderUID'];
        String auctionTitle = doc['title'];
        Timestamp? endTime = doc['endTime'];

        if ((uploaderUID == currentUserId ||
            winningBidderUID == currentUserId) &&
            uploaderUID.isNotEmpty &&
            auctionTitle.isNotEmpty &&
            endTime != null) {
          if (endTime.toDate().isBefore(DateTime.now())) {
            String chatRoomId = createChatRoomId(uploaderUID, winningBidderUID);

            chatRooms.add(ChatRoomInfo(
              chatRoomId: chatRoomId,
              chatTitle: auctionTitle,
              uploaderUID: uploaderUID,
              winningBidderUID: winningBidderUID,
            ));

            // createChatMessagesDocument 함수 호출 시 uploaderUID, winningBidderUID 추가
            await createChatMessagesDocument(
                chatRoomId, currentUserId, uploaderUID, winningBidderUID);
          }
        }
      }
    } catch (e) {
      print('채팅 목록을 가져오는 중 오류 발생: $e');
    }

    return chatRooms;
  }

  Future<void> createChatMessagesDocument(String chatRoomId, String currentUserId,
      String uploaderUID, String winningBidderUID) async {
    DocumentReference chatMessagesDocRef =
    FirebaseFirestore.instance.collection('chat_messages').doc(chatRoomId);

    try {
      // "Chat" 컬렉션에 데이터를 직접 설정합니다.
      await _firestore.collection('Chat').doc(chatRoomId).set({
        'chatRoomId': chatRoomId,
        'uploaderUID': uploaderUID,
        'winningBidderUID': winningBidderUID,
        // 추가 필드는 여기에 추가할 수 있습니다.
      });
    } catch (e) {
      print('Chat 문서 생성 중 오류 발생: $e');
    }
  }

  String createChatRoomId(String uid1, String uid2) {
    List<String> sortedUids = [uid1, uid2]..sort();
    return '${sortedUids[0]}_${sortedUids[1]}';
  }

  void exitChatRoom(String chatRoomId) async {
    try {
      print('채팅방 나가기: $chatRoomId');

      // Chat 컬렉션에서 해당 채팅방 문서 삭제
      await FirebaseFirestore.instance.collection('Chat').doc(chatRoomId).delete();

      print('채팅방 삭제 성공');

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

  ChatRoomInfo({
    required this.chatRoomId,
    required this.chatTitle,
    required this.uploaderUID,
    required this.winningBidderUID,
  });
}

class ChatListItem extends StatelessWidget {
  final String chatRoomId;
  final String chatTitle;
  final String uploaderUID;
  final String winningBidderUID;
  final Function(String) onExitChatRoom;

  ChatListItem({
    required this.chatRoomId,
    required this.chatTitle,
    required this.uploaderUID,
    required this.winningBidderUID,
    required this.onExitChatRoom,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.blueGrey[50],
        ),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage('상대방 프로필 사진 경로'),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$chatTitle',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              FutureBuilder(
                future: getLastMessage(chatRoomId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Loading...');
                  }

                  if (snapshot.hasError) {
                    return Text('Error');
                  }

                  var lastMessage = snapshot.data as String?;
                  return Text(
                    lastMessage ?? '',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  );
                },
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  chatRoomId: chatRoomId,
                  chatTitle: chatTitle,
                  uploaderUID: uploaderUID,
                  winningBidderUID: winningBidderUID,
                ),
              ),
            );
          },
          onLongPress: () {
            showExitChatDialog(context, chatRoomId);
          },
        ),
      ),
    );
  }

  Future<String?> getLastMessage(String chatRoomId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('chat_messages')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var latestMessage = querySnapshot.docs.first.data();
        String sender = latestMessage['senderId'] ?? '';
        String messageText = latestMessage['text'] ?? '';

        return '$sender: $messageText';
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
