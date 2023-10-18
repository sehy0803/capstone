// import 'package:firebase_core/firebase_core.dart'; // 파이어베이스
import 'package:capstone/terms_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MaterialApp(
    home: AuctionRegistScreen(),
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: [
      const Locale('en', 'US'),
      const Locale('ko', 'KR'),
      // Add other supported locales as needed.
    ],
  ));
}



class AuctionRegistScreen extends StatefulWidget {
  const AuctionRegistScreen({Key? key}) : super(key: key);

  @override
  _AuctionRegistScreenState createState() => _AuctionRegistScreenState();
}

class _AuctionRegistScreenState extends State<AuctionRegistScreen> {
  File? userImage;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String formattedDate = '날짜를 선택해주세요';
  String formattedTime = '시간을 선택해주세요';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '경매 등록',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
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
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                // 1. 사진
                ImageUploadWidget(
                  userImage: userImage,
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
                Line(),

                // 2. 카테고리
                CategoryWidget(),
                Line(),

                // 3. 상품명
                ProductName(),
                Line(),

                // 4. 즉시낙찰가
                StartAndNowPrice(),
                Line(),

                // 5. 경매 종료시간
                AuctionClosingTime(
                  initialDate: selectedDate,
                  initialTime: selectedTime,
                  onDateTimeSelected: (date, time) {
                    setState(() {
                      selectedDate = date;
                      selectedTime = time;
                      formattedDate = DateFormat('yyyy-MM-dd').format(date);
                      formattedTime = DateFormat('HH:mm').format(
                          DateTime(0, 0, 0, time.hour, time.minute));
                    });
                  },
                ),
                Line(),

                // 6. 설명
                ProductInfo(),


              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          height: 60,
          child: ElevatedButton(
            onPressed: () {},
            child: Text("등록하기",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.lightBlue),
            ),
          ),
        ),
      ),
    );
  }
}



// ========================================== 커스텀 위젯 ==========================================

// 1. 사진
class ImageUploadWidget extends StatelessWidget {
  final File? userImage;
  final Function()? onImageUpload;

  ImageUploadWidget({required this.userImage, required this.onImageUpload});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('1. 사진', style: TextStyle(fontSize: 18)),
        Center(
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
              OutlinedButton(
                onPressed: onImageUpload,
                child: Text( "사진 업로드",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xffbbbbbb)),
                  minimumSize: MaterialStateProperty.all(Size(150, 40)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 2. 카테고리
enum Category { clothes, digital, jewelry, furniture, etc }

class CategoryWidget extends StatefulWidget {
  const CategoryWidget({Key? key}) : super(key: key);

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  // 처음에는 의류가 선택되어 있도록 clothes 초기화 -> groupValue에 들어갈 값!
  Category? _category = Category.clothes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('2. 카테고리', style: TextStyle(fontSize: 18)),
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

// 3. 상품명
class ProductName extends StatelessWidget {
  const ProductName({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('3. 상품명', style: TextStyle(fontSize: 18)),
        TextField(
          decoration: InputDecoration(
            hintText: '상품명을 입력하세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
          ),
          keyboardType: TextInputType.text,
          maxLength: 20,
        ),
      ],
    );
  }
}

// 4. 즉시낙찰가
class StartAndNowPrice extends StatelessWidget {
  const StartAndNowPrice({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('4. 즉시낙찰가', style: TextStyle(fontSize: 18)),
        TextField(
          decoration: InputDecoration(
            hintText: '즉시낙찰가를 입력하세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
          ),
          keyboardType: TextInputType.multiline,
          maxLines: null,
          maxLength: 10,
        )
      ],
    );
  }
}

// 5. 경매 종료시간
class AuctionClosingTime extends StatefulWidget {
  final DateTime initialDate;
  final TimeOfDay initialTime;
  final Function(DateTime, TimeOfDay) onDateTimeSelected;

  AuctionClosingTime({
    required this.initialDate,
    required this.initialTime,
    required this.onDateTimeSelected,
  });

  @override
  _AuctionClosingTimeState createState() => _AuctionClosingTimeState();
}

class _AuctionClosingTimeState extends State<AuctionClosingTime> {
  late DateTime selectedDate = DateTime.now();
  late TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    selectedTime = widget.initialTime;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('5. 경매 종료시간', style: TextStyle(fontSize: 18)),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text('날짜 선택'),
            ),
            SizedBox(width: 20),
            Text('날짜 : ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
          ],
        ),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: Text('시간 선택'),
            ),
            SizedBox(width: 20),
            Text('시간 : ${selectedTime.format(context)}'),
          ],
        ),
      ],
    );
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        widget.onDateTimeSelected(selectedDate, selectedTime);
      });
    }
  }

  void _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        widget.onDateTimeSelected(selectedDate, selectedTime);
      });
    }
  }
}



// 6. 설명
class ProductInfo extends StatelessWidget {
  const ProductInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('6. 설명', style: TextStyle(fontSize: 18)),
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
        )
      ],
    );
  }
}
