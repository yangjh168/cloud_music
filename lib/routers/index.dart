import 'package:cloud_music/music_player/player_page.dart';
import 'package:cloud_music/pages/layout/player_router_view.dart';
import 'package:cloud_music/pages/layout/slide_drawer.dart';
import 'package:cloud_music/pages/search_page.dart';
import 'package:cloud_music/pages/songlist_page.dart';

final Map<String, Function> routers = {
  '/slideDrawer': (params) => SlideDrawer(),
  // '/player': (params) => PlayingPage(),
  '/playerPage': (params) => PlayerPage(),
  '/searchPage': (params) => SearchPage(),
  '/songlistPage': (params) => SonglistPage(id: int.parse(params['id'])),
};

final List<Map> routerConfig = [
  {
    'path': '/slideDrawer',
    'name': 'slideDrawer',
    'component': (params) => SlideDrawer(),
  },
  {
    'path': '/playerPage',
    'name': 'playerPage',
    'component': (params) => PlayerPage(),
  },
  {
    'path': '/playerView',
    'name': 'playerView',
    'component': (params, path) =>
        PlayerRouterView(initialRoute: path, routes: [
          {
            'path': '/songlistPage',
            'name': 'songlistPage',
            'component': (params) {
              return SonglistPage(id: int.parse(params['id']));
            },
          },
          {
            'path': '/searchPage',
            'name': 'searchPage',
            'component': (params) => SearchPage(),
          },
        ]),
  },
];
