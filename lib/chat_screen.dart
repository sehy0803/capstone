import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  ChatScreen({
    required this.chatId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
