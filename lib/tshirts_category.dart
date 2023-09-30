import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TshirtsCategory extends StatefulWidget {
  const TshirtsCategory({super.key});

  @override
  _TshirtsCategoryState createState() => _TshirtsCategoryState();
}

class _TshirtsCategoryState extends State<TshirtsCategory> {
  bool isFavorited = false;     // 하트 버튼 상태 추적 변수

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('티셔츠', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          centerTitle: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
          height: 150,
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Image.asset('assets/Tshirts.jpeg', width: 150, height: 150,),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('티셔츠', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    Text('경매일 2023-09-01', style: TextStyle(fontSize: 15, color: Colors.grey)),
                    SizedBox(height: 30,),
                    Text('시작가', style: TextStyle(fontSize: 15)),
                    Expanded(
                      child: Row(
                        children: [
                          Text('880,000원',
                              style: TextStyle(fontSize: 20, color: Color(0xff18a4f0))),
                          Spacer(),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                isFavorited = !isFavorited;
                              });
                            },
                            icon: Icon(
                              isFavorited ? Icons.favorite : Icons.favorite_border,  // 처음 상태는 빈 하트
                              color: isFavorited ? Colors.black : Colors.black,        // 누를 때마다 하트 상태 변경
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(),
      ),
    );
  }
}