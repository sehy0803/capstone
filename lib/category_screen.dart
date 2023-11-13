import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _firestore = FirebaseFirestore.instance;

  late Widget selectedPage;

  bool isButton1Selected = true;
  bool isButton2Selected = false;
  bool isButton3Selected = false;
  bool isButton4Selected = false;

  void changePage(Widget page, bool button1, bool button2, bool button3, bool button4) {
    setState(() {
      selectedPage = page;
      isButton1Selected = button1;
      isButton2Selected = button2;
      isButton3Selected = button3;
      isButton4Selected = button4;
    });
  }

  @override
  void initState() {
    super.initState();
    selectedPage = Container(
      height: 100,
      color: Colors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
                isButton4Selected: isButton4Selected,
                changePage: changePage,
              ),
            ),

            //fireStore의 AuctionCommunity에 접근함
            StreamBuilder(
              stream: _firestore.collection('AuctionCommunity').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var documents = snapshot.data?.docs;

                  // 선택한 카테고리를 기준으로 경매 필터링함
                  var filteredAuctions = documents
                      ?.where((document) {
                    String category = document?['selectedValue'];
                    return (category == "1" && isButton1Selected) ||
                        (category == "2" && isButton2Selected) ||
                        (category == "3" && isButton3Selected) ||
                        (category == "4" && isButton4Selected);
                  }).toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: filteredAuctions?.length,
                    itemBuilder: (context, index) {
                      var document = filteredAuctions?[index];
                      return ListTile(
                        title: Text(document?['title']),
                        subtitle: Text(document?['content']),
                        onTap: () {
                          String category = document?['selectedValue'];
                          // 이 부분에 카테고리 화면에 나와있는 경매들을 클릭했을 때 어떻게 실행시킬지 구현
                        },
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
            selectedPage,
          ],
        ),
      ),
    );
  }
}

// Rest of

// ========================================== 커스텀 위젯 ==========================================

// 카테고리 버튼
class CategoryButtons extends StatelessWidget {
  final bool isButton1Selected;
  final bool isButton2Selected;
  final bool isButton3Selected;
  final bool isButton4Selected;
  final Function(Widget, bool, bool, bool, bool) changePage;

  CategoryButtons({
    required this.isButton1Selected,
    required this.isButton2Selected,
    required this.isButton3Selected,
    required this.isButton4Selected,
    required this.changePage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        buildCategoryButton("의류/패션", isButton1Selected),
        buildCategoryButton("전자제품", isButton2Selected),
        buildCategoryButton("가전제품", isButton3Selected),
        buildCategoryButton("기타", isButton4Selected),
      ],
    );
  }

  Widget buildCategoryButton(String text, bool isSelected) {
    return TextButton(
      onPressed: () {

        // changePage 함수를 호출하여 페이지를 변경
        if (text == "의류/패션") {
          changePage(
            Container(
              height: 50,
              color: Colors.black,
            ),
            true,
            false,
            false,
            false,
          );
        } else if (text == "전자제품") {
          changePage(
            Container(
              height: 50,
              color: Colors.black45,
            ),
            false,
            true,
            false,
            false,
          );
        } else if (text == "가전제품") {
          changePage(
            Container(
              height: 50,
              color: Colors.black26,
            ),
            false,
            false,
            true,
            false,
          );
        } else if (text == "기타") {
          changePage(
            Container(
              height: 50,
              color: Colors.black12,
            ),
            false,
            false,
            false,
            true,
          );
        }
      },
      child: Text(text, style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: isSelected ? Colors.black : Colors.grey,
      )),
      style: TextButton.styleFrom(
        padding: EdgeInsets.all(15),
        backgroundColor: isSelected ? Colors.black12 : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
    );
  }
}