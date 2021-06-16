import 'package:cloud_music/music_player/player_page.dart';
import 'package:cloud_music/pages/index_page.dart';
import 'package:cloud_music/pages/rank/rank_page.dart';
import 'package:cloud_music/pages/search_page.dart';
import 'package:cloud_music/pages/setting/setting_theme_page.dart';
import 'package:cloud_music/pages/songlist_page.dart';
import 'package:cloud_music/pages/daily_recommend_page.dart';
import 'package:cloud_music/pages/playlist_plaza_page.dart';

final Map<String, Function> routers = {
  '/indexPage': (params) => IndexPage(),
  // '/player': (params) => PlayingPage(),
  '/playerPage': (params) => PlayerPage(),
  '/searchPage': (params) => SearchPage(),
  '/songlistPage': (params) =>
      SonglistPage(id: params['id'], playlistDetail: params['playlistDetail']),
  '/dailyRecommendPage': (params) => DailyRecommendPage(),
  '/playlistPlazaPage': (params) => PlaylistPlazzPage(),
  '/rankPage': (params) => RankPage(),
  '/settingThemePage': (params) => SettingThemePage(),
};
