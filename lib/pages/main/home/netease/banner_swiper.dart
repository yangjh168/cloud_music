import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BannerSwiper extends StatelessWidget {
  final List bannerList;

  BannerSwiper({Key key, this.bannerList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 253.h,
      width: 750.w,
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: Swiper(
        itemCount: bannerList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.network('${bannerList[index]['url']}',
                    fit: BoxFit.fill),
              ));
        },
        pagination: SwiperPagination(),
        autoplay: true,
      ),
    );
  }
}
