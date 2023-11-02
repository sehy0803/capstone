import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class AuctionRegisterScreen extends StatefulWidget {
  const AuctionRegisterScreen({super.key, required String boardType});

  @override
  State<AuctionRegisterScreen> createState() => _AuctionRegisterScreenState();
}

class _AuctionRegisterScreenState extends State<AuctionRegisterScreen> {
  final _firestore = FirebaseFirestore.instance;

  File? _pickedFile;

  // 유저가 입력한 게시글 정보를 저장할 변수
  String title = '';
  String content = '';
  String endTime = '';
  String nowPrice = '';

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
                    var image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        _pickedFile = File(image.path);
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
                    hintStyle: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
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
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(double.infinity, 55),
                      elevation: 5,
                      shape: StadiumBorder()),
                  child: Text(
                    "경매 올리기",
                    style: TextStyle(fontSize: 18),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
