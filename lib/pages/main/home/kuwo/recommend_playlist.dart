import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_music/api/kuwo.dart';
import 'package:cloud_music/entity/song_menu.dart';
import 'package:cloud_music/widget/load_data_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecommendPlaylist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: 20.0.w, right: 20.0.w, bottom: 20.0.w),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15.0.w)),
            color: Colors.white),
        child: Column(
          children: [
            Container(
              padding:
                  EdgeInsets.symmetric(vertical: 14.0.h, horizontal: 20.0.w),
              decoration: BoxDecoration(
                  border: Border(
                      bottom:
                          BorderSide(width: 0.5, color: Color(0xFFf5f5f5)))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('推荐歌单', style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Text('更多', style: TextStyle(color: Colors.black38)),
                      Icon(Icons.arrow_forward_ios_outlined,
                          color: Colors.black38, size: 24.sp)
                    ],
                  )
                ],
              ),
            ),
            LoadDataBuilder<List<SongMenu>>(
                api: kuwoApi.getRecommendPlaylist,
                builder: (context, data) {
                  return Container(
                    padding: EdgeInsets.only(left: 20.w, right: 20.w),
                    child: GridView.count(
                      childAspectRatio: 0.7, //宽高比
                      crossAxisSpacing: 20.w,
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      physics: NeverScrollableScrollPhysics(), //关闭滚动
                      children: data.map<Widget>((item) {
                        return _playItem(item);
                      }).toList(),
                    ),
                  );
                })
          ],
        ));
  }

  Widget _playItem(item) {
    return InkWell(
      onTap: () {
        print('点击了菜单');
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            color: Colors.black12,
            margin: EdgeInsets.only(bottom: 10.0.h),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: CachedNetworkImage(
                imageUrl: item.picUrl,
                placeholder: (context, url) => Container(
                  width: 130,
                  height: 100,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Text(item.name,
              softWrap: true,
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(color: Color(0XFF666666), fontSize: 24.0.sp)),
        ],
      ),
    );
  }
}
