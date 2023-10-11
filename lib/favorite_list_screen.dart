import 'package:capstone/home_screen.dart';
import 'package:capstone/my_page_screen.dart';
import 'package:capstone/terms_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const FavoriteListScreen());
}

class FavoriteListScreen extends StatelessWidget {
  const FavoriteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text("관심목록",
                  style: TextStyle(color: Colors.black, fontSize: 25)
              ),
              backgroundColor: Colors.white,
              floating: true,
              pinned: false,
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Line(),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        AuctionProductList(),
                        SizedBox(height: 20),
                        AuctionProductList(),
                        SizedBox(height: 20),
                        AuctionProductList(),
                        SizedBox(height: 20),
                        AuctionProductList(),
                        SizedBox(height: 20),
                        AuctionProductList(),
                        SizedBox(height: 20),
                        AuctionProductList(),
                        SizedBox(height: 20),
                      ],
                    ),
                  )
                ]
              ),
            )
          ],
        ),
        bottomNavigationBar: HomeBottomAppBar()
      ),
    );
  }
}
