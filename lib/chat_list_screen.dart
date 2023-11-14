import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  ChatListScreen({Key? key});

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

          final chatRooms = snapshot.data ?? [];

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(chatRooms[index].chatTitle),
                onTap: () {
                  // 채팅방을 클릭했을 때 ChatScreen으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatRoomId: chatRooms[index].chatRoomId,
                        chatTitle: chatRooms[index].chatTitle,
                      ),
                    ),
                  );
                },
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
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance.collection('AuctionCommunity').get();  // DB에서 컬렉션 정보 가져오기

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in querySnapshot.docs) {
        String uploaderUID = doc['uploaderUID'];
        String winningBidderUID = doc['winningBidderUID'];
        String auctionTitle = doc['title'];

        if (uploaderUID.isNotEmpty && winningBidderUID.isNotEmpty && auctionTitle.isNotEmpty) { // 채팅방 생성 조건

          String chatRoomId = createChatRoomId(uploaderUID, winningBidderUID);  // 채팅방 ID 생성

          chatRooms.add(ChatRoomInfo(chatRoomId: chatRoomId, chatTitle: auctionTitle)); // 채팅방 정보 추가

          await createChatMessagesDocument(chatRoomId); // 채팅 메시지 문서 생성
        }
      }
    } catch (e) {
      print('Error getting chat rooms: $e');
    }

    return chatRooms;
  }

  Future<void> createChatMessagesDocument(String chatRoomId) async {

    DocumentReference chatMessagesDocRef = FirebaseFirestore.instance
        .collection('chat_messages')
        .doc(chatRoomId); // DB의 chat_messages 문서 참조


    if (!(await chatMessagesDocRef.get()).exists) { // 문서가 이미 존재하는지 확인
      await chatMessagesDocRef.set({  // 없는 경우 문서 생성
        'created_at': FieldValue.serverTimestamp(),
      });
    }
  }

  String createChatRoomId(String uid1, String uid2) {
    List<String> sortedUids = [uid1, uid2]..sort(); // UID 정렬
    return '${sortedUids[0]}_${sortedUids[1]}';
  }
}

class ChatRoomInfo {
  final String chatRoomId;
  final String chatTitle;

  ChatRoomInfo({required this.chatRoomId, required this.chatTitle});
}
