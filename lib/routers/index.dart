import 'package:cloud_music/music_player/player_page.dart';
import 'package:cloud_music/pages/layout/slide_drawer.dart';
import 'package:cloud_music/pages/search_page.dart';
import 'package:cloud_music/pages/songlist_page.dart';
import 'package:cloud_music/pages/daily_recommend_page.dart';
import 'package:cloud_music/pages/playlist_plaza_page.dart';

final Map<String, Function> routers = {
  '/slideDrawer': (params) => SlideDrawer(),
  // '/player': (params) => PlayingPage(),
  '/playerPage': (params) => PlayerPage(),
  '/searchPage': (params) => SearchPage(),
  '/songlistPage': (params) => SonglistPage(id: params['id']),
  '/dailyRecommendPage': (params) => DailyRecommendPage(),
  '/playlistPlazaPage': (params) => PlaylistPlazzPage(),
};
