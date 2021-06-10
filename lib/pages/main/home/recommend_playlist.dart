import 'package:cloud_music/api/common.dart';
import 'package:cloud_music/entity/song_menu.dart';
import 'package:cloud_music/routers/routers.dart';
import 'package:cloud_music/widget/cache_image.dart';
import 'package:cloud_music/widget/load_data_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecommendPlaylist extends StatefulWidget {
  RecommendPlaylist({
    Key key,
  }) : super(key: key);

  @override
  RecommendPlaylistState createState() => RecommendPlaylistState();
}

class RecommendPlaylistState extends State<RecommendPlaylist> {
  GlobalKey<LoadDataBuilderState> loadDataKey =
      new GlobalKey<LoadDataBuilderState>();

  @override
  void initState() {
    super.initState();

    //修改ImageCache的文件最大缓存值，解决CachedNetworkImage新页面返回会重新加载图片问题，参考：https://github.com/Baseflow/flutter_cached_network_image/issues/529
    PaintingBinding.instance.imageCache.maximumSizeBytes = 1000 << 20;
  }

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
                  InkWell(
                    onTap: () {
                      Routes.navigateTo(context, '/playlistPlazaPage');
                    },
                    child: Row(
                      children: [
                        Text('更多', style: TextStyle(color: Colors.black38)),
                        Icon(Icons.arrow_forward_ios_outlined,
                            color: Colors.black38, size: 24.sp)
                      ],
                    ),
                  ),
                ],
              ),
            ),
            LoadDataBuilder<List<SongMenu>>(
              key: loadDataKey,
              api: commonApi.getRecommendPlaylist,
              builder: (context, data) {
                return Container(
                  padding: EdgeInsets.only(left: 20.w, right: 20.w),
                  child: GridView.count(
                    childAspectRatio: 0.7, //宽高比
                    crossAxisSpacing: 20.w,
                    mainAxisSpacing: 10.0.w,
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    physics: NeverScrollableScrollPhysics(), //关闭滚动
                    children: data.map<Widget>((item) {
                      return _playItem(item, context);
                    }).toList(),
                  ),
                );
              },
            )
          ],
        ));
  }

  Widget _playItem(item, context) {
    return InkWell(
      onTap: () {
        Routes.navigateTo(context, '/songlistPage', params: {'id': item.id});
      },
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 230.w,
            child: CacheImage(
              borderRadius: BorderRadius.circular(5),
              url: item.picUrl,
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
