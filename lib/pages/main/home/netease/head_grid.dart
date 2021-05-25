import 'package:cloud_music/common/const.dart';
import 'package:flutter/material.dart';
// import 'package:cloud_music/routers/routers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    return InkWell(
      onTap: () {
        // 打开wenview页面
        // Routes.navigateTo(context, '/webviewPage',
        //         params: {'url': item['link'], 'title': item['title']})
        //     .then((result) {});
        // print('点击了菜单');
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
