import 'dart:async';
import 'dart:io';
import 'package:capstone/community_auction_detail_screen.dart';
import 'package:capstone/custom_widget.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class EditAuctionScreen extends StatefulWidget {
  final String documentId;
  EditAuctionScreen({required this.documentId});

  @override
  State<EditAuctionScreen> createState() => _EditAuctionScreenState();
}

class _EditAuctionScreenState extends State<EditAuctionScreen> {
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
  late Timestamp createDate; // 게시글 작성일 = 경매 시작 시간
  late Timestamp endTime;
  String category = '1'; // 카테고리 초기값 1 = 의류

  // 남은 시간
  int remainingTime = 0;

  late Future<void> _fetchAuctionDataFuture;

  // Firestore에서 해당 documentId의 데이터를 가져오는 함수
  Future<void> _fetchAuctionData() async {
    try {
      var documentSnapshot = await _firestore
          .collection('AuctionCommunity')
          .doc(widget.documentId)
          .get();

      if (documentSnapshot.exists) {
        var data = documentSnapshot.data();
        if (data != null) {
          photoURL = data['photoURL'] ?? '';
          title = data['title'] ?? '';
          startBid = data['startBid'] ?? 0;
          content = data['content'] ?? '';
          category = data['category'] ?? '';

          uploaderUID = data['uploaderUID'] ?? '';
          uploaderEmail = data['uploaderEmail'] ?? '';
          uploaderImageURL = data['uploaderImageURL'] ?? '';
          uploaderNickname = data['uploaderNickname'] ?? '';
          views = data['views'] ?? 0;
          like = data['like'] ?? 0;
          comments = data['comments'] ?? 0;
          createDate = data['createDate'] ?? 0;

          winningBid = data['winningBid'] ?? 0;
          winningBidder = data['winningBidder'] ?? '';
          winningBidderUID = data['winningBidderUID'] ?? '';
          status = data['status'] ?? '';
          endTime = data['endTime'] ?? 0;

          // 남은 시간
          remainingTime = data['remainingTime'] ?? 0;
        }
      }
    } catch (e) {
      print("데이터 가져오기 오류 : $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAuctionDataFuture = _fetchAuctionData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: DarkColors.basic,
        title: Text(
            '경매 수정', style: TextStyle(color: Colors.white, fontSize: 20)),
        leading: IconButton(
          onPressed: () {
            showCloseConfirmationDialog(context);
          },
          icon: Icon(Icons.close),
          iconSize: 30,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: FutureBuilder<void>(
              future: _fetchAuctionDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('오류: ${snapshot.error}');
                }

                return Column(
                    children: [
                      // 상품 사진 업로드
                      _buildAuctionImage(),

                      SizedBox(height: 20),

                      // 경매 제목
                      TextField(
                        // 가져온 데이터를 기본값으로 설정
                        controller: TextEditingController(text: title),
                        maxLength: 30,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                            hintText: title,
                            hintStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        onChanged: (value) {
                          title = value;
                        },
                      ),

                      // 경매 시작가(최소 입찰가)
                      TextField(
                        // 가져온 데이터를 기본값으로 설정
                        controller: TextEditingController(text: startBid.toString()),
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                            hintText: '$startBid',
                            hintStyle: TextStyle(fontSize: 18)),
                        onChanged: (value) {
                          startBid = int.tryParse(value) ?? 0;
                        },
                      ),

                      // 경매 설명
                      TextField(
                        // 가져온 데이터를 기본값으로 설정
                        controller: TextEditingController(text: content),
                        maxLength: 200,
                        maxLines: 7,
                        style: TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                            hintText: content,
                            hintStyle: TextStyle(fontSize: 18)),
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
                          )),
                    ]);

              }
          ),
        ),
      ),
    );
  }

  //============================================================================

  // firestore에 수정한 정보를 업데이트
  void _updateEditAuctionData() async {
    if (title.isNotEmpty && content.isNotEmpty) {
      try {
        String updatedPhotoURL = photoURL;
        if (_pickedFile != null) {
          updatedPhotoURL = await uploadImageToStorage(_pickedFile!);
        }

        await _firestore.collection('AuctionCommunity').doc(widget.documentId).update({
          'photoURL': updatedPhotoURL,
          'title': title,
          'content': content,
          'startBid': startBid,
          'winningBid': startBid,
          'category': category,
        });

      } catch (e) {
        print('데이터 업데이트 오류: $e');
      }
    }
  }

  // 경매 수정 확인 AlertDialog 표시
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
                _updateEditAuctionData();
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

  // 경매 수정 취소 확인 AlertDialog 표시
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
        // 기본 아이콘 또는 Firestore에서 가져온 이미지 표시
        child: _pickedFile == null
            ? (photoURL.isNotEmpty
            ? Container(
          width: _imageSize,
          height: _imageSize,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(photoURL),
              fit: BoxFit.cover,
            ),
          ),
        )
            : Container(
          width: _imageSize,
          height: _imageSize,
          color: Colors.black12,
          child: Icon(
            Icons.add_photo_alternate_rounded,
            color: Colors.black26,
            size: 100,
          ),
        ))
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