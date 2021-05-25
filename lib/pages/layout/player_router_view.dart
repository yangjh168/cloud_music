import 'package:cloud_music/pages/error_page.dart';
import 'package:cloud_music/pages/layout/base_router_view.dart';
import 'package:flutter/material.dart';
import 'package:cloud_music/widget/bottom_player_bar.dart';

class PlayerRouterView extends StatefulWidget {
  //当前路由层次的路径
  final String initialRoute;
  //子路由列表
  final List routes;

  PlayerRouterView(
      {Key key, @required this.initialRoute, @required this.routes})
      : super(key: key);

  static _PlayerRouterViewState of(BuildContext context) {
    // findAncestorStateOfType()可以从当前节点沿着widget树向上查找指定类型的StatefulWidget对应的State对象。
    // 注意：context必须为LoadDataBuilder子节点的context
    return context.findAncestorStateOfType<_PlayerRouterViewState>();
  }

  @override
  _PlayerRouterViewState createState() => _PlayerRouterViewState();
}

class _PlayerRouterViewState extends State<PlayerRouterView> {
  final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    print("初始路由：" + widget.initialRoute);
    return WillPopScope(
      onWillPop: () async {
        //重写物理返回键，如果本router-view的Navigator可以返回，优先在该路由返回
        if (key.currentState.canPop()) {
          key.currentState.pop();
          return false;
        } else {
          return true;
        }
      },
      child: BaseRouterView(
        rootRoute: '/playerView',
        routes: widget.routes,
        builder: (router) {
          return Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: Navigator(
                    key: key,
                    initialRoute: widget.initialRoute,
                    onGenerateRoute: router.generator,
                    onUnknownRoute: (RouteSettings setting) {
                      String name = setting.name;
                      print("未匹配到路由:$name");
                      return MaterialPageRoute(builder: (context) {
                        return ErrorPage();
                      });
                    },
                  ),
                ),
                BottomPlayerBar(),
              ],
            ),
          );
        },
      ),
    );
  }
}
