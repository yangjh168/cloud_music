import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IndexStore extends ChangeNotifier {
  ///根据BuildContext获取 [IndexStore]
  static IndexStore of(BuildContext context, {bool listen = true}) {
    return Provider.of<IndexStore>(context, listen: listen);
  }

  int currentIndex = 0; //主页底部tab下标
  Route currentRoute; //当前路由对象

  int currentPlatform = 1; //当前播放平台

  setCurrentIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }

  setCurrentRoute(Route route) {
    currentRoute = route;
    notifyListeners();
  }

  setCurrentPlatform(int platform) {
    currentPlatform = platform;
    notifyListeners();
  }
}
