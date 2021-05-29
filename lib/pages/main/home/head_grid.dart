import 'package:cloud_music/common/const.dart';
import 'package:cloud_music/routers/routers.dart';
import 'package:flutter/material.dart';
// import 'package:cloud_music/routers/routers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HeadGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20.0.w, right: 20.0.w, bottom: 20.0.w),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15.0.w)),
          color: Colors.white),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 4,
        physics: NeverScrollableScrollPhysics(), //关闭滚动
        children: HOME_GRID_LIST.map<Widget>((item) {
          return _menuItem(context, item);
        }).toList(),
      ),
    );
  }

  Widget _menuItem(context, Map item) {
    return GestureDetector(
      onTap: () {
        if (item['path'] != null) {
          Routes.navigateTo(context, item['path']);
        } else {
          Fluttertoast.showToast(
            msg: "暂未完成",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            fontSize: 26.0.sp,
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.0.w,
            height: 80.0.w,
            margin: EdgeInsets.only(bottom: 10.0.h),
            child: Image.asset('${item['icon']}'),
          ),
          Text('${item['name']}',
              style: TextStyle(color: Color(0XFF666666), fontSize: 24.0.sp)),
        ],
      ),
    );
  }
}
