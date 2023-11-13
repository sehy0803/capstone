import 'package:flutter/material.dart';

void main() {
  runApp(CategoryScreen());
}

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  // 선택된 페이지를 나타내는 변수
  Widget selectedPage = Container(
    height: 100,
    color: Colors.black,
  );

  // 각 버튼의 선택 상태를 저장하는 변수
  bool isButton1Selected = true; // 초기 상태에서 버튼1 선택
  bool isButton2Selected = false;
  bool isButton3Selected = false;

  // 페이지를 변경하고 버튼 상태를 업데이트하는 함수
  void changePage(Widget page, bool button1, bool button2, bool button3) {
    setState(() {
      selectedPage = page;
      isButton1Selected = button1;
      isButton2Selected = button2;
      isButton3Selected = button3;
    });
  }
  String selectedCategory = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            '카테고리',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.black),
          ),
        ),
        body: Row(
          children: [
            Container(
              width: 110,
              height: 655,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.black12,
              ),
              child: Column(
                children: [
                  buildCategoryButton('의류'),
                  buildCategoryButton('신발'),
                  buildCategoryButton('가방'),
                  buildCategoryButton('디지털'),
                  buildCategoryButton('쥬얼리'),
                  buildCategoryButton('뷰티'),
                  buildCategoryButton('가구'),
                  buildCategoryButton('기타'),
                ],
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedCategory,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  if (selectedCategory == '디지털')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildSubCategoryButton('서브 카테고리 1'),
                        buildSubCategoryButton('서브 카테고리 2'),
                        buildSubCategoryButton('서브 카테고리 3'),
                        buildSubCategoryButton('서브 카테고리 4'),
                        buildSubCategoryButton('서브 카테고리 5'),
                      ],
                    ),
                ],
          title: Text('카테고리', style: TextStyle(color: Colors.black, fontSize: 20)),
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: CategoryButtons(
                  isButton1Selected: isButton1Selected,
                  isButton2Selected: isButton2Selected,
                  isButton3Selected: isButton3Selected,
                  changePage: changePage,
                ),
              ),
              selectedPage, // 선택된 페이지를 여기에 표시
            ],
          ),
        ),
    );
  }
}

// ========================================== 커스텀 위젯 ==========================================

// 카테고리 버튼
class CategoryButtons extends StatelessWidget {
  final bool isButton1Selected;
  final bool isButton2Selected;
  final bool isButton3Selected;
  final Function(Widget, bool, bool, bool) changePage;

  CategoryButtons({
    required this.isButton1Selected,
    required this.isButton2Selected,
    required this.isButton3Selected,
    required this.changePage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        buildCategoryButton("버튼1", isButton1Selected),
        buildCategoryButton("버튼2", isButton2Selected),
        buildCategoryButton("버튼3", isButton3Selected),
      ],
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(onPressed: () {}, icon: Icon(Icons.home)),
              IconButton(onPressed: () {}, icon: Icon(Icons.launch)),
              IconButton(onPressed: () {}, icon: Icon(Icons.chat)),
              IconButton(onPressed: () {}, icon: Icon(Icons.favorite)),
              IconButton(onPressed: () {}, icon: Icon(Icons.person)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCategoryButton(String category) {
    return Container(
      width: double.infinity,
      child: TextButton(
        style: ButtonStyle(
          alignment: Alignment.centerLeft,
          backgroundColor: selectedCategory == category && category == '디지털'
              ? MaterialStateProperty.all(Colors.white)
              : null,
        ),
        child: Text(
          category,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal, color: Colors.black),
        ),
        onPressed: () {
          setState(() {
            selectedCategory = category;
          });
        },
      ),
    );
  }

  Widget buildSubCategoryButton(String subCategory) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 16.0, top: 8.0), // Adjust padding as needed
      child: TextButton(
        style: ButtonStyle(
          alignment: Alignment.centerLeft,
          backgroundColor: MaterialStateProperty.all(Colors.white),
  Widget buildCategoryButton(String text, bool isSelected) {
    return TextButton(
      onPressed: () {
        if (text == "버튼1") {
          changePage(Container(
            height: 100,
            color: Colors.black,
          ), true, false, false);
        } else if (text == "버튼2") {
          changePage(Container(
            height: 100,
            color: Colors.black45,
          ), false, true, false);
        } else if (text == "버튼3") {
          changePage(Container(
            height: 100,
            color: Colors.black26,
          ), false, false, true);
        }
      },
      child: Text(text, style: TextStyle(
        fontSize: 16, fontWeight: FontWeight.normal,
        color: isSelected ? Colors.black : Colors.grey,
      )),
      style: TextButton.styleFrom(
        padding: EdgeInsets.all(15),
        backgroundColor: isSelected ? Colors.black12 : Colors.transparent, // 선택된 버튼의 배경색
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0)
        ),
        child: Text(
          subCategory,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal, color: Colors.black),
        ),
        onPressed: () {
          // Handle subcategory button press
        },
      ),
    );
  }
}
