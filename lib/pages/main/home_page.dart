import 'package:cloud_music/pages/main/home/kuwo_home.dart';
import 'package:cloud_music/repository/global_repository.dart';
import 'package:cloud_music/routers/routers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_music/pages/main/home/netease_home.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
  }

  // 重新销毁
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("home build");
    return Scaffold(
        appBar: AppBar(
          // titleSpacing: 10.0,
          elevation: 0,
          backgroundColor: Color(0xFFf1503B),
          // iconTheme: IconThemeData(color: Colors.black),
          // textTheme: Theme.of(context).primaryTextTheme,
          // brightness: Theme.of(context).primaryColorBrightness,
          leading: Center(
            child: GestureDetector(
              child: Icon(
                Icons.dehaze,
              ),
              onTap: () {
                //打开侧边栏
                var _slideKey = globalData.getSlideKey();
                if (_slideKey != null) {
                  _slideKey.currentState.openOrClose();
                }
              },
            ),
          ),
          leadingWidth: 50.0.w,
          title: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(50.0.w)),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            constraints: BoxConstraints(maxHeight: 34),
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                Routes.navigateTo(context, '/playerView/searchPage');
              },
              child: TextField(
                style: TextStyle(fontSize: 26.0.sp),
                textInputAction: TextInputAction.search,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  enabled: false, //禁用
                  contentPadding: EdgeInsets.all(2),
                  focusColor: Colors.black,
                  border: InputBorder.none,
                  hintText: '搜索歌曲',
                  hintStyle: TextStyle(fontSize: 26.0.sp),
                  prefixIcon: GestureDetector(
                    onTap: () {},
                    child: Icon(Icons.search, color: Colors.black45),
                  ),
                  prefixStyle: TextStyle(fontSize: 24.sp),
                ),
              ),
            ),
          ),
          // actions: [Icon(Icons.add)],
          bottom: TabBar(
            controller: _controller,
            indicatorColor: Colors.white,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(child: Text('网易')),
              Tab(child: Text('酷狗')),
              Tab(child: Text('酷我')),
            ],
          ),
        ),
        body: TabBarView(controller: _controller, children: <Widget>[
          NeteaseHome(),
          Text('222'),
          // Text('333'),
          KuwoHome(),
        ]));
  }
}
