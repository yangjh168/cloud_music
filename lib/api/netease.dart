import 'package:dio/dio.dart';
import '../dio/http_utils.dart';

NeteaseApi neteaseApi = new NeteaseApi();

class NeteaseApi {
  ///根据音乐id获取歌词
  Future loadLyric([Map data, Options options, bool capture]) async {
    return HttpUtils.get('/lyric', data, options, capture);
  }

  //获取热门搜索列表
  Future getHotSearchList([Map data, Options options, bool capture]) async {
    return HttpUtils.get('/search/hot', data, options, capture);
  }

  //获取播放链接
  Future<String> getMediaLink([Map data, Options options, bool capture]) async {
    print(data.toString());
    final link = await HttpUtils.get('/media/link', data, options, capture);
    return link;
  }
}
