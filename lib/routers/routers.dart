//参考链接：https://my.oschina.net/u/4602373/blog/4465401

import 'package:cloud_music/pages/error_page.dart';
import 'package:cloud_music/provider/index_store.dart';
import 'package:cloud_music/routers/handlers.dart';
import 'package:cloud_music/routers/index.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:provider/provider.dart';

//封装一个Routes 类
class Routes {
  //定义Router 对象
  static FluroRouter router;

  //定义路由路径
  static String webviewPage = "/webviewPage";

  //全局路由配置
  static void configureRoutes(FluroRouter router) {
    //定义找不到路由的回调方法，与显示界面
    router.notFoundHandler = Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print("route not found!");
      return Scaffold(
        body: ErrorPage(),
      );
    });

    //定义一个路由路径与Handler,
    routers.forEach((key, value) {
      router.define(key, handler: pageHandler(builder: value));
    });
  }

  // 需要页面返回值的跳转
  static navigateToForResult<T>(BuildContext context, String path,
      {Map<String, dynamic> params,
      bool clearStack = false,
      TransitionType transition = TransitionType.inFromRight}) async {
    //FocusScope.of(context).requestFocus(new FocusNode());
    String query = "";
    if (params != null) {
      int index = 0;
      for (var key in params.keys) {
        var value = Uri.encodeComponent(params[key]);
        if (index == 0) {
          query = "?";
        } else {
          query = query + "\&";
        }
        query += "$key=$value";
        index++;
      }
    }
    print('我是 navigateTo 传递的参数：$query');

    path = path + query;
    T _result = await router.navigateTo(context, path,
        clearStack: clearStack, transition: transition);
    return _result;
  }

  // 对参数进行 encode，解决参数中有特殊字符
  //不需要返回值的跳转
  static Future navigateTo(BuildContext context, String path,
      {Map<String, dynamic> params,
      bool clearStack = false,
      TransitionType transition = TransitionType.inFromRight}) {
    print("navigateTo的参数");
    print(params);
    return router.navigateTo(context, path,
        clearStack: clearStack,
        transition: transition,
        routeSettings: RouteSettings(arguments: params));
  }

  //返回
  static void pop<T>(BuildContext context, [T result]) {
    return router.pop(context, result);
  }

  // 返回顶层
  static void switchPop<T>(BuildContext context, int index, [T result]) {
    IndexStore indexStore = Provider.of<IndexStore>(context, listen: false);
    indexStore.setCurrentIndex(index);
    return Navigator.of(context).popUntil(ModalRoute.withName('/'));
  }
}
