import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String chatTitle;
  final String chatRoomId;
  final String uploaderUID;
  final String winningBidderUID;
  final String auctionImageURL;
  final VoidCallback refreshChatList;

  ChatScreen({
    required this.chatTitle,
    required this.chatRoomId,
    required this.uploaderUID,
    required this.winningBidderUID,
    required this.auctionImageURL,
    required this.refreshChatList,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageController = TextEditingController();
  CollectionReference _chatCollection = FirebaseFirestore.instance.collection(
      'chat_messages');
  ScrollController _scrollController = ScrollController();
  bool _isMessageInputFieldVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatTitle),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'cancelDeal') {
                _showCancelDealDialog();
              } else if (value == 'completeDeal') {
                _showCompleteDealDialog();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'cancelDeal',
                child: Text('거래 취소하기'),
              ),
              const PopupMenuItem<String>(
                value: 'completeDeal',
                child: Text('거래 완료'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
            children: [
              Container(
              color: Colors.lightBlue,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage:
                          NetworkImage(widget.auctionImageURL),
                        ),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.chatTitle,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            FutureBuilder<int?>(
                              future: _getWinningBid(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text(
                                    '낙찰가: ???',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return Text(
                                    '낙찰가를 불러올 수 없습니다.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  );
                                } else {
                                  int? winningBid = snapshot.data;

                                  return Text(
                                    '낙찰가: ${winningBid ?? "???"}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Visibility(
                      visible: _isRightButtonVisible(),
                      child: IconButton(
                        icon: Icon(Icons.done),
                        onPressed: () {
                          _showCompleteDealDialog();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Expanded(
              child: SingleChildScrollView(
                reverse: true,
                controller: _scrollController,
                child: Column(
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: _chatCollection
                          .doc(widget.chatRoomId)
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
          Visibility(
            visible: _isMessageInputFieldVisible,
            child: _buildMessageInputField(),
          ),
          Visibility(
            visible: _isDealCompleted(),
            child: Container(
              child: ElevatedButton(
                onPressed: () {
                  // 예시: 거래 완료 다이얼로그 표시
                  _showCompleteDealDialog();
                },
                child: Text('거래 완료'),
              ),
            ),
          ),
          Visibility(
            visible: _isReviewButtonVisible(),
            child: Container(
              child: ElevatedButton(
                onPressed: () {
                  // 예시: 거래 후기 작성 화면으로 이동
                  _navigateToReviewScreen();
                },
                child: Text('거래 후기 남기기'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isReviewButtonVisible() {
    print("현재 사용자 UID: ${FirebaseAuth.instance.currentUser?.uid}");
    print("낙찰자 UID: ${widget.winningBidderUID}");
    return _isDealCompleted() &&
        FirebaseAuth.instance.currentUser?.uid == widget.winningBidderUID;
  }

  bool _isDealCompleted() {
    // TODO: 거래 상태가 '완료' 또는 '취소'인지 여부를 판단하는 로직 구현
    // 실제로는 데이터베이스의 상태를 확인하는 것이 좋습니다.
    bool isCompleted = _getChatRoomStatus() == '거래 완료';

    // 거래가 완료되었으면 채팅 입력 필드를 숨기고, 그렇지 않으면 보이도록 설정
    _isMessageInputFieldVisible = !isCompleted;

    return isCompleted;
  }

  bool _isRightButtonVisible() {
    // TODO: 업로더에게 보일지 낙찰자에게 보일지 여부 결정 로직 구현
    // 예시: 거래 상태가 '완료'가 아니면 업로더에게 보이도록 설정
    return true; // 실제 로직에 맞게 수정
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

    Color backgroundColor = isUser ? Colors.lightBlue : Colors.green;
    Color textColor = isUser ? Colors.white : Colors.white;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            message,
            style: TextStyle(
              color: textColor,
              fontSize: 18.0,
            ),
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
            .doc(widget.chatRoomId)
            .collection('messages')
            .add({
          'text': message,
          'senderId': senderId,
          'timestamp': FieldValue.serverTimestamp(),
        })
            .then((_) {
          _messageController.clear();
          _scrollController.animateTo(
            0.0,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
        })
            .catchError((error) {
          print('Error sending message: $error');
        });

        _updateSharedChatMessagesDocument(widget.chatRoomId, message, senderId);
      }
    }
  }

  void _updateSharedChatMessagesDocument(String chatRoomId, String message,
      String senderId) {
    FirebaseFirestore.instance.collection('chat_messages')
        .doc(chatRoomId)
        .set({
      'latest_message': message,
      'latest_message_sender': senderId,
      'latest_message_timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true))
        .then((_) {
      print('Shared chat messages document created/updated successfully.');
      widget.refreshChatList(); // 채팅 목록을 갱신하기 위한 콜백 호출
    })
        .catchError((error) {
      print('Error creating/updating shared chat messages document: $error');
    });
  }

  Future <void> _showCancelDealDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('거래 취소하기'),
          content: Text('"${widget.chatTitle}"의 거래를 취소하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                // 거래 상태를 '취소'로 업데이트하고 채팅 데이터 삭제
                Navigator.pop(context);
                _updateDealStatus('거래 취소');
                FirebaseFirestore.instance
                    .collection('Chat')
                    .doc(widget.chatRoomId)
                    .delete();
                FirebaseFirestore.instance
                    .collection('chat_messages')
                    .doc(widget.chatRoomId)
                    .delete();

              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future <void> _showCompleteDealDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('거래 완료'),
          content: Text('거래가 성공적으로 완료되었습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                // TODO: 거래 완료 로직 구현
                // 예시: 거래 상태를 '완료'로 업데이트
                _updateDealStatus('거래 완료');
                Navigator.pop(context);
                _hideMessageInputField();


              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _updateDealStatus(String status) {
    FirebaseFirestore.instance
        .collection('AuctionCommunity')
        .doc(widget.chatRoomId)
        .update({
      'status': status,
    })
        .then((_) {
      print('status 업데이트 성공');
      setState(() {
        if (_isDealCompleted()) {
          _hideMessageInputField();
        } else {
          _showMessageInputField();
        }
      });
      if (status == '거래 취소') {
        // 거래가 취소되면 채팅방 삭제
        FirebaseFirestore.instance.collection('Chat')
            .doc(widget.chatRoomId)
            .delete();
      }
    })
        .catchError((error) {
      print('status 업데이트 오류: $error');
    });
  }


  void _hideMessageInputField() {
    print("Hiding message input field");
    if (_isMessageInputFieldVisible) {
      setState(() {
        _isMessageInputFieldVisible = false;
      });
    }
  }

  void _showMessageInputField() {
    print("Showing message input field");
    if (!_isMessageInputFieldVisible) {
      setState(() {
        _isMessageInputFieldVisible = true;
      });
    }
  }



  Future<int?> _getWinningBid() async {
    try {
      var documentSnapshot = await FirebaseFirestore.instance
          .collection('AuctionCommunity')
          .doc(widget.chatRoomId)
          .get();

      int? winningBid = documentSnapshot['winningBid'];

      return winningBid;
    } catch (error) {
      print('Error getting winningBid: $error');
      return null;
    }
  }

  Future<String?> _getChatRoomStatus() async {
    try {
      var documentSnapshot = await FirebaseFirestore.instance
          .collection('AuctionCommunity')
          .doc(widget.chatRoomId)
          .get();

      String? status = documentSnapshot['status'];
      print('status: $status');

      return status;

    }
    catch (error) {
      print('상태를 가져오는 동안 오류 발생: $error');
      return null;
    }
  }


  void _navigateToReviewScreen() {
    // TODO: 거래 후기 작성 화면으로 이동하는 코드 작성
    // Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewScreen(chatRoomId: widget.chatRoomId)),);
  }
}