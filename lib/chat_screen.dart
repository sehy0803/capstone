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
  TextEditingController _messageController = TextEditingController();
  CollectionReference _chatCollection =
  FirebaseFirestore.instance.collection('chat_messages');
  ScrollController _scrollController = ScrollController();

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
              reverse: true, // Initially set to true
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

  Widget _buildMessage(String message, String sender) {
    bool isUser = sender == FirebaseAuth.instance.currentUser?.uid;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUser ? Colors.blue : Colors.green,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            message,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: '메시지를 입력하세요...',
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
              _sendMessage(_messageController.text);
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage(String message) {
    if (message.isNotEmpty) {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String senderId = user.uid;

        _chatCollection
            .doc(widget.chatTitle)
            .collection('messages')
            .add({
          'text': message,
          'senderId': senderId,
          'timestamp': FieldValue.serverTimestamp(),
        })
            .then((_) {
          _messageController.clear();
          // Keep the current behavior when sending a message
          _scrollController.animateTo(
            0.0,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
        })
            .catchError((error) {
          print('Error sending message: $error');
        });

        // Update the shared chat messages document with the latest message
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
