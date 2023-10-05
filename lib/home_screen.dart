import 'package:flutter/material.dart';

void main() {
  runApp(const HomeScreen());
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Logo",
              style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold)
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              color: Colors.black,
              iconSize: 30,
              onPressed: () {
                print('click');
                }
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              height: 160,
              color: Colors.black12,
            ),
            Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: Column(
                children: [ Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(onPressed: (){}, icon: Icon(Icons.home), iconSize: 50),
                        IconButton(onPressed: (){}, icon: Icon(Icons.home), iconSize: 50),
                        IconButton(onPressed: (){}, icon: Icon(Icons.home), iconSize: 50),
                        IconButton(onPressed: (){}, icon: Icon(Icons.home), iconSize: 50),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(onPressed: (){}, icon: Icon(Icons.home), iconSize: 50),
                        IconButton(onPressed: (){}, icon: Icon(Icons.home), iconSize: 50),
                        IconButton(onPressed: (){}, icon: Icon(Icons.home), iconSize: 50),
                        IconButton(onPressed: (){}, icon: Icon(Icons.home), iconSize: 50),
                      ],
                    ),
                  ),
                ],
              )
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("최근 경매 결과",
                        style: TextStyle(fontSize: 24)),
                    TextButton(onPressed: (){}, child: Text("더보기", style: TextStyle(fontSize: 20, color: Colors.grey))),
                  ],
                )
            ),
            Padding(padding: EdgeInsets.all(25),
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //Image.asset('assets/Tshirts.jpeg', width: 120, height: 120),
                  Container(width: 120, height: 120, color: Colors.black12),
                  Container(
                    width: 200,
                    height: 120,
                    margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("괜찮은 의자", style: TextStyle(fontSize: 18)),
                        Text("2023-09-02", style: TextStyle(fontSize: 18, color: Colors.grey)),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("시작가", style: TextStyle(fontSize: 18)),
                            Text("150,000원", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("낙찰가", style: TextStyle(fontSize: 18)),
                            Text("210,000원", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
                          ],
                        )
                      ],
                    )
                  )
                ],
              )
            )
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(onPressed: (){}, icon: Icon(Icons.home)),
                IconButton(onPressed: (){}, icon: Icon(Icons.launch)),
                IconButton(onPressed: (){}, icon: Icon(Icons.chat)),
                IconButton(onPressed: (){}, icon: Icon(Icons.favorite)),
                IconButton(onPressed: (){}, icon: Icon(Icons.person)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
