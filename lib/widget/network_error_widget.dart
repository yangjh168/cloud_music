import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback callback;

  NetworkErrorWidget({@required this.callback});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        alignment: Alignment.center,
        height: 200.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              size: 80.w,
            ),
            // VEmptyView(ScreenUtil().setWidth(10)),
            Text(
              '点击重新请求',
            )
          ],
        ),
      ),
    );
  }
}
