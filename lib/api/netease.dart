import 'package:cloud_music/entity/playlist_detail.dart';
import 'package:cloud_music/entity/song_menu.dart';
import 'package:dio/dio.dart';
import '../dio/http_utils.dart';

NeteaseApi neteaseApi = new NeteaseApi();

class NeteaseApi {
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
  Future getNewMusicList([Map data, Options options, bool capture]) async {
    return HttpUtils.get('/personalized/newsong', data, options, capture);
  }

  ///根据音乐id获取歌词
  Future loadLyric([Map data, Options options, bool capture]) async {
    return HttpUtils.get('/lyric', data, options, capture);
  }

  //获取热门搜索列表
  Future getHotSearchList([Map data, Options options, bool capture]) async {
    return HttpUtils.get('/search/hot', data, options, capture);
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

  //获取播放链接
  Future<String> getMediaLink([Map data, Options options, bool capture]) async {
    print(data.toString());
    final link = await HttpUtils.get('/media/link', data, options, capture);
    return link;
  }

  // 获取歌单详情
  Future<PlaylistDetail> getSonglistDetail(
      [Map data, Options options, bool capture]) async {
    final res = await HttpUtils.get('/songlist/detail', data, options, capture);
    PlaylistDetail playlistDetail = PlaylistDetail.fromJson(res);
    return playlistDetail;
  }
}
