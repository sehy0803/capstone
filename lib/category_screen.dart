import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// void main() {
//   runApp(const CategoryScreen());
// }
// 테스트 코드

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home : Scaffold(
        appBar: AppBar(title: Text('카테고리', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,centerTitle: false, titleSpacing: 0.0,
        ),
        body: Row(
          children: [
            Flexible(child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(onPressed: (){}, child: Text('의류', style: TextStyle(color: Colors.black))),
                TextButton(onPressed: (){}, child: Text('신발', style: TextStyle(color: Colors.black))),
                TextButton(onPressed: (){}, child: Text('가방', style: TextStyle(color: Colors.black))),
                TextButton(onPressed: (){}, child: Text('디지털', style: TextStyle(color: Colors.black))),
                TextButton(onPressed: (){}, child: Text('쥬얼리', style: TextStyle(color: Colors.black))),
                TextButton(onPressed: (){}, child: Text('뷰티', style: TextStyle(color: Colors.black))),
                TextButton(onPressed: (){}, child: Text('가구', style: TextStyle(color: Colors.black))),
                TextButton(onPressed: (){}, child: Text('기타', style: TextStyle(color: Colors.black))), // 카테고리 버튼
              ],
            ), flex: 1),
            Flexible(child: Row(), flex: 3)
          ],
        ),
        bottomNavigationBar: BottomAppBar(child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(onPressed: (){}, icon: Icon(Icons.home)),
            IconButton(onPressed: (){}, icon: Icon(Icons.launch)),
            IconButton(onPressed: (){}, icon: Icon(Icons.chat)),
            IconButton(onPressed: (){}, icon: Icon(Icons.favorite)),
            IconButton(onPressed: (){}, icon: Icon(Icons.person)),
          ],
        ),),
      )
    );
  }
}
