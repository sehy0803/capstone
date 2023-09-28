import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('커뮤니티', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          centerTitle: false,
          titleSpacing: 0.0,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: Icon(Icons.search, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
    );
  }
}