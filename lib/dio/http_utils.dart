import 'package:dio/dio.dart';

import 'dio_utils.dart';

class HttpUtils {
  //get 请求
  static Future get(String url, [Map data, Options options, bool capture]) {
    return _request(Method.GET, url, data, options, capture);
  }

  //post 请求
  static Future post(String url, [Map data, Options options, bool capture]) {
    return _request(Method.POST, url, data, options, capture);
  }

  //_request 请求
  static Future _request(Method method, String url,
      [Map data, Options options, bool capture]) {
    /// restful 请求处理
    /// /base/search/hist/:user_id        user_id=27
    /// 最终生成 url 为     /base/search/hist/27
    // if (data != null) {
    //   data.forEach((key, value) {
    //     if (url.indexOf(key) != -1) {
    //       url = url.replaceAll(':$key', value.toString());
    //     }
    //   });
    // }
    // 参数处理
    // LogUtils.d("--------- data ---------");
    // LogUtils.d("$data");
    return DioUtils.request(method, url, data, options, capture);
  }
}
