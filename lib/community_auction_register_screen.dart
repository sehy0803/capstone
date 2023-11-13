import 'dart:io';
import 'package:capstone/community_user_register_screen.dart';
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
  File? _pickedFile;

  // 게시글 정보를 저장할 변수
  String title = ''; // 제목
  String content = ''; // 내용
  String uploaderUID = ''; // 업로더 uid
  String uploaderEmail = ''; // 업로더 이메일
  String uploaderImageURL = ''; // 업로더 프로필 사진 URL
  String uploaderNickname = ''; // 업로더 닉네임
  int views = 0; // 조회수
  int like = 0; // 좋아요 횟수
  int comments = 0; // 댓글 수
  String photoURL = ''; // 경매 상품 사진
  // 경매 정보를 저장할 변수
  int startBid = 0; // 시작가
  int winningBid = 0; // 낙찰가
  String winningBidder = ''; // 낙찰자
  String winningBidderUID = ''; // 낙찰자 uid
  String status = '진행중'; // 경매 상태 : 진행중, 낙찰, 경매 실패
  Timestamp createDate = Timestamp.now(); // 글을 올린 날짜와 시간
  Timestamp endTime = Timestamp.fromDate(
      DateTime.now().add(Duration(minutes: 1)));
  String selectedValue = '1'; // 카테고리 처음 값 1 = 의류

  // 경매 종료까지 남은 시간 : createDate + 1분

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
                // 상품 사진 업로드
                _buildAuctionImage(),

                SizedBox(height: 20),

                // 경매 제목
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

                // 경매 시작가(최소 입찰가)
                TextField(
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                      hintText: '시작가', hintStyle: TextStyle(fontSize: 18)),
                  onChanged: (value) {
                    startBid = int.tryParse(value) ?? 0;
                  },
                ),

                // 경매 설명
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

                //카테고리 항목들
                Container(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width, // DropdownButton의 폭을 화면에 표시될 공간만큼으로 설정
                    child: DropdownButton<String>(
                      value: selectedValue,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedValue = newValue!;
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

  // firestore에 경매 정보 저장
  void _saveAuctionData() async {
    if (title.isNotEmpty && content.isNotEmpty) {
      if (_pickedFile != null) {
        Navigator.of(context).pop();
        try {
          String photoURL = await uploadImageToStorage(_pickedFile!);
          await _firestore.collection('AuctionCommunity').add({
            'title': title, // 제목
            'content': content, // 상품 설명
            'uploaderUID': uploaderUID, // 업로더 uid
            'uploaderEmail': uploaderEmail, // 업로더 이메일
            'uploaderImageURL': uploaderImageURL, // 프로필 사진 URL
            'uploaderNickname': uploaderNickname, // 업로더 닉네임
            'createDate': createDate, // 게시글 작성일
            'views': views, // 조회수 초기값
            'like': like, // 좋아요 횟수 초기값
            'comments': comments, // 댓글 수 초기값
            'photoURL': photoURL, // Firebase Storage에서 받은 URL로 업데이트
            // ==========================================================
            'startBid': startBid, // 시작가
            'winningBid': startBid, // 낙찰가. 최소 입찰가(초기값은 시작가로)
            'winningBidder': winningBidder, // 낙찰자 닉네임
            'winningBidderUID': winningBidderUID, // 낙찰자 uid
            'status': status,
            'endTime': endTime, // 경매 종료까지 남은 시간
            'selectedValue': selectedValue, // 카테고리 값
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

  // 상품 사진을 스토리지에 업로드하는 함수
  Future<String> uploadImageToStorage(File imageFile) async {
    try {
      final storageReference = FirebaseStorage.instance.ref().child(
          'images/${Uuid().v4()}');
      await storageReference.putFile(imageFile);
      final photoURL = await storageReference.getDownloadURL();
      return photoURL;
    } catch (e) {
      print('이미지 업로드 오류: $e');
      return '';
    }
  }

  // Firestore에서 업로더의 정보를 가져오는 함수
  void getCurrentUser() async {
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        final userDocument =
        await _firestore.collection('User').doc(user.uid).get();
        if (userDocument.exists) {
          uploaderUID = user.uid;
          uploaderEmail = userDocument['email'];
          uploaderImageURL = userDocument['imageURL'];
          uploaderNickname = userDocument['nickname'];
        }
      }
    } catch (e) {
      print('업로더 정보 가져오기 오류: $e');
    }
  }

  // 상품 사진을 표시하는 함수
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

