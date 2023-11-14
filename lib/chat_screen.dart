import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String chatTitle;
  final String chatRoomId;

  ChatScreen({required this.chatTitle, required this.chatRoomId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageController = TextEditingController(); // 메시지 보내기 함수
  CollectionReference _chatCollection = FirebaseFirestore.instance.collection('chat_messages');
  ScrollController _scrollController = ScrollController();  // 채팅 메시지가 많아 화면에 다 표시되지 않을 시 스크롤 표시 함수

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              // Add any additional actions for the app bar here
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              reverse: true,  // 메시지가 맨 아래에서부터 생성되도록 설정
              controller: _scrollController,
              child: Column(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: _chatCollection
                        .doc(widget.chatTitle)
                        .collection('messages')
                        .orderBy('timestamp')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      var messages = snapshot.data!.docs;

                      return _buildMessageList(messages);
                    },
                  ),
                ],
              ),
            ),
          ),
          _buildMessageInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageList(List<QueryDocumentSnapshot> messages) {
    return Column(
      children: messages.map((message) {
        var messageText = message['text'];
        var messageSender = message['senderId'];

        return _buildMessage(messageText, messageSender);
      }).toList(),
    );
  }

  // 각 메시지를 표시하는 위젯
  Widget _buildMessage(String message, String sender) {
    bool isUser = sender == FirebaseAuth.instance.currentUser?.uid; // 사용자 인증

    return Align(
      // 로그인된 사용자가 보낸 메시지는 오른쪽, 상대방이 보낸 메시지는 왼쪽에 뜨게 설정
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUser ? Colors.blue : Colors.green, // 본인 메시지 박스 : 파란색, 상대방 메시지 박스 : 초록색으로 설정
            borderRadius: BorderRadius.circular(8),
          ), // 채팅방 디자인은 추후 수정 예정
          child: Text(
            message,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
  // 메시지 입력 필드 위젯
  Widget _buildMessageInputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: '메시지를 입력하세요...',  // 메시지 입력 요청 텍스트
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              _sendMessage(_messageController.text);  // 메시지를 보낼 시 채팅방에 날리기 설정
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage(String message) {
    if (message.isNotEmpty) {
      User? user = FirebaseAuth.instance.currentUser; // 로그인된 사용자의 정보

      if (user != null) {
        String senderId = user.uid; // UID를 senderId 변수에 할당

        _chatCollection
            .doc(widget.chatTitle)
            .collection('messages')
            .add({
          'text': message,
          'senderId': senderId,
          'timestamp': FieldValue.serverTimestamp(),
        })
            .then((_) {
          _messageController.clear(); // 메시지 입력 완료 시 메시지 입력 필드 비움
          _scrollController.animateTo(
            0.0,  // 메시지 입력 완료 시 최신 메시지로 스크롤 바 조정
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
        })
            .catchError((error) {
          print('Error sending message: $error');
        });

        _updateSharedChatMessagesDocument(widget.chatTitle, message, senderId);
      }
    }
  }

  void _updateSharedChatMessagesDocument(
      String chatRoomId, String message, String senderId) {
    FirebaseFirestore.instance.collection('chat_messages').doc(chatRoomId).update({
      'latest_message': message,
      'latest_message_sender': senderId,
      'latest_message_timestamp': FieldValue.serverTimestamp(),
    });
  }
}
