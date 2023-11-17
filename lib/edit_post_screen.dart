import 'package:capstone/custom_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditPostScreen extends StatefulWidget {
  final String documentId;
  EditPostScreen({required this.documentId});

  @override
  State<EditPostScreen> createState() =>
      _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _firestore = FirebaseFirestore.instance;

  String title = ''; // 제목
  String content = ''; // 내용

  late Future<void> _fetchPostDataFuture;

  // Firestore에서 해당 documentId의 데이터를 가져오는 함수
  Future<void> _fetchPostData() async {
    try {
      var documentSnapshot = await _firestore
          .collection('UserCommunity')
          .doc(widget.documentId)
          .get();

      if (documentSnapshot.exists) {
        var data = documentSnapshot.data();
        if (data != null) {
          title = data['title'] ?? '';
          content = data['content'] ?? '';
        }
      }
    } catch (e) {
      print("데이터 가져오기 오류 : $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchPostDataFuture = _fetchPostData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: DarkColors.basic,
        title:
        Text('게시물 수정', style: TextStyle(color: Colors.white, fontSize: 20)),
        leading: IconButton(
          onPressed: () {
            showCloseConfirmationDialog(context);
          },
          icon: Icon(Icons.close),
          iconSize: 30,
          color: Colors.white,
        )
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: FutureBuilder<void>(
            future: _fetchPostDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              if (snapshot.hasError) {
                return Text('오류: ${snapshot.error}');
              }

              return Column(
                children: [
                  TextField(
                    // 가져온 데이터를 기본값으로 설정
                    controller: TextEditingController(text: title),
                    maxLength: 30,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                        hintText: '제목',
                        hintStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    onChanged: (value) {title = value;},
                  ),
                  SizedBox(height: 10),
                  TextField(
                    // 가져온 데이터를 기본값으로 설정
                    controller: TextEditingController(text: content),
                    maxLength: 200,
                    style: TextStyle(fontSize: 18),
                    decoration: InputDecoration(hintText: '내용', hintStyle: TextStyle(fontSize: 18)),
                    keyboardType: TextInputType.multiline,
                    maxLines: 20,
                    onChanged: (value) {content = value;},
                  ),
                  SizedBox(height: 10),
                  // 경매 수정 버튼
                  ElevatedButton(
                      onPressed: () {
                        showConfirmationDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: DarkColors.basic,
                          minimumSize: Size(double.infinity, 55),
                          elevation: 5,
                          shape: StadiumBorder()),
                      child: Text(
                        "수정완료",
                        style: TextStyle(fontSize: 18),
                      )
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }
  //============================================================================

  // firestore에 수정한 정보를 업데이트
  void _updateEditPostData() async {
    if (title.isNotEmpty && content.isNotEmpty) {
      try {
        await _firestore.collection('UserCommunity').doc(widget.documentId).update({
          'title': title,
          'content': content,
        });
      } catch (e) {
        print('데이터 업데이트 오류: $e');
      }
    }
  }

  // 게시물 수정 확인 AlertDialog 표시
  void showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('수정하기'),
          content: Text('수정하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                _updateEditPostData();
                Navigator.pop(context);
                await Future.delayed(Duration(milliseconds: 100)); // 기다렸다가 재구성
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('수정완료',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                    dismissDirection: DismissDirection.up,
                    duration: Duration(milliseconds: 1500),
                    backgroundColor: Colors.black,
                  ),
                );
                Navigator.pop(context);
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

// 게시물 수정 취소 확인 AlertDialog 표시
  void showCloseConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('돌아가기'),
          content: Text('현재 페이지를 벗어나면 변경된 내용이 적용되지 않습니다.\n이전 페이지로 돌아가시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

}
