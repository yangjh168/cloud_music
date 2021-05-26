import 'package:cloud_music/widget/slide_container.dart';
import 'package:flutter/material.dart';

//单例设计模式
class GlobalData {
  // 工厂模式
  factory GlobalData() => _getInstance();
  static GlobalData get instance => _getInstance();
  static GlobalData _instance;

  GlobalData._internal() {
    // 初始化
  }
  static GlobalData _getInstance() {
    if (_instance == null) {
      _instance = new GlobalData._internal();
    }
    return _instance;
  }

  //侧边栏的GlobalKey
  GlobalKey<ContainerState> slideKey;
  //当前平台
  int platform;
}
