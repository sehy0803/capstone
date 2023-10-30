import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _authentication = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  TextEditingController nicknameController = TextEditingController();

  String? imageURL;
  String email = '';
  String nickname = '';

  File? _pickedFile;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // 사용자의 정보를 Firebase 및 Firestore에서 가져오는 함수
  void _fetchUserData() async {
    final user = _authentication.currentUser;
    if (user != null) {
      imageURL = user.photoURL ?? '';
      email = user.email ?? '';

      final userDoc = await _firestore.collection('User').doc(user.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          nickname = userData['nickname'];
        });
      }
    }
  }

  // 프로필 업데이트 함수
  Future<Map<String, dynamic>> _updateProfile() async {
    Map<String, dynamic> updatedInfo = {}; // 업데이트된 정보를 담을 Map

    String newNickname = nicknameController.text.trim();
    final user = _authentication.currentUser;

    try {
      if (user != null) {
        // Authentication에 사용자의 프로필 사진 업데이트
        if (_pickedFile != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('user_profile/${user.uid}.jpg');
          await storageRef.putFile(_pickedFile!);
          final downloadURL = await storageRef.getDownloadURL();

          await user.updatePhotoURL(downloadURL);
          user.reload();

          updatedInfo['photoURL'] = downloadURL;
        }

        // Firestore에 사용자의 닉네임 업데이트
        if (newNickname.isNotEmpty) {
          await _firestore.collection('User').doc(user.uid).update({
            'nickname': newNickname,
          });

          updatedInfo['nickname'] = newNickname;
        }

      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("프로필 수정 중 오류 발생"),
        ),
      );
    }

    return updatedInfo; // 업데이트된 정보가 포함된 Map 반환
  }


  // 프로필 이미지를 표시할 위젯
  Widget _buildProfileImage() {
    final _imageSize = MediaQuery.of(context).size.width / 2;

    if (imageURL != null && imageURL!.isNotEmpty) {
      // Firebase Storage에서 이미지를 가져와 표시
      return Container(
        constraints: BoxConstraints(
          minHeight: _imageSize,
          minWidth: _imageSize,
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
            child: _pickedFile == null
                ? ClipOval(
              child: Image.network(
                imageURL!,
                width: _imageSize,
                height: _imageSize,
                fit: BoxFit.cover,
              ),
            )
                : Container(
              width: _imageSize,
              height: _imageSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: FileImage(File(_pickedFile!.path)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      // 기본 아이콘 표시
      return Container(
        constraints: BoxConstraints(
          minHeight: _imageSize,
          minWidth: _imageSize,
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
            child: _pickedFile == null
                ? Icon(
              Icons.account_circle,
              size: _imageSize,
            )
                : Container(
              width: _imageSize,
              height: _imageSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: FileImage(File(_pickedFile!.path)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: Text('프로필 수정',
              style: TextStyle(color: Colors.black, fontSize: 20)),
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.close),
            iconSize: 30,
            color: Colors.black,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  // 유저 프로필 사진
                  _buildProfileImage(),
                  SizedBox(height: 30),
                  // 이메일 정보
                  Row(
                    children: [
                      Text('이메일', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 30),
                      Text(email,
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),

                  // 수정할 값을 입력받을 텍스트필드
                  Row(
                    children: [
                      Text("닉네임", style: TextStyle(fontSize: 16)),
                      SizedBox(width: 30),
                      Expanded(
                        child: TextField(
                          controller: nicknameController,
                          decoration: InputDecoration(
                              hintText: '변경할 닉네임',
                              hintStyle: TextStyle(color: Colors.grey)),
                        ),
                      )
                    ],
                  ),
                ],
              ),

              // 프로필 수정 버튼
              ElevatedButton(
                onPressed: () async {
                  final updatedInfo = await _updateProfile(); // 프로필 업데이트
                  if (updatedInfo['nickname'] != null || updatedInfo['photoURL'] != null) {
                    Navigator.pop(context, updatedInfo); // Map 반환
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("변경된 내용이 없습니다."),
                      ),
                    );
                  }
                },
                child: Text('저장하기'),
              )

            ],
          ),
        ));
  }
}
