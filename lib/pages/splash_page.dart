import 'package:cloud_music/routers/routers.dart';
import 'package:flutter/material.dart';
// import 'package:cloud_music/application.dart';
// import 'package:cloud_music/model/song.dart';
// import 'package:cloud_music/model/user.dart';
// import 'package:cloud_music/provider/play_list_model.dart';
// import 'package:cloud_music/provider/play_songs_model.dart';
// import 'package:cloud_music/provider/user_model.dart';
// import 'package:cloud_music/utils/fluro_convert_utils.dart';
// import 'package:cloud_music/utils/navigator_util.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:cloud_music/utils/net_utils.dart';
// import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  AnimationController _logoController;
  Tween _scaleTween;
  CurvedAnimation _logoAnimation;

  @override
  void initState() {
    super.initState();
    _scaleTween = Tween(begin: 0, end: 1);
    _logoController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..drive(_scaleTween);
    // 延时任务
    Future.delayed(Duration(milliseconds: 500), () {
      //播放动画
      _logoController.forward();
    });
    _logoAnimation =
        CurvedAnimation(parent: _logoController, curve: Curves.easeOutQuart);

    _logoController.addStatusListener((status) {
      // 动画已经执行完毕
      if (status == AnimationStatus.completed) {
        // 延时任务
        Future.delayed(Duration(milliseconds: 500), () {
          goPage();
        });
      }
    });
  }

  void goPage() async {
    // await Application.initSp();
    // UserModel userModel = Provider.of<UserModel>(context);
    // userModel.initUser();
    // PlaySongsModel playSongsModel = Provider.of<PlaySongsModel>(context);
    // // 判断是否有保存的歌曲列表
    // if (Application.sp.containsKey('playing_songs')) {
    //   List<String> songs = Application.sp.getStringList('playing_songs');
    //   playSongsModel.addSongs(songs
    //       .map((s) => Song.fromJson(FluroConvertUtils.string2map(s)))
    //       .toList());
    //   int index = Application.sp.getInt('playing_index');
    //   playSongsModel.curIndex = index;
    // }
    // if (userModel.user != null) {
    //   await NetUtils.refreshLogin(context).then((value) {
    //     if (value.data != -1) {
    //       NavigatorUtil.goHomePage(context);
    //     }
    //   });
    //   Provider.of<PlayListModel>(context).user = userModel.user;
    // } else
    //   NavigatorUtil.goLoginPage(context);
    Routes.navigateTo(context, '/indexPage', clearStack: true); //clearStack清空栈
  }

  @override
  Widget build(BuildContext context) {
    // NetUtils.init();
    // ScreenUtil.init(context, width: 750, height: 1334);
    // final size = MediaQuery.of(context).size;
    // Application.screenWidth = size.width;
    // Application.screenHeight = size.height;
    // Application.statusBarHeight = MediaQuery.of(context).padding.top;
    // Application.bottomBarHeight = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: ScaleTransition(
          scale: _logoAnimation,
          child: Hero(
            tag: 'logo',
            child: Image.asset('images/icon_logo.png'),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _logoController.dispose();
  }
}
