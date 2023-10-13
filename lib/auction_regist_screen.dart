import 'package:capstone/terms_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 이미지 피커
import 'dart:io'; // 파일을 유용하게 다룰 수 있는 패키지

void main() {
  runApp(const AuctionRegistScreen());
}

class AuctionRegistScreen extends StatefulWidget {
  const AuctionRegistScreen({Key? key}) : super(key: key);

  @override
  _AuctionRegistScreenState createState() => _AuctionRegistScreenState();
}

class _AuctionRegistScreenState extends State<AuctionRegistScreen> {
  File? userImage; // 이미지를 저장할 변수

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            AuctionRegistAppBar(),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Line(),
                  Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('1. 사진', style: TextStyle(fontSize: 20)),
                          SizedBox(height: 20),
                          ImageUploadWidget(
                            userImage: userImage, // 이미지 파일을 전달
                            onImageUpload: () async {
                              var picker = ImagePicker();
                              var image = await picker.pickImage(source: ImageSource.gallery);
                              if (image != null) {
                                setState(() {
                                  userImage = File(image.path);
                                });
                              }
                            },
                          ),
                          SizedBox(height: 20),
                          Line(),
                          SizedBox(height: 20),
                          Text('2. 카테고리', style: TextStyle(fontSize: 20)),
                          RadioButtonWidget(), // 드롭다운으로 대체할 것
                          SizedBox(height: 20),
                          Line(),
                          SizedBox(height: 20),
                          Text('3. 상품명', style: TextStyle(fontSize: 20)),
                          SizedBox(height: 10),
                          ProductNameTextField(),
                          SizedBox(height: 20),
                          Line(),
                          SizedBox(height: 20),
                          Text('4. 시작가/즉시거래가', style: TextStyle(fontSize: 20)),
                          SizedBox(height: 20),
                          StartPriceTextField(),
                          NowPriceTextField(),
                          SizedBox(height: 20),
                          Line(),
                          SizedBox(height: 20),
                          Text('5. 경매일', style: TextStyle(fontSize: 20)),
                          SizedBox(height: 20),
                          Line(),
                          SizedBox(height: 20),
                          Text('6. 입금받을 계좌', style: TextStyle(fontSize: 20)),
                          SizedBox(height: 20),
                          Line(),
                          SizedBox(height: 20),
                          Text('7. 설명', style: TextStyle(fontSize: 20)),
                          SizedBox(height: 20),
                          TextField(
                            decoration: InputDecoration(
                              hintText: '상품 설명을 입력하세요',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              ),
                            ),
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            maxLength: 300,
                          ),
                          Line(),
                          SizedBox(height: 20),




                        ],
                      )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ======================================================= 커스텀 위젯 =======================================================

// 경매 등록 앱바
class AuctionRegistAppBar extends StatelessWidget {
  const AuctionRegistAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text(
        "경매 등록",
        style: TextStyle(color: Colors.black, fontSize: 25),
      ),
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back_ios),
        iconSize: 30,
        color: Colors.black,
      ),
      backgroundColor: Colors.white,
      floating: true,
      pinned: false,
    );
  }
}


// 카테고리 선택 라디오위젯
enum Category { clothes, digital, jewelry, furniture, etc }

class RadioButtonWidget extends StatefulWidget {
  const RadioButtonWidget({Key? key}) : super(key: key);

  @override
  State<RadioButtonWidget> createState() => _RadioButtonWidgetState();
}

class _RadioButtonWidgetState extends State<RadioButtonWidget> {
  // 처음에는 사과가 선택되어 있도록 clothes 초기화 -> groupValue에 들어갈 값!
  Category? _category = Category.clothes;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          //color: Colors.blue,
          height: 40,
          child: ListTile(
            title: const Text('의류'),
            leading: Radio<Category>(
              value: Category.clothes,
              groupValue: _category,
              onChanged: (Category? value) {
                setState(() {
                  _category = value;
                });
              },
            ),
          ),
        ),
        Container(
          //color: Colors.teal,
          height: 40,
          child: ListTile(
            title: const Text('디지털'),
            leading: Radio<Category>(
              value: Category.digital,
              groupValue: _category,
              onChanged: (Category? value) {
                setState(() {
                  _category = value;
                });
              },
            ),
          ),
        ),
        Container(
          //color: Colors.red,
          height: 40,
          child: ListTile(
            title: const Text('주얼리'),
            leading: Radio<Category>(
              value: Category.jewelry,
              groupValue: _category,
              onChanged: (Category? value) {
                setState(() {
                  _category = value;
                });
              },
            ),
          ),
        ),
        Container(
          //color: Colors.amber,
          height: 40,
          child: ListTile(
            title: const Text('가구'),
            leading: Radio<Category>(
              value: Category.furniture,
              groupValue: _category,
              onChanged: (Category? value) {
                setState(() {
                  _category = value;
                });
              },
            ),
          ),
        ),
        Container(
          //color: Colors.amber,
          height: 40,
          child: ListTile(
            title: const Text('기타'),
            leading: Radio<Category>(
              value: Category.etc,
              groupValue: _category,
              onChanged: (Category? value) {
                setState(() {
                  _category = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

// 상품명 텍스트필드
class ProductNameTextField extends StatelessWidget {
  const ProductNameTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      child: TextField(
        decoration: InputDecoration(
          hintText: '상품명을 입력하세요',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
        ),
        keyboardType: TextInputType.text,
        maxLength: 20,
      ),
    );
  }
}

// 시작가 텍스트필드
class StartPriceTextField extends StatelessWidget {
  const StartPriceTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: '시작가를 입력하세요',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
      ),
      keyboardType: TextInputType.multiline,
      maxLines: null,
      maxLength: 10,
    );
  }
}

// 즉시 거래가 텍스트필드
class NowPriceTextField extends StatelessWidget {
  const NowPriceTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: '즉시거래가를 입력하세요',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
      ),
      keyboardType: TextInputType.multiline,
      maxLines: null,
      maxLength: 10,
    );
  }
}


// 상품 이미지 업로드 버튼, 이미지 표시
class ImageUploadWidget extends StatelessWidget {
  final File? userImage;
  final Function()? onImageUpload;

  ImageUploadWidget({required this.userImage, required this.onImageUpload});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[200], // 빈 이미지 컨테이너의 배경색
            ),
            child: userImage != null
                ? ClipRRect( // userImage 변수가 null이 아닐 시(=이미지가 선택되었음) 다음 코드를 실행
              // borderRadius: BorderRadius.circular(50), // 이미지 둥글게
              child: Image.file(
                userImage!,
                width: 100,
                height: 100,
                fit: BoxFit.cover, // 이미지를 컨테이너에 맞게 늘립니다.
              ),
            )
                : Center(
              child: Icon(
                Icons.photo,
                size: 50, // 빈 이미지 컨테이너에 표시되는 아이콘 크기
                color: Colors.grey, // 빈 이미지 컨테이너 아이콘의 색상
              ),
            ),
          ),
          ElevatedButton(
            onPressed: onImageUpload,
            child: Text(
              "사진 업로드",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.grey),
              minimumSize: MaterialStateProperty.all(Size(150, 40)),
            ),
          ),
        ],
      ),
    );
  }
}








