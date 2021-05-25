import 'package:dio/dio.dart';
import '../dio/http_utils.dart';

Global globalApi = new Global();

class Global {
  Future<List<Map>> getHomeBannerList(
      [Map data, Options options, bool capture]) async {
    final response = await HttpUtils.get(
        'http://119.29.152.159:8080/sysParams/homeParamList',
        data,
        options,
        capture);
    final list = (response as List).cast<Map>().toList();
    return list;
  }
}
