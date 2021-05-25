import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_music/entity/music.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MusicTileDialog extends StatefulWidget {
  final Music music;

  const MusicTileDialog({Key key, this.music}) : super(key: key);

  static void show(BuildContext context, Music music) {
    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return MusicTileDialog(music: music);
      },
    );
  }

  @override
  MusicTileDialogState createState() {
    return new MusicTileDialogState();
  }
}

class MusicTileDialogState extends State<MusicTileDialog> {
  List actionList;

  @override
  void initState() {
    super.initState();
    var list = [
      {
        'icon': Icons.play_circle_outline,
        'name': '下一首播放',
        'event': () => {},
      },
      {
        'icon': Icons.favorite_border,
        'name': '收藏到歌单',
        'event': () => {},
      },
      {
        'icon': Icons.download_rounded,
        'name': '下载',
        'event': () => {},
      },
      {
        'icon': Icons.account_circle_outlined,
        'name': '歌手：' + widget.music.artist[0].name,
        'event': () => {},
      },
      {
        'icon': Icons.album_outlined,
        'name': '专辑：' + widget.music.album.name,
        'event': () => {},
      },
    ];
    this.setState(() {
      actionList = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _MusicActionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _dialogHeader(),
          const Divider(
            height: 1,
            thickness: 1,
          ),
          Expanded(
            child: ListView(
              children: actionList.map<Widget>((item) {
                return _MusicActionItem(action: item);
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  //弹窗头部
  Widget _dialogHeader() {
    return Container(
      padding: EdgeInsets.all(15.0),
      child: Row(
        children: [
          Container(
            color: Colors.yellow,
            width: 80.0.w,
            height: 80.0.w,
            margin: EdgeInsets.only(right: 5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: CachedNetworkImage(
                imageUrl: widget.music.imageUrl,
                placeholder: (context, url) => Container(
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 1,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${widget.music.title}',
                    style:
                        TextStyle(color: Color(0XFF666666), fontSize: 24.0.sp)),
                Text('${widget.music.subTitle}',
                    style:
                        TextStyle(color: Color(0XFF666666), fontSize: 24.0.sp)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

//横竖屏处理
class _MusicActionContainer extends StatelessWidget {
  final Widget child;
  const _MusicActionContainer({Key key, this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // if (context.isLandscape) {
    //   return _LandscapeMusicActionContainer(child: child);
    // } else {
    //   return _PortraitMusicActionContainer(child: child);
    // }
    return _LandscapeMusicActionContainer(child: child);
  }
}

class _LandscapeMusicActionContainer extends StatelessWidget {
  final Widget child;
  const _LandscapeMusicActionContainer({Key key, this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Material(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: child,
        ),
      ),
    );
  }
}

// 每项操作action
const _HEIGHT_MUSIC_TILE = 48.0;

class _MusicActionItem extends StatelessWidget {
  final Map action;

  const _MusicActionItem({Key key, this.action})
      : assert(action != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Ink(
      child: InkWell(
        onTap: () {
          action['event']();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          height: _HEIGHT_MUSIC_TILE,
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: Theme.of(context).dividerColor, width: 0.3))),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 10),
                child: Icon(action['icon'], color: Colors.black),
              ),
              Expanded(
                  child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: action['name']),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
