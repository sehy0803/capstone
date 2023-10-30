import 'package:flutter/material.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

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
        body: ListView(
          children: [
            Text('채팅'),
            Text('채팅'),
            Text('채팅'),
            Text('채팅'),
            Text('채팅'),
          ],
        ));
  }
}
