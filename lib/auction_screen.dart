import 'package:capstone/product_info_screen.dart';
import 'package:capstone/terms_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AuctionScreen());
}

class AuctionScreen extends StatelessWidget {
  const AuctionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset : false,
        appBar: AppBar(
          title: Text('나가기',
              style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          leading: IconButton(
              onPressed: () {Navigator.pop(context);},
              icon: Icon(Icons.clear),
              iconSize: 30,
              color: Colors.black
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 160,
                color: Colors.black12,
              ),
              SizedBox(height: 10),
              Text('괜찮은 의자(상품 제목)',
                  style: TextStyle(fontSize: 22)
              ),
              StartPriceText(),
              Line(),
              AuctionEndTimer(), // 경매 종료까지 남은 시간
              AuctionBidList(), // 경매 입찰 리스트
              SizedBox(height: 12),
              BidPriceTextField(), // 입찰가 입력칸
              SizedBox(height: 12),
              AuctionBidButton(), // 입찰하기 버튼


            ],
          ),

        )
      ),
    );
  }
}

// ======================================================= 커스텀 위젯 =======================================================

// 경매 종료까지 남은 시간
class AuctionEndTimer extends StatelessWidget {
  const AuctionEndTimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('경매 종료까지', style: TextStyle(fontSize: 18)),
          SizedBox(width: 10),
          Container(
            width: 60,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('Time',
                style: TextStyle(fontSize: 18, color: Colors.white, height: 1.8),
                textAlign: TextAlign.center),
          ),
        ],
      )
    );
  }
}

// 시간, 닉네임, 입찰가 등 경매자 정보
class AuctionUserInfo extends StatelessWidget {
  const AuctionUserInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text('시간', style: TextStyle(color: Color(0xff7a7a7a), fontSize: 16)),
            SizedBox(width: 10),
            Text('닉네임', style: TextStyle(color: Colors.black, fontSize: 16)),
          ],
        ),
        Row(
          children: [
            Text('150,000원', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
            Text(' 에 입찰!', style: TextStyle(color: Colors.black, fontSize: 16))
          ],
        )
      ],
    );
  }
}

// 경매 입찰 리스트
class AuctionBidList extends StatelessWidget {
  const AuctionBidList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 200,
      decoration: BoxDecoration(
        color: Color(0xffececec),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            AuctionUserInfo(), // 시간, 닉네임, 입찰가 등 경매자 정보
            SizedBox(height: 5),
            AuctionUserInfo(),
          ],
        ),
      ),
    );
  }
}

// 입찰하기 버튼
class AuctionBidButton extends StatelessWidget {
  const AuctionBidButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () { },
      child: Text("입찰하기",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      style: ButtonStyle(
        backgroundColor : MaterialStateProperty.all(Color(0xff18a4f0)),
        minimumSize: MaterialStateProperty.all(Size(350, 60)),
      ),
    );
  }
}

// 입찰가 입력칸
class BidPriceTextField extends StatelessWidget {
  const BidPriceTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      child: TextField(
        decoration: InputDecoration(
          hintText: '금액을 입력하세요',
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(width: 1, color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(width: 1, color: Colors.grey),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}
