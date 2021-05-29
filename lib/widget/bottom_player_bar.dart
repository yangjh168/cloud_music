import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_music/entity/music.dart';
import 'package:cloud_music/music_player/playing_list.dart';
import 'package:cloud_music/provider/audio_store.dart';
import 'package:cloud_music/provider/index_store.dart';
import 'package:cloud_music/provider/player_store.dart';
import 'package:flutter/material.dart';

class BottomPlayerBar extends StatefulWidget {
  @override
  _BottomPlayerBarState createState() => _BottomPlayerBarState();
}

class _BottomPlayerBarState extends State<BottomPlayerBar> {
  //显示底部播放控制面板的页面
  final List<String> playerPage = ['/songlistPage', '/dailyRecommendPage'];

  @override
  Widget build(BuildContext context) {
    IndexStore indexStore = IndexStore.of(context);
    bool isShow = playerPage.any((item) {
      if (indexStore.currentRoute != null) {
        // print(indexStore.currentRoute.settings.name);
        return item == indexStore.currentRoute.settings.name;
      } else {
        return false;
      }
    });
    if (isShow) {
      return BottomControllerBar(
          bottomPadding: MediaQuery.of(context).viewInsets.bottom +
              MediaQuery.of(context).padding.bottom);
    } else {
      return Container();
    }
  }
}

///底部当前音乐播放控制栏
class BottomControllerBar extends StatelessWidget {
  final double bottomPadding;

  const BottomControllerBar({
    Key key,
    this.bottomPadding = 0,
  })  : assert(bottomPadding != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    PlayerStore player = PlayerStore.of(context);
    AudioStore audioStore = AudioStore.of(context);
    Music music = player.music;
    if (music == null) {
      return Container();
    }
    return InkWell(
      onTap: () {
        IndexStore indexStore = IndexStore.of(context, listen: false);
        Route currentRoute = indexStore.currentRoute;
        currentRoute.navigator.pushNamed('/playerPage');
        // Routes.navigateTo(context, '/playerPage');
      },
      child: Card(
        margin: EdgeInsets.all(0),
        shape: const RoundedRectangleBorder(
            borderRadius: const BorderRadius.only(
                topLeft: const Radius.circular(4.0),
                topRight: const Radius.circular(4.0))),
        child: Container(
          decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(width: 0.5, color: Color(0xFFf5f5f5)))),
          height: 56,
          margin: EdgeInsets.only(bottom: bottomPadding),
          child: Row(
            children: <Widget>[
              PlayerHero(
                tag: "album_cover", //唯一标记，前后两个路由页Hero的tag必须相同
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      child: music.imageUrl == null
                          ? Container(color: Colors.grey)
                          : CachedNetworkImage(
                              imageUrl: music.imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: DefaultTextStyle(
                  style: TextStyle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Spacer(),
                      Text(
                        music.title,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      Padding(padding: const EdgeInsets.only(top: 2)),
                      Text(music.subTitle,
                          style: Theme.of(context).textTheme.caption),
                      Spacer(),
                    ],
                  ),
                ),
              ),
              new IconButton(
                onPressed: player.playHandle,
                padding: const EdgeInsets.all(0.0),
                icon: new Icon(
                  audioStore.isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 32.0,
                ),
              ),
              new IconButton(
                onPressed: () {
                  player.next();
                },
                icon: new Icon(
                  Icons.skip_next,
                  size: 32.0,
                ),
              ),
              new IconButton(
                tooltip: "当前播放列表",
                onPressed: () {
                  IndexStore indexStore = IndexStore.of(context, listen: false);
                  Route currentRoute = indexStore.currentRoute;
                  BuildContext currentContext = currentRoute.navigator.context;
                  PlayingListDialog.show(currentContext);
                },
                icon: new Icon(
                  Icons.menu,
                  size: 28.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlayerHero extends StatelessWidget {
  final Object tag;
  final Widget child;

  const PlayerHero({Key key, @required this.tag, @required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // if (context.isLandscape) {
    // disable hero animation in landscape mode
    // return child;
    // }
    return Hero(tag: tag, child: child);
  }
}
