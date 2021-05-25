import 'package:cloud_music/entity/song_menu.dart';
import 'package:dio/dio.dart';
import '../dio/http_utils.dart';

KuwoApi kuwoApi = new KuwoApi();

class KuwoApi {
  // 获取推荐歌单
  Future<List<SongMenu>> getRecommendPlaylist(
      [Map data, Options options, bool capture]) async {
    final response =
        await HttpUtils.get('/kuwo/homedata', data, options, capture);
    final list = (response as List)
        .cast<Map>()
        .map((item) => SongMenu.fromJson(item))
        .toList();
    return list;
  }

  //获取搜索结果列表
  Future getSearchResultList([Map data, Options options, bool capture]) async {
    return HttpUtils.get('/kuwo/search', data, options, capture);
  }
}
