import 'package:cloud_music/provider/index_store.dart';
import 'package:flutter/material.dart';
import 'package:cloud_music/pages/main/home/banner_swiper.dart';
import 'package:cloud_music/pages/main/home/head_grid.dart';
import 'package:cloud_music/pages/main/home/new_music_list.dart';
import 'package:cloud_music/pages/main/home/recommend_playlist.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeIndex extends StatefulWidget {
  @override
  _HomeIndexState createState() => _HomeIndexState();
}

class _HomeIndexState extends State<HomeIndex>
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
            "https://i2.hdslb.com/bfs/archive/859129019595d166286962c6b1aabd034ad58b4f.jpg@880w_388h_1c_95q.webp"
      },
      {
        "url":
            "http://i0.hdslb.com/bfs/feed-admin/bd20e2214e1459381832eabf706dfe8d6adfe249.jpg@880w_388h_1c_95q"
      },
      {
        "url":
            "https://i1.hdslb.com/bfs/archive/0a9a38dff7a4f1f1e3b9cb0ca06af7171a060f14.jpg@880w_388h_1c_95q.webp"
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
            color: Theme.of(context).primaryColor,
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
