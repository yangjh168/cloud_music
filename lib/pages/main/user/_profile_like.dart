import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileLike extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20.0.w),
      child: Ink(
          padding: EdgeInsets.all(15.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15.0.w)),
              color: Colors.white),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                child: Image.asset('images/icon_logo.png'),
                margin: EdgeInsets.only(right: 10),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("我喜欢的音乐"),
                  Text("0首",
                      style: TextStyle(color: Color(0xff999999), fontSize: 14))
                ],
              )
            ],
          )),
    );
  }
}
