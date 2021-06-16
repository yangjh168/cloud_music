import 'dart:ui';
import 'package:cloud_music/repository/global_repository.dart';
import 'package:cloud_music/routers/routers.dart';
import 'package:flutter/material.dart';
import 'package:cloud_music/widget/slide_container.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SlideDrawer extends StatefulWidget {
  final Widget child;

  const SlideDrawer({Key key, this.child}) : super(key: key);

  @override
  _SlideDrawerState createState() => _SlideDrawerState();
}

class _SlideDrawerState extends State<SlideDrawer> {
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
    return Container(
      // margin: EdgeInsets.only(top: statusBarHeight),
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
              widget.child,
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
  final Function onTap;

  _MenuInfo({this.title, this.icon, this.onTap});
}

class DrawerPage extends StatelessWidget {
  final List<_MenuInfo> menus = [
    _MenuInfo(
      title: '主题设置',
      icon: Icons.settings,
      onTap: (context) {
        print("点击主题设置");
        Routes.navigateTo(context, '/settingThemePage');
      },
    ),
    // _MenuInfo(title: '夜间模式', icon: Icons.account_balance_wallet),
    // _MenuInfo(title: '个性装扮', icon: Icons.format_paint),
    _MenuInfo(
        title: '关于',
        icon: Icons.quiz_outlined,
        onTap: (context) {
          showDialog(
            context: context,
            builder: (context) {
              return AboutDialog(
                applicationIcon: Container(
                  width: 150.w,
                  height: 150.w,
                  child: Image.asset("images/bg_daily.png"),
                ),
                applicationVersion: "0.0.1-alpha",
                applicationLegalese: "此应用仅供学习交流使用，请勿用于任何商业用途。",
              );
            },
          );
        }),
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      // child: new BackdropFilter(
      //   filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
      child: new Container(
        padding: EdgeInsets.only(top: 20.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                  itemCount: menus.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => menus[index].onTap(context),
                      child: Container(
                        padding: EdgeInsets.only(left: 20.0),
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
                      ),
                    );
                  }),
            )
          ],
        ),
        decoration: new BoxDecoration(color: Colors.white.withOpacity(0.25)),
      ),
      // ),
    );
  }
}
