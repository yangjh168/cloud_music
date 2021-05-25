import 'package:cloud_music/entity/model.dart';
import 'package:cloud_music/entity/song_menu.dart';
import 'package:dio/dio.dart';
import '../dio/http_utils.dart';

CommonApi commonApi = new CommonApi();

class CommonApi {
  // 获取推荐歌单
  Future<List<SongMenu>> getRecommendPlaylist(
      [Map data, Options options, bool capture]) async {
    final response =
        await HttpUtils.get('/netease/recommend', data, options, capture);
    final list = (response as List)
        .cast<Map>()
        .map((item) => SongMenu.fromJson(item))
        .toList();
    return list;
  }

  // 获取推荐的新歌（10首）
  Future<List<Music>> getNewMusicList(
      [Map data, Options options, bool capture]) async {
    final response =
        await HttpUtils.get('/personalized/newsong', data, options, capture);
    final list = (response as List)
        .cast<Map>()
        .map((item) => Music.fromMap(item))
        .toList();
    return list;
  }
}
