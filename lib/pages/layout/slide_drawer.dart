import 'dart:ui';

import 'package:cloud_music/android/android_back_desktop.dart';
import 'package:cloud_music/pages/index_page.dart';
import 'package:cloud_music/repository/global_repository.dart';
import 'package:flutter/material.dart';
import 'package:cloud_music/widget/slide_container.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SlideDrawer extends StatefulWidget {
  @override
  _SlideDrawerState createState() => _SlideDrawerState();
}

class _SlideDrawerState extends State<SlideDrawer> {
  DateTime lastPopTime;

  double position = 0.0;
  double height = 0.0;

  double get maxSlideDistance => MediaQuery.of(context).size.width * 0.7;

  final GlobalKey<ContainerState> _slideKey = GlobalKey<ContainerState>();

  void onSlide(double position) {
    setState(() => this.position = position);
  }

  @override
  Widget build(BuildContext context) {
    // double statusBarHeight = MediaQuery.of(context).padding.top;
    height = MediaQuery.of(context).size.height; //- statusBarHeight;
    //遮罩层透明度
    final double opacity = position * 0.6;
    //存储
    GlobalData.instance.slideKey = _slideKey;
    return WillPopScope(
      // margin: EdgeInsets.only(top: statusBarHeight),
      onWillPop: () async {
        // 点击返回键的操作
        AndroidBackTop.backDeskTop(); //设置为返回不退出app
        return false;
        //退出提示
        // if (lastPopTime == null ||
        //     DateTime.now().difference(lastPopTime) > Duration(seconds: 2)) {
        //   lastPopTime = DateTime.now();
        //   Fluttertoast.showToast(
        //     msg: "再按一次退出",
        //     toastLength: Toast.LENGTH_SHORT,
        //     gravity: ToastGravity.BOTTOM,
        //   );
        //   return false;
        // } else {
        //   lastPopTime = DateTime.now();
        //   // 退出app
        //   await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        // }
        // return false;
      },
      child: SlideStack(
        drawer: DrawerPage(),
        child: SlideContainer(
          key: _slideKey,
          // minAutoSlideDistance: 50.0,
          shadowSpreadRadius: 0,
          shadowBlurRadius: 0,
          slideDirection: SlideDirection.left,
          onSlide: onSlide,
          drawerSize: maxSlideDistance,
          child: Stack(
            fit: StackFit.expand,
            children: [
              IndexPage(),
              opacity <= 0
                  ? Container(width: 0, height: 0)
                  : Positioned(
                      top: 0,
                      left: 0,
                      width: MediaQuery.of(context).size.width,
                      height: height,
                      child: InkWell(
                        onTap: () {
                          _slideKey.currentState.openOrClose();
                        },
                        child: Container(
                          color: Color.fromRGBO(0, 0, 0, opacity),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  final String title;
  final VoidCallback tapDrawer;
  final double height;

  const CustomAppBar({Key key, this.title, this.tapDrawer, this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).accentColor,
      height: height,
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: tapDrawer,
            child: Padding(
              padding: EdgeInsets.only(left: 10.0, right: 20.0),
              child: Icon(
                Icons.dehaze,
                color: Colors.white,
              ),
            ),
          ),
          Center(
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .title
                  .copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuInfo {
  final String title;
  final IconData icon;

  _MenuInfo({this.title, this.icon});
}

final List<_MenuInfo> menus = [
  _MenuInfo(title: '设置', icon: Icons.settings),
  _MenuInfo(title: '夜间模式', icon: Icons.account_balance_wallet),
  _MenuInfo(title: '个性装扮', icon: Icons.format_paint),
  _MenuInfo(title: '关于', icon: Icons.photo_album),
];

class DrawerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: new BackdropFilter(
        filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: new Container(
          padding: EdgeInsets.only(top: 20.0, left: 20.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                    itemCount: menus.length,
                    itemBuilder: (context, index) {
                      return Container(
                        height: 60.0,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(right: 10.0),
                              child: Icon(
                                menus[index].icon,
                              ),
                            ),
                            Center(
                              child: Text(
                                menus[index].title,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
              )
            ],
          ),
          decoration: new BoxDecoration(color: Colors.white.withOpacity(0.25)),
        ),
      ),
    );
  }
}
