import 'package:cloud_music/provider/index_store.dart';
import 'package:flutter/material.dart';
import 'package:cloud_music/pages/main/home/banner_swiper.dart';
import 'package:cloud_music/pages/main/home/head_grid.dart';
import 'package:cloud_music/pages/main/home/new_music_list.dart';
import 'package:cloud_music/pages/main/home/recommend_playlist.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NeteaseHome extends StatefulWidget {
  @override
  _NeteaseHomeState createState() => _NeteaseHomeState();
}

class _NeteaseHomeState extends State<NeteaseHome>
    with AutomaticKeepAliveClientMixin {
  int platform = 1;

  GlobalKey<RecommendPlaylistState> recommendPlaylistKey =
      new GlobalKey<RecommendPlaylistState>();
  GlobalKey<NewMusicListState> newMusicListKey =
      new GlobalKey<NewMusicListState>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // _getMenuList();
  }

  void _getMenuList() async {
    print("重新加载首页数据");
    recommendPlaylistKey.currentState.loadDataKey.currentState.refresh();
    newMusicListKey.currentState.loadDataKey.currentState.refresh();
    // var list = await getHomeMenuList({}, {
    //   'headers': {'source_type': '504'}
    // });
    // setState(() {
    //   menuList = list;
    // });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    List<Map> bannerList = [
      {
        "url":
            "https://ns-strategy.cdn.bcebos.com/ns-strategy/upload/fc_big_pic/part-00799-2326.jpg"
      }
    ];
    IndexStore indexStore = IndexStore.of(context);
    int currentPlatform = indexStore.currentPlatform;
    if (platform != currentPlatform) {
      this.setState(() {
        platform = currentPlatform;
      });
      _getMenuList();
    }
    return EasyRefresh(
      header: MaterialHeader(),
      bottomBouncing: false, //底部回弹
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            color: Color(0xFFf1503B),
            height: 150.0.h,
          ),
          Container(
            child: Column(
              children: [
                BannerSwiper(bannerList: bannerList),
                HeadGrid(),
                RecommendPlaylist(key: recommendPlaylistKey),
                NewMusicList(key: newMusicListKey),
              ],
            ),
          ),
        ],
      ),
      onRefresh: () async {
        _getMenuList();
      },
    );
  }
}
