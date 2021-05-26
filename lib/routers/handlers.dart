import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

//创建Handler用来接收路由参数及返回第二个页面对象
Handler pageHandler({Function builder}) {
  return Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
      final args = context.settings.arguments as Map<String, dynamic>;
      // print("pageHandler页面跳转参数");
      return builder(args);
    },
  );
}
