import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_music/entity/music.dart';
import 'package:cloud_music/music_player/playing_list.dart';
import 'package:cloud_music/provider/player_store.dart';
import 'package:cloud_music/routers/routers.dart';
import 'package:flutter/material.dart';

class BottomPlayerBar extends StatefulWidget {
  @override
  _BottomPlayerBarState createState() => _BottomPlayerBarState();
}

class _BottomPlayerBarState extends State<BottomPlayerBar> {
  @override
  Widget build(BuildContext context) {
    return BottomControllerBar(
        bottomPadding: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom);
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
    Music music = player.music;
    if (music == null) {
      return Container();
    }
    return InkWell(
      onTap: () {
        Routes.navigateTo(context, '/playerPage');
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
              QuietHero(
                tag: "album_cover",
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
                  player.isPlaying ? Icons.pause : Icons.play_arrow,
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
                  PlayingListDialog.show(context);
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

class QuietHero extends StatelessWidget {
  final Object tag;
  final Widget child;

  const QuietHero({Key key, @required this.tag, @required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // if (context.isLandscape) {
    // disable hero animation in landscape mode
    return child;
    // }
    // return Hero(tag: tag, child: child);
  }
}
