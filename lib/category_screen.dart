import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// void main() {
//   runApp(CategoryScreen());
// }


class CategoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            '카테고리',
            style: TextStyle(color: Colors.black, fontSize: 25),
          ),
          backgroundColor: Colors.white,
          centerTitle: false,
          titleSpacing: 0.0,
        ),
        body: Container(
          child: Row(
            children: [
              Flexible(
                child: Container(
                  width: 100,
                  color: Colors.black12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: Text('의류', style: TextStyle(color: Colors.black, fontSize: 20)),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text('신발', style: TextStyle(color: Colors.black, fontSize: 20)),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text('가방', style: TextStyle(color: Colors.black, fontSize: 20)),
                      ),
                      TextButton(
                        onPressed: () => {},
                        child: Text('디지털', style: TextStyle(color: Colors.black, fontSize: 20)),
                      ),

                      TextButton(
                        onPressed: () {},
                        child: Text('쥬얼리', style: TextStyle(color: Colors.black, fontSize: 20)),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text('뷰티', style: TextStyle(color: Colors.black, fontSize: 20)),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text('가구', style: TextStyle(color: Colors.black, fontSize: 20)),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          '기타',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                flex: 3,
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 400.0),
                  child: Wrap(
                    spacing: 10.0, // 각 버튼 간격 조절
                    runSpacing: 20.0, // 각 줄 간격 조절
                    children: [
                      Container(child: Padding(padding: EdgeInsets.only(top: 20))),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          '휴대폰',
                          style: TextStyle(color: Colors.black, fontSize: 15),
                        ),
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all<Size>(
                            Size(70, 60), // 버튼의 최소 크기 조절
                          ),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.black12),
                        ),
                      ),

                      Container(child: Padding(padding: EdgeInsets.only(top: 20))),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          '노트북',
                          style: TextStyle(color: Colors.black, fontSize: 15),
                        ),
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all<Size>(
                            Size(70, 60), // 버튼의 최소 크기 조절
                          ),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.black12),
                        ),
                      ),

                      Padding(padding: EdgeInsets.only(top: 20)),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          '데스크탑',
                          style: TextStyle(color: Colors.black, fontSize: 15),
                        ),
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all<Size>(
                            Size(70, 60), // 버튼의 최소 크기 조절
                          ),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.black12),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            '보조\n배터리',
                            textAlign: TextAlign.center, // 텍스트 가운데 정렬
                            style: TextStyle(color: Colors.black, fontSize: 15),
                          ),
                          style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all<Size>(
                              Size(70, 60), // 버튼의 최소 크기 조절
                            ),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.black12),
                          ),
                        ),
                      ),

                      Padding(padding: EdgeInsets.only(top: 20)),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          '충전기',
                          style: TextStyle(color: Colors.black, fontSize: 15),
                        ),
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all<Size>(
                            Size(70, 60), // 버튼의 최소 크기 조절
                          ),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.black12),
                        ),
                      ),
                    ],
                  ),
                ),
                flex: 7,
              ),
            ],
          ),
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
}