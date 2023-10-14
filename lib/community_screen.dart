import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(CommunityScreen());
}

class CommunityScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title:
            Text('커뮤니티',style: TextStyle(color: Colors.black,fontSize: 24.0),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 35.0),
                child: IconButton(
                  icon: Icon(Icons.search,color: Colors.black, size: 45.0,) ,
                  onPressed: (){},),
              )
            ],
          ),
          body: Column(
            children: [
              Container(
                padding: EdgeInsets.all(14.0),
                alignment: Alignment.centerLeft,
                width: 400,
                height: 135,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('마우스 있는 분 계신가요 ?',
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22
                      ),),
                    Text('무선 마우스랑 유선 마우스 둘 다 필요합니다.',
                      style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
                    SizedBox(height: 3,),
                    Row(
                      children: [
                        Text('댓글  0   ',
                          style: TextStyle(fontWeight: FontWeight.w600,fontSize: 14
                              ,color: Colors.black38),),
                        Text('•',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 14,
                            color: Colors.black38),),
                        Text('   조회수  0',
                          style: TextStyle(fontWeight: FontWeight.w600,fontSize: 14,
                              color: Colors.black38),),
                        SizedBox(width: 190,),
                        IconButton(icon: Icon(Icons.chat_bubble, size: 22,),
                          onPressed: (){}, )
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 5,),
              Container(
                padding: EdgeInsets.all(14.0),
                alignment: Alignment.centerLeft,
                width: 400,
                height: 135,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('좋은 가구 고르는 법',
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22
                      ),),
                    Text('좋은 안목이 필요함',
                      style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
                    SizedBox(height: 3,),
                    Row(
                      children: [
                        Text('댓글  0   ',
                          style: TextStyle(fontWeight: FontWeight.w600,fontSize: 14
                              ,color: Colors.black38),),
                        Text('•',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 14,
                            color: Colors.black38),),
                        Text('   조회수  0',
                          style: TextStyle(fontWeight: FontWeight.w600,fontSize: 14,
                              color: Colors.black38),),
                        SizedBox(width: 190,),
                        IconButton(icon: Icon(Icons.chat_bubble, size: 22,),
                          onPressed: (){}, )
                      ],
                    )
                  ],
                ),
              ),
              Expanded(child: Container(
                color: Colors.black12,
              )),
            ],
          ),
        )
    );
  }
}
