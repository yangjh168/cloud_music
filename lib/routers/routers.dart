import 'package:cloud_music/pages/layout/base_router_view.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:cloud_music/provider/index_store.dart';
import 'package:provider/provider.dart';

//封装一个Routes 类
class Routes {
  static findFluroRouter(BuildContext context, [bool root]) {
    return BaseRouterView.of(context, root);
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
    var router = findFluroRouter(context).router;
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
    //FocusScope.of(context).requestFocus(new FocusNode());
    String query = "";
    if (params != null) {
      int index = 0;
      for (var key in params.keys) {
        String valueStr = params[key].toString();
        var value = Uri.encodeComponent(valueStr);
        if (index == 0) {
          query = "?";
        } else {
          query = query + "\&";
        }
        query += "$key=$value";
        index++;
      }
    }
    print('navigateTo的参数：$query');
    var routerView = findFluroRouter(context);
    var router = routerView.router;
    var rootRoute = routerView.rootRoute;
    var pathArray = path.split("/");
    var routeSettings;
    var url = path + query;
    var sameRoute = (('/' + pathArray[1]).indexOf(rootRoute) != -1);
    print("是否同级路由：" + sameRoute.toString());
    if (sameRoute) {
      url = '/' + pathArray[1] + query;
      if (pathArray.length > 2) {
        routeSettings = RouteSettings(
          arguments: pathArray[pathArray.length - 1] +
              query, //路由要带上参数，fluro会自动把它转为参数返回给handler
        );
      }
    } else {
      //非统计路由重新找根router-view的router
      routerView = findFluroRouter(context, true);
      router = routerView.router;
    }
    print("跳转路径:" + url);
    return router.navigateTo(
      context,
      url,
      clearStack: clearStack,
      transition: transition,
      routeSettings: routeSettings,
    );
  }

  //返回
  static void pop<T>(BuildContext context, [T result]) {
    var routerView = findFluroRouter(context);
    var router = routerView.router;
    router.pop(context, result);
  }

  // 返回顶层
  static void switchPop<T>(BuildContext context, int index, [T result]) {
    IndexStore indexStore = Provider.of<IndexStore>(context, listen: false);
    indexStore.setCurrentIndex(index);
    return Navigator.of(context).popUntil(ModalRoute.withName('/'));
  }
}
