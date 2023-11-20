import 'dart:async';
import 'dart:io';
import 'package:capstone/custom_widget.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class AuctionRegisterScreen extends StatefulWidget {
  const AuctionRegisterScreen({super.key, required String boardType});

  @override
  State<AuctionRegisterScreen> createState() => _AuctionRegisterScreenState();
}

class _AuctionRegisterScreenState extends State<AuctionRegisterScreen> {
  final _authentication = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // 유저 정보
  String uploaderUID = ''; // 업로더 uid
  String winningBidderUID = ''; // 낙찰자 uid

  // 경매 정보
  File? _pickedFile; // 사진 파일
  String photoURL = ''; // 경매 상품 사진
  String title = ''; // 제목
  String content = ''; // 설명
  String category = '1'; // 카테고리 초기값 1 = 의류
  int startBid = 0; // 시작가

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: DarkColors.basic,
        title: Text(
            '경매 게시판', style: TextStyle(color: Colors.white, fontSize: 20)),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.close),
          iconSize: 30,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
              children: [
                // 사진 업로드
                _buildAuctionImage(),

                SizedBox(height: 20),

                // 제목
                TextField(
                  maxLength: 30,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                      hintText: '제목',
                      hintStyle: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  onChanged: (value) {
                    title = value;
                  },
                ),

                // 시작가(최소 입찰가)
                TextField(
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                      hintText: '시작가', hintStyle: TextStyle(fontSize: 18)),
                  onChanged: (value) {
                    startBid = int.tryParse(value) ?? 0;
                  },
                ),

                // 설명
                TextField(
                  maxLength: 200,
                  maxLines: 7,
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                      hintText: '설명', hintStyle: TextStyle(fontSize: 18)),
                  onChanged: (value) {
                    content = value;
                  },
                ),

                SizedBox(height: 20),

                // 카테고리
                Container(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width, // DropdownButton의 폭을 화면에 표시될 공간만큼으로 설정
                    child: DropdownButton<String>(
                      value: category,
                      onChanged: (String? newValue) {
                        setState(() {
                          category = newValue!;
                        });
                      },
                      items: <DropdownMenuItem<String>>[
                        DropdownMenuItem<String>(
                          value: '1',
                          child: Text('의류/패션'),
                        ),
                        DropdownMenuItem<String>(
                          value: '2',
                          child: Text('전자제품'),
                        ),
                        DropdownMenuItem<String>(
                          value: '3',
                          child: Text('가전제품'),
                        ),
                        DropdownMenuItem<String>(
                          value: '4',
                          child: Text('기타'),
                        ),
                      ],
                      style: TextStyle(fontSize: 18,color: Colors.black),
                      iconSize: 30,
                      isExpanded: true, // DropdownButton의 폭을 화면에 표시될 공간만큼으로 설정
                      icon: Icon(Icons.arrow_drop_down), // 아이콘 지정
                    ),
                  ),
                ),

                // 경매 등록 버튼
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
                      "등록",
                      style: TextStyle(fontSize: 18),
                    )),
              ]),
        ),
      ),
    );
  }

  //============================================================================

  // Firestore에서 uploaderUID(현재 로그인한 사용자의 UID)를 가져오는 함수
  void getCurrentUser() async {
    final user = _authentication.currentUser;
    if (user != null) {
      setState(() {
        uploaderUID = user.uid;
      });
    }
  }

  // firestore에 경매 정보 저장
  void _saveAuctionData() async {
    if (title.isNotEmpty && content.isNotEmpty) {
      if (_pickedFile != null) {
        Navigator.of(context).pop();
        try {
          // 경매 정보
          String photoURL = await uploadImageToStorage(_pickedFile!);
          int views = 0;
          int like = 0;
          String status = '대기중'; // 경매 상태 : 대기중, 진행중, 낙찰, 경매 실패

          // 시간 정보
          Timestamp createDate = Timestamp.now();
          Timestamp startTime = Timestamp.fromDate(createDate.toDate().add(Duration(minutes: 10)));
          Timestamp endTime = Timestamp.fromDate(startTime.toDate().add(Duration(minutes: 30)));
          int remainingTime = createDate.toDate().difference(startTime.toDate()).inSeconds;

          await _firestore.collection('AuctionCommunity').add({
            // 유저 정보
            'uploaderUID': uploaderUID, // 업로더 uid
            'winningBidderUID': winningBidderUID, // 낙찰자 uid

            // 경매 정보
            'photoURL': photoURL, // 사진
            'title': title, // 제목
            'content': content, // 설명
            'category': category, // 카테고리
            'views': views, // 조회수
            'like': like, // 좋아요
            'startBid': startBid, // 시작가
            'winningBid': startBid, // 낙찰가. 최소 입찰가(초기값은 시작가로)
            'status': status, // 경매 상태(대기중, 진행중, 낙찰, 경매 실패)

            // 시간 정보
            'createDate': createDate, // 경매 등록 시간
            'startTime': startTime, // 경매 시작 시간. 경매 등록 시간 + 10분
            'endTime': endTime, // 경매 종료 시간. 경매 시작 시간 + 30분
            'remainingTime': remainingTime, // 경매 종료까지 "남은 시간"
          });
        } catch (e) {
          print('데이터 저장 오류: $e');
        }
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('알림'),
              content: Text('사진을 업로드해주세요.'),
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
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('알림'),
            content: Text('제목과 내용을 모두 입력하세요.'),
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

  // 경매 등록 확인 AlertDialog 표시
  void showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('등록하기'),
          content: Text('경매를 등록하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                _saveAuctionData();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('경매가 등록되었습니다.',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                    dismissDirection: DismissDirection.up,
                    duration: Duration(milliseconds: 1500),
                    backgroundColor: Colors.black,
                  ),
                );
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 사진을 스토리지에 업로드하는 함수
  Future<String> uploadImageToStorage(File imageFile) async {
    final storageReference = FirebaseStorage.instance.ref().child('images/${Uuid().v4()}');
    await storageReference.putFile(imageFile);
    final photoURL = await storageReference.getDownloadURL();
    return photoURL;
  }

  // 사진 표시 위젯
  Widget _buildAuctionImage() {
    double _imageSize = 150.0;

    return GestureDetector(
      onTap: () async {
        var picker = ImagePicker();
        var image = await picker.pickImage(source: ImageSource.gallery);
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
          width: _imageSize,
          height: _imageSize,
          color: Colors.black12,
          child: Icon(
            Icons.add_photo_alternate_rounded,
            color: Colors.black26,
            size: 100,
          ),
        )
        // 사진 선택 후
            : Container(
          width: _imageSize,
          height: _imageSize,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(File(_pickedFile!.path)),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

