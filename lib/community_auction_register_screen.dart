import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AuctionRegisterScreen extends StatefulWidget {
  const AuctionRegisterScreen({super.key, required String boardType});

  @override
  State<AuctionRegisterScreen> createState() => _AuctionRegisterScreenState();
}

class _AuctionRegisterScreenState extends State<AuctionRegisterScreen> {
  final _authentication = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  File? _pickedFile;

  // 유저가 입력한 게시글 정보를 저장할 변수
  String title = ''; // 제목
  String content = ''; // 내용
  String uploaderEmail = ''; // 업로더 이메일
  String uploaderImageURL = ''; // 업로더 프로필 사진 URL
  String uploaderNickname = ''; // 업로더 닉네임
  String createDate = ''; // 글을 올린 날짜와 시간
  int views = 0; // 조회수
  int like = 0; // 좋아요 횟수
  int comments = 0; // 댓글 수
  String photoURL = ''; // 사진
  String endTime = ''; // 경매 종료시간
  String nowPrice = ''; // 즉시거래가

  @override
  void initState() {
    super.initState();
    getCurrentUser(); // Firestore에서 업로더 정보 가져오기
    setCreateDate(); // 현재 시간으로 createDate 설정
  }

  // Firestore에서 업로더 정보 가져오기
  void getCurrentUser() async {
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        final userDocument =
            await _firestore.collection('User').doc(user.uid).get();
        if (userDocument.exists) {
          uploaderEmail = userDocument['email'];
          uploaderImageURL = userDocument['imageURL'];
          uploaderNickname = userDocument['nickname'];
        }
      }
    } catch (e) {
      print('업로더 정보 가져오기 오류: $e');
    }
  }

  // 현재 시간으로 createDate 설정
  void setCreateDate() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy.MM.dd HH:mm');
    createDate = formatter.format(now);
  }

  // 상품 사진을 스토리지에 업로드
  Future<String> uploadImageToStorage(File imageFile) async {
    try {
      final storageReference = FirebaseStorage.instance.ref().child('images/${Uuid().v4()}');
      await storageReference.putFile(imageFile);

      final imageUrl = await storageReference.getDownloadURL();

      return imageUrl;
    } catch (e) {
      print('이미지 업로드 오류: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title:
            Text('경매 게시판', style: TextStyle(color: Colors.black, fontSize: 20)),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.close),
          iconSize: 30,
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // 상품 사진 업로드
              Container(
                constraints: BoxConstraints(
                  minHeight: 150,
                  minWidth: 150,
                ),
                child: GestureDetector(
                  onTap: () async {
                    var picker = ImagePicker();
                    var image =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        _pickedFile = File(image.path);
                        photoURL = _pickedFile!.path;
                      });
                    }
                  },
                  child: Center(
                    // 기본 아이콘
                    child: _pickedFile == null
                        ? Container(
                            width: 150,
                            height: 150,
                            color: Colors.black12,
                            child: Icon(
                              Icons.add_photo_alternate_rounded,
                              color: Colors.black26,
                              size: 100,
                            ),
                          )
                        // 사진 선택 후
                        : Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(File(_pickedFile!.path)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // 경매 제목
              TextField(
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                    hintText: '제목',
                    hintStyle:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onChanged: (value) {
                  title = value;
                },
              ),

              // 즉시거래가
              TextField(
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 18),
                decoration: InputDecoration(
                    hintText: '즉시거래가', hintStyle: TextStyle(fontSize: 18)),
                onChanged: (value) {
                  nowPrice = value;
                },
              ),

              // 경매 종료 시간
              TextField(
                keyboardType: TextInputType.datetime,
                style: TextStyle(fontSize: 18),
                decoration: InputDecoration(
                    hintText: '경매 종료 시간', hintStyle: TextStyle(fontSize: 18)),
                onChanged: (value) {
                  endTime = value;
                },
              ),

              // 경매 설명
              TextField(
                style: TextStyle(fontSize: 18),
                maxLines: 10,
                decoration: InputDecoration(
                    hintText: '설명', hintStyle: TextStyle(fontSize: 18)),
                onChanged: (value) {
                  content = value;
                },
              ),

              SizedBox(height: 20),
              // 경매 등록 버튼
              ElevatedButton(
                  onPressed: () {
                    // 게시물을 등록하고 AlertDialog 닫기
                    _saveCommunityData();
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('게시물이 등록되었습니다.',
                              style: TextStyle(fontSize: 16, color: Colors.white)),
                          dismissDirection: DismissDirection.up,
                          duration: Duration(milliseconds: 1500),
                          backgroundColor: Colors.black,
                        )
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: Size(double.infinity, 55),
                      elevation: 5,
                      shape: StadiumBorder()),
                  child: Text(
                    "등록",
                    style: TextStyle(fontSize: 18),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // firestore에 게시글 정보 저장
  void _saveCommunityData() async {
    if (title.isNotEmpty && content.isNotEmpty) {
      if (_pickedFile != null) {
        String photoURL = await uploadImageToStorage(_pickedFile!);
      }

      try {
        await _firestore.collection('AuctionCommunity').add({
          'title': title,
          'content': content,
          'uploaderEmail': uploaderEmail, // 이메일 저장
          'uploaderImageURL': uploaderImageURL, // 프로필 사진 URL 저장
          'uploaderNickname': uploaderNickname, // 닉네임 저장
          'createDate': createDate, // 작성일자 저장
          'views': views, // 조회수 초기값
          'like': like, // 좋아요 횟수 초기값
          'comments': comments, // 댓글 수 초기값
          'photoURL': photoURL, // Firebase Storage에서 받은 URL로 업데이트
          'endTime': endTime, // 경매 종료시간
          'nowPrice': nowPrice // 즉시거래가
        });
        Navigator.pop(context);
      } catch (e) {
        print('데이터 저장 오류: $e');
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('알림'),
            content: Text('모두 입력하세요.'),
            actions: [
              TextButton(
                onPressed: () {
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
}
