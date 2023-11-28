import 'package:capstone/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
        Text('채팅', style: TextStyle(color: Colors.black, fontSize: 20)),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Chat').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {return Center(child: CircularProgressIndicator());}
          if (snapshot.hasError) {return Center(child: Text('데이터를 불러올 수 없습니다.'));}
          final documents = snapshot.data?.docs;

          if (documents == null || documents.isEmpty) {
            return Center(child: Text('데이터가 없습니다.',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)));
          }

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {

              String documentsId = documents[index].id;
              String auctionId = documents[index]['auctionId'] as String;

              return StreamBuilder<DocumentSnapshot>(
                stream: _firestore.collection('AuctionCommunity').doc(auctionId).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {return Center(child: CircularProgressIndicator());}

                  var auctionData = snapshot.data!.data() as Map<String, dynamic>;

                  String photoURL = auctionData['photoURL'] ?? '';
                  String title = auctionData['title'] ?? '';

                  return Column(
                    children: [
                      Card(
                        elevation: 0,
                        child: ListTile(
                          title: _buildAuctionImage(photoURL),
                          subtitle: Text(title, style: TextStyle(fontSize: 12)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ChatScreen(chatId : documentsId);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
              );
            }
          );
        }
      ),
    );
  }

  // ===========================================================================
  // 경매 상품 사진을 표시하는 함수
  Widget _buildAuctionImage(String auctionImageURL) {
    double _imageSize = 40.0;
    return Center(
      child: Container(
        width: _imageSize,
        height: _imageSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle
        ),
        child: Image.network(auctionImageURL,
            width: _imageSize, height: _imageSize, fit: BoxFit.contain),
      ),
    );
  }

}
