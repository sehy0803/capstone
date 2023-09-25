import 'package:flutter/material.dart';

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextFormField(
        obscureText: false, // true 인 경우 값이 * 로 보임
        keyboardType: TextInputType.text, // email, password, number 등의 inputType
        textInputAction: TextInputAction.next, // next, done 과 같이 keyboard enter의 속성
        decoration: InputDecoration(
          hintText: "ddd"
        ),
        validator: (value) {
          if (value!.length < 12) {
            return "오류입니다";
          }
        },
      ),
    );
  }
}
