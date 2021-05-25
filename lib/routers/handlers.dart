import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

//创建Handler用来接收路由参数及返回第二个页面对象
Handler pageHandler({Function builder}) {
  return Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
      print("----------------pageHandler---------------");
      Map<String, Object> newParams = {};
      if (params != null) {
        print('pageHandler页面跳转参数:' + params.toString());
        params.forEach((key, value) {
          if (value != null && value.length == 1) {
            newParams[key] = value.first;
          } else {
            newParams[key] = value;
          }
        });
      }
      if (context.settings.arguments != null) {
        print("获取到路径参数：" + context.settings.arguments);
        return builder(newParams, context.settings.arguments);
      } else {
        return builder(newParams);
      }
    },
  );
}
