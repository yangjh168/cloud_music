import 'package:cloud_music/entity/model.dart';
import 'package:cloud_music/entity/playlist_detail.dart';
import 'package:cloud_music/entity/song_menu.dart';
import 'package:dio/dio.dart';
import '../dio/http_utils.dart';

CommonApi commonApi = new CommonApi();

class CommonApi {
  // 获取推荐歌单
  Future<List<SongMenu>> getRecommendPlaylist(
      [Map data, Options options, bool capture]) async {
    final response =
        await HttpUtils.get('/home/recommend', data, options, capture);
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
        await HttpUtils.get('/home/newsong', data, options, capture);
    final list = (response as List)
        .cast<Map>()
        .map((item) => Music.fromMap(item))
        .toList();
    return list;
  }

  //获取搜索结果列表
  Future getSearchResultList([Map data, Options options, bool capture]) async {
    return HttpUtils.get('/search', data, options, capture);
  }

  //检查音乐是否可用
  Future checkMusic([Map data, Options options, bool capture]) async {
    return HttpUtils.get('/check/music', data, options, capture);
  }

  //获取歌曲详情
  Future getMusicDetail([Map data, Options options, bool capture]) async {
    return HttpUtils.get('/song/detail', data, options, capture);
  }

  // 获取歌单详情
  Future<PlaylistDetail> getSonglistDetail(
      [Map data, Options options, bool capture]) async {
    final res = await HttpUtils.get('/songlist/detail', data, options, capture);
    PlaylistDetail playlistDetail = PlaylistDetail.fromJson(res);
    return playlistDetail;
  }
}
