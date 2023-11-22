import 'dart:io';
import 'package:capstone/custom_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileEditScreen extends StatefulWidget {
  final String userID; // 유저 uid

  ProfileEditScreen({
    required this.userID,
  });

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _profileFormKey = GlobalKey<FormState>();

  TextEditingController nicknameController = TextEditingController();

  bool isProfileChanged = false;

  File? _pickedFile;
  String nickname = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 빈 곳 터치시 키패드 사라짐
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          appBar: AppBar(
            centerTitle: true,
            title: Text('프로필 수정', style: TextStyle(color: Colors.black, fontSize: 20)),
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
          body: StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection('User').doc(widget.userID).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {return Center(child: CircularProgressIndicator());}
                if (snapshot.hasError) {return Center(child: Text('데이터를 불러올 수 없습니다.'));}

                var userData = snapshot.data!.data() as Map<String, dynamic>;

                String email = userData['email'] as String;
                String imageURL = userData['imageURL'] as String;
                String nickname = userData['nickname'] as String;

                return Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          // 유저 프로필 사진
                          Center(child: _buildProfileImage(imageURL)),
                          SizedBox(height: 30),

                          // 이메일 정보
                          Row(
                            children: [
                              Text('이메일', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 30),
                              Text(email, style: TextStyle(fontSize: 16, color: Colors.grey)),
                            ],
                          ),

                          // 수정할 값을 입력받을 텍스트필드
                          Row(
                            children: [
                              Text("닉네임", style: TextStyle(fontSize: 16)),
                              SizedBox(width: 30),
                              Form(
                                key: _profileFormKey,
                                child: Expanded(
                                  child: // 닉네임 텍스트필드
                                  TextFormField(
                                    controller: nicknameController,
                                    decoration: InputDecoration(
                                        hintText: nickname,
                                        hintStyle: TextStyle(fontSize: 16, color: Colors.grey)),
                                      validator: (value) {
                                        if (value!.length < 2) {
                                          return '닉네임을 2글자 이상 입력해주세요.';
                                        }
                                        if (RegExp(r'[!@#\$%^&*]')
                                            .hasMatch(value)) {
                                          return '닉네임에 특수문자를 포함할 수 없습니다.';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) {
                                        nickname = value!;
                                      },
                                      onChanged: (value) {
                                        nickname = value;
                                      },
                                  )
                                ),
                              )
                            ],
                          ),
                        ],
                      ),

                      // 프로필 수정 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () async {
                            final updatedInfo = await _updateProfile();
                            if(updatedInfo.isNotEmpty){
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('변경 사항이 저장되었습니다.',
                                        style: TextStyle(fontSize: 16, color: Colors.white)),
                                    dismissDirection: DismissDirection.up,
                                    duration: Duration(milliseconds: 1500),
                                    backgroundColor: Colors.black,
                                  )
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('변경된 내용이 없습니다.',
                                        style: TextStyle(fontSize: 16, color: Colors.white)),
                                    dismissDirection: DismissDirection.up,
                                    duration: Duration(milliseconds: 1500),
                                    backgroundColor: Colors.black,
                                  )
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DarkColors.basic,
                            elevation: 5,
                            shape: StadiumBorder(),
                          ),
                          child: Text("저장하기", style: TextStyle(fontSize: 18),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }
          )
      ),
    );
  }
  //============================================================================

  // 유효성 검사 후 값 저장
  void _tryValidation() {
    final isValid = _profileFormKey.currentState!.validate();
    if (isValid) {
      _profileFormKey.currentState!.save();
    }
  }

  // firestore에 게시글 정보 저장
  Future<Map<String, dynamic>> _updateProfile() async {
    Map<String, dynamic> updatedInfo = {};
    String newNickname = nicknameController.text.trim();

    if (_pickedFile != null) {
      // 프로필 사진이 선택된 경우, 저장소에 업로드하고 URL을 얻어옴
      final storageRef = _storage.ref().child(
          'user_profile/${widget.userID}.jpg');
      await storageRef.putFile(_pickedFile!);
      final downloadURL = await storageRef.getDownloadURL();

      // 프로필 사진 URL을 Firestore에 저장
      await _firestore.collection('User').doc(widget.userID).update({
        'imageURL': downloadURL,
      });

      updatedInfo['imageURL'] = downloadURL;
    }
    if (newNickname.isNotEmpty) {
      _tryValidation();
      if(_profileFormKey.currentState!.validate()){
        // 닉네임을 Firestore에 저장
        await _firestore.collection('User').doc(widget.userID).update({
          'nickname': newNickname,
        });
        updatedInfo['nickname'] = newNickname;
      }
    }
    return updatedInfo;
  }

  // 프로필 이미지를 표시할 위젯
  Widget _buildProfileImage(String imageURL) {
    double _imageSize = 180.0;

    // 기본 프로필 사진이 아닐 경우
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
    }
    // 기본 프로필 사진일 경우
    else {
      // 기본 아이콘 표시
      return Stack(children: [
        Container(
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
                  ? Container(
                width: _imageSize,
                height: _imageSize,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/defaultImage.png', // 기본 이미지 파일 경로
                    width: _imageSize,
                    height: _imageSize,
                    fit: BoxFit.cover,
                  ),
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
        ),
        // '+' 아이콘
        Center(
          child: Container(
            alignment: Alignment.bottomRight,
            width: 180,
            height: 180,
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
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0, 2),
                        blurRadius: 4.0,
                      ),
                    ],
                  ),
                  child: Icon(Icons.camera_alt, size: 30, color: Colors.black),
                )
            ),
          ),
        ),
      ]);
    }
  }

}
