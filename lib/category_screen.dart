import 'package:flutter/material.dart';

void main() {
  runApp(CategoryScreen());
}

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String selectedCategory = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
              ),
            ),
          ],
        ),
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