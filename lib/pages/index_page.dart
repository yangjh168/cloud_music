import 'package:cloud_music/android/android_back_desktop.dart';
import 'package:cloud_music/provider/audio_store.dart';
import 'package:flutter/material.dart';
import 'package:cloud_music/pages/layout/slide_drawer.dart';
import 'package:cloud_music/pages/main_page.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({Key key}) : super(key: key);

  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  DateTime lastPopTime;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // 点击返回键的操作
      onWillPop: () async {
        bool isPlaying = AudioStore.of(context, listen: false).isPlaying;
        //如果时正在播放音乐，则返回进入后台播放，不退出
        if (isPlaying) {
          //设置为返回不退出app
          AndroidBackTop.backDeskTop();
        } else {
          // 退出提示
          if (lastPopTime == null ||
              DateTime.now().difference(lastPopTime) > Duration(seconds: 2)) {
            lastPopTime = DateTime.now();
            Fluttertoast.showToast(
              msg: "再按一次退出",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );
            return false;
          } else {
            lastPopTime = DateTime.now();
            // 退出app
            await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          }
        }
        return false;
      },
      child: SlideDrawer(
        child: MainPage(),
      ),
    );
  }
}
