import 'package:cloud_music/pages/error_page.dart';
import 'package:cloud_music/routers/handlers.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

class BaseRouterView extends StatefulWidget {
  final String rootRoute;

  final List routes;

  final Widget Function(FluroRouter router) builder;

  BaseRouterView({
    Key key,
    @required this.rootRoute,
    @required this.routes,
    @required this.builder,
  }) : super(key: key);

  static _BaseRouterViewState of(BuildContext context, [root]) {
    // findAncestorStateOfType()可以从当前节点沿着widget树向上查找指定类型的StatefulWidget对应的State对象。
    // 注意：context必须为BaseRouterView子节点的context
    root = root ?? false;
    if (root) {
      return context.findRootAncestorStateOfType<_BaseRouterViewState>();
    } else {
      return context.findAncestorStateOfType<_BaseRouterViewState>();
    }
  }

  @override
  _BaseRouterViewState createState() => _BaseRouterViewState();
}

class _BaseRouterViewState extends State<BaseRouterView> {
  FluroRouter router;
  String rootRoute;

  @override
  void initState() {
    super.initState();
    //创建路由对象
    var fluroRouter = FluroRouter();
    //定义找不到路由的回调方法，与显示界面
    fluroRouter.notFoundHandler = Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print("route not found!");
      return Scaffold(
        body: ErrorPage(),
      );
    });
    //添加默认路由
    fluroRouter.define('/', handler: Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      return Scaffold(
          body: Center(
        child: Text("默认页面"),
      ));
    }));
    //配置路由集Routes的路由对象
    widget.routes.forEach((item) {
      fluroRouter.define(item['path'],
          handler: pageHandler(builder: item['component']));
    });
    this.setState(() {
      router = fluroRouter;
      rootRoute = widget.rootRoute;
    });
    print("初始化router-view完成");
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(router);
  }
}
