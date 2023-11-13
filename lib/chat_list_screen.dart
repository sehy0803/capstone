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
      // Fetch the Firestore documents containing the chat room data
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance.collection('AuctionCommunity').get();

      // Iterate through the documents and extract relevant information
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in querySnapshot.docs) {
        String uploaderUID = doc['uploaderUID'];
        String winningBidderUID = doc['winningBidderUID'];
        String auctionTitle = doc['title'];

        // Check if both uploaderUID, winningBidderUID, and auctionTitle are not empty
        if (uploaderUID.isNotEmpty && winningBidderUID.isNotEmpty && auctionTitle.isNotEmpty) {
          // Create a unique chat room ID using both user UIDs
          String chatRoomId = createChatRoomId(uploaderUID, winningBidderUID);

          // Create a chat room info object and add it to the list
          chatRooms.add(ChatRoomInfo(chatRoomId: chatRoomId, chatTitle: auctionTitle));

          // Create chat messages document if it doesn't exist
          await createChatMessagesDocument(chatRoomId);
        }
      }
    } catch (e) {
      print('Error getting chat rooms: $e');
    }

    return chatRooms;
  }

  Future<void> createChatMessagesDocument(String chatRoomId) async {
    // Reference to the chat messages document in Firestore
    DocumentReference chatMessagesDocRef = FirebaseFirestore.instance
        .collection('chat_messages')
        .doc(chatRoomId);

    // Check if the document already exists
    if (!(await chatMessagesDocRef.get()).exists) {
      // If not, create the document with initial data
      await chatMessagesDocRef.set({
        'created_at': FieldValue.serverTimestamp(),
      });
    }
  }

  String createChatRoomId(String uid1, String uid2) {
    // Sort the UIDs to ensure consistency in the chat room ID
    List<String> sortedUids = [uid1, uid2]..sort();
    return '${sortedUids[0]}_${sortedUids[1]}';
  }
}

class ChatRoomInfo {
  final String chatRoomId;
  final String chatTitle;

  ChatRoomInfo({required this.chatRoomId, required this.chatTitle});
}
