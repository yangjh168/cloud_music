import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  final String desc;
  const EmptyWidget({Key key, this.desc = "暂无数据"}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(50),
      child: Column(
        children: [
          Container(
              child: Image.asset("assets/images/empty.png",
                  width: 100, height: 100)),
          Text(desc)
        ],
      ),
    );
  }
}
