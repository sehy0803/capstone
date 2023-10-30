import 'package:flutter/material.dart';

void main() {
  runApp(const AuctionScreen());
}

class AuctionScreen extends StatelessWidget {
  const AuctionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: Text('경매',
                style: TextStyle(color: Colors.black, fontSize: 20)),
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: (){},
              icon: Icon(Icons.arrow_back_ios_new_rounded),
              iconSize: 30,
              color: Colors.black,
            ),
        ),
        body: SingleChildScrollView(
              child: Column(
                children: [



                ],
              ),
        )
    );
  }
}