import 'package:capstone/tshirts_category.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CategoryScreen());
}
// 테스트 코드

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              '카테고리',
              style: TextStyle(color: Colors.black),
            ),
          ),
          backgroundColor: Colors.white,
          centerTitle: false,
          titleSpacing: 0.0,
        ),
        body: Category(),
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
}

class Category extends StatefulWidget {
  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  List<String> clothingCategories = [
    '의류', '신발', '가방', '디지털', '쥬얼리', '뷰티', '가구', '기타'
  ];
  List<String> upperWearCategories = ['티셔츠', '셔츠'];

  String selectedCategory = '';
  bool isCategorySelected = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Container(
            color: Colors.black12,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (String category in clothingCategories)
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              selectedCategory = category;
                              isCategorySelected = true;
                            });
                          },
                          child: Text(
                            category,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (isCategorySelected)
          Positioned(
            right: 40,
            top: 0,
            bottom: 420,
            child: Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      selectedCategory,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20.0),

                    if (selectedCategory == '의류')
                      ...upperWearCategories.map((upperCategory) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: TextButton(
                              onPressed: () {
                                // 의류
                                Navigator.push(context, MaterialPageRoute(builder: (context) => TshirtsCategory()));
                              },
                              child: Text(
                                upperCategory,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        );
                      }),

                    if (selectedCategory == '신발')
                      ...[
                        '구두', '운동화',
                      ].map((shoeCategory) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: TextButton(
                              onPressed: () {
                                // 신발
                              },
                              child: Text(
                                shoeCategory,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        );
                      }),

                    if (selectedCategory == '가방')
                      ...[
                        '백팩',
                        '토트백',
                      ].map((bagCategory) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: TextButton(
                              onPressed: () {
                                // 가방
                              },
                              child: Text(
                                bagCategory,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        );
                      }),

                    if (selectedCategory == '디지털')
                      ...[
                        ['휴대폰', '노트북', '데스크탑'],
                        ['보조배터리','충전기']
                      ].asMap().entries.map((entry) {
                        int index = entry.key;
                        List<String> categoryGroup = entry.value;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: categoryGroup.map((category) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    // 디지털
                                  },
                                  child: Text(
                                    category,
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),

                    if (selectedCategory == '쥬얼리')
                      ...[
                        '반지',
                        '목걸이',
                      ].map((shoeCategory) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: TextButton(
                              onPressed: () {
                                // 쥬얼리
                              },
                              child: Text(
                                shoeCategory,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        );
                      }),

                    if (selectedCategory == '뷰티')
                      ...[
                        '화장품',
                      ].map((shoeCategory) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: TextButton(
                              onPressed: () {
                                // 뷰티
                              },
                              child: Text(
                                shoeCategory,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        );
                      }),

                    if (selectedCategory == '가구')
                      ...[
                        '책상',
                        '의자',
                      ].map((shoeCategory) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: TextButton(
                              onPressed: () {
                                // 가구
                              },
                              child: Text(
                                shoeCategory,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        );
                      }),

                    if (selectedCategory == '기타')
                      ...[
                        '기타',
                      ].map((shoeCategory) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: TextButton(
                              onPressed: () {
                                // 기타
                              },
                              child: Text(
                                shoeCategory,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
