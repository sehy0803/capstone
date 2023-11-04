import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  String? imageURL;
  String email = '';
  String nickname = '';

  File? _pickedFile;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // 유효성 검사 후 값 저장
  void _tryValidation() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
    }
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

    final user = _authentication.currentUser;

    try {
      if (user != null) {
        if (_pickedFile != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('user_profile/${user.uid}.jpg');
          await storageRef.putFile(_pickedFile!);

          // 이미지 업로드 이후에 이미지 URL을 얻어옵니다.
          final downloadURL = await storageRef.getDownloadURL();

          await user.updatePhotoURL(downloadURL);
          user.reload();

          updatedInfo['photoURL'] = downloadURL;

          // Firestore에 사용자의 이미지 URL 업데이트
          await _firestore.collection('User').doc(user.uid).update({
            'imageURL': downloadURL,
          });
        }

        // Firestore에 사용자의 닉네임 업데이트
        if (nickname.isNotEmpty) {
          await _firestore.collection('User').doc(user.uid).update({
            'nickname': nickname,
          });

          updatedInfo['nickname'] = nickname;
        }
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("프로필 수정 중 오류 발생"),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }

    return updatedInfo; // 업데이트된 정보가 포함된 Map 반환
  }

  // 프로필 이미지를 표시할 위젯
  Widget _buildProfileImage() {
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
          child: SizedBox(
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
                child: Icon(Icons.add, size: 40, color: Colors.black)),
          ),
        ),
      ]);
    }
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
                    Center(child: _buildProfileImage()),
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
                        Form(
                          key: _formKey,
                          child: Expanded(
                            child: // 닉네임 텍스트필드
                                TextFormField(
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
                                    decoration: InputDecoration(
                                      hintText: '닉네임',
                                      hintStyle: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[400]!),
                                    )),
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
                      setState(() {
                        isLoading = true; // 버튼 클릭 시 로딩 상태를 활성화
                      });

                      // 유효성 검사 수행
                      _tryValidation();

                      // 유효성 검사를 통과했을 시
                      if (_formKey.currentState!.validate()) {
                        // 프로필 업데이트 수행
                        final updatedInfo = await _updateProfile();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '변경사항이 저장되었습니다.',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                            margin: EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.height - 120,
                              left: 10,
                              right: 10,
                            ),
                            dismissDirection: DismissDirection.up,
                            duration: Duration(milliseconds: 1500),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.black,
                          ),
                        );
                        Navigator.pop(context);
                      }
                      setState(() {
                        isLoading = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      elevation: 5,
                      shape: StadiumBorder(),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator() // 로딩 중일 때 표시할 위젯
                        : Text(
                            "저장하기",
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}
