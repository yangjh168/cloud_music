import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_music/Cache/lyric_cache.dart';
import 'package:cloud_music/api/netease.dart';
import 'package:cloud_music/entity/music.dart';
import 'package:cloud_music/model/lyric.dart';
import 'package:cloud_music/music_player/playing_list.dart';
import 'package:cloud_music/music_player/utils/lyric.dart';
import 'package:cloud_music/music_player/widget/lyricPannel.dart';
import 'package:cloud_music/provider/audio_store.dart';
import 'package:cloud_music/provider/player_store.dart';
import 'package:cloud_music/widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'animate/pointer.dart';
import 'animate/disc.dart';

class PlayerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new PlayerPageState();
}

class PlayerPageState extends State<PlayerPage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    PlayerStore player = PlayerStore.of(context);
    Music music = player.music;
    if (music == null) {
      return Scaffold(
        appBar: AppBar(title: Text("播放详情")),
        body: Center(
          child: EmptyWidget(desc: "暂无播放音乐"),
        ),
      );
    }
    return Stack(
      children: <Widget>[
        new Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: CachedNetworkImageProvider(music.album.coverImageUrl),
              fit: BoxFit.cover,
              colorFilter: new ColorFilter.mode(
                Colors.black54,
                BlendMode.overlay,
              ),
            ),
          ),
        ),
        new Container(
            child: new BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Opacity(
            opacity: 0.6,
            child: new Container(
              decoration: new BoxDecoration(
                color: Colors.grey.shade900,
              ),
            ),
          ),
        )),
        new Scaffold(
          backgroundColor: Colors.transparent,
          appBar: new AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            title: Container(
              child: Text(
                music.title,
                style: new TextStyle(fontSize: 13.0),
              ),
            ),
          ),
          body: new Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              LightDisk(),
              PlayerController(),
            ],
          ),
        ),
      ],
    );
  }
}

// 播放CD光盘
class LightDisk extends StatelessWidget {
  const LightDisk({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AudioStore audioStore = AudioStore.of(context);
    PlayerStore player = PlayerStore.of(context);
    Music music = player.music;
    bool isPlaying = audioStore.isPlaying;
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        new GestureDetector(
          onTap: player.playHandle,
          child: Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              new Disc(
                isPlaying: isPlaying,
                cover: music.album.coverImageUrl,
              ),
              !isPlaying
                  ? Padding(
                      padding: EdgeInsets.only(top: 186.0),
                      child: Container(
                        height: 56.0,
                        width: 56.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            alignment: Alignment.topCenter,
                            image: AssetImage("assets/images/play.png"),
                          ),
                        ),
                      ),
                    )
                  : Text('')
            ],
          ),
        ),
        new Pointer(isPlaying: isPlaying),
      ],
    );
  }
}

// 播放器控制器
class PlayerController extends StatefulWidget {
  final Color color;
  PlayerController({this.color: Colors.white});

  @override
  _PlayerControllerState createState() => _PlayerControllerState();
}

class _PlayerControllerState extends State<PlayerController> {
  LyricPanel panel;
  @override
  Widget build(BuildContext context) {
    AudioStore audioStore = AudioStore.of(context);
    PlayerStore player = PlayerStore.of(context);
    Music music = player.music;
    bool isPlaying = audioStore.isPlaying;
    if (panel != null) {
      if (panel.musicId != music.id || panel.platform != music.platform) {
        print("重新加载歌词");
        this.onMusicPanelChanged();
      }
    } else {
      if (isPlaying) {
        print("开始加载歌词");
        this.onMusicPanelChanged();
      }
    }
    return new Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: buildContent(audioStore, player),
      ),
    );
  }

  List<Widget> buildContent(AudioStore audioStore, PlayerStore player) {
    //进度
    double sliderValue;
    if (audioStore.position != null && audioStore.duration != null) {
      sliderValue =
          (audioStore.position.inSeconds / audioStore.duration.inSeconds);
    }
    //播放模式
    final playMode = player.playMode;
    final List<Widget> list = [
      const Divider(color: Colors.transparent),
      const Divider(
        color: Colors.transparent,
        height: 32.0,
      ),
      new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            new IconButton(
              onPressed: () {
                player.setPlayMode(player.playMode.next);
              },
              icon: new Icon(
                playMode.icon,
                size: 32.0,
                color: widget.color,
              ),
            ),
            new IconButton(
              onPressed: () {
                player.previous();
              },
              icon: new Icon(
                Icons.skip_previous,
                size: 32.0,
                color: widget.color,
              ),
            ),
            new IconButton(
              onPressed: player.playHandle,
              padding: const EdgeInsets.all(0.0),
              icon: new Icon(
                audioStore.isPlaying ? Icons.pause : Icons.play_arrow,
                size: 48.0,
                color: widget.color,
              ),
            ),
            new IconButton(
              onPressed: () {
                player.next();
              },
              icon: new Icon(
                Icons.skip_next,
                size: 32.0,
                color: widget.color,
              ),
            ),
            new IconButton(
              onPressed: () {
                PlayingListDialog.show(context);
              },
              icon: new Icon(
                Icons.menu,
                size: 32.0,
                color: widget.color,
              ),
            ),
          ],
        ),
      ),
      new Slider(
        onChanged: (newValue) {
          if (audioStore.duration != null) {
            int seconds = (audioStore.duration.inSeconds * newValue).round();
            audioStore.seek(new Duration(seconds: seconds));
          }
        },
        value: sliderValue ?? 0.0,
        activeColor: widget.color,
      ),
      new Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        child: buildTimer(context, audioStore),
      ),
    ];

    if (panel != null) {
      list.insert(0, panel);
    }

    return list;
  }

  Widget buildTimer(BuildContext context, AudioStore audioStore) {
    final style = new TextStyle(color: widget.color);
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        new Text(
          audioStore.position == null
              ? "--:--"
              : formatDuration(audioStore.position),
          style: style,
        ),
        new Text(
          audioStore.duration == null
              ? "--:--"
              : formatDuration(audioStore.duration),
          style: style,
        ),
      ],
    );
  }

  //格式化时间
  String formatDuration(Duration d) {
    int minute = d.inMinutes;
    int second = (d.inSeconds > 60) ? (d.inSeconds % 60) : d.inSeconds;
    String format = ((minute < 10) ? "0$minute" : "$minute") +
        ":" +
        ((second < 10) ? "0$second" : "$second");
    return format;
  }

  //初始化数据
  resetPanelData() async {
    print("加载歌词");
    PlayerStore player = PlayerStore.of(context, listen: false);
    if (player.music != null) {
      var id = player.music.id;
      print("歌曲平台：" + player.music.platform.toString());
      if (player.music.platform == 1) {
        try {
          //先从文件缓存中查找，没有再发送请求获取
          final lyricCache = await LyricCache.initLyricCache();
          final key = LyricCacheKey(id);
          String cached = await lyricCache.get(key);
          String lrcString;
          // String tlyricString;
          print("缓存中是否有歌词" + (cached != null).toString());
          if (cached != null) {
            lrcString = cached;
          } else {
            var result = await neteaseApi.loadLyric({'id': id});
            Map lyc = result["lrc"];
            if (lyc != null) {
              lrcString = lyc['lyric'];
              //存入文件缓存
              await lyricCache.update(key, lrcString);
            }
            // Map tlyric = result["tlyric"];
            // if (tlyric != null) {
            //   tlyricString = tlyric['lyric'];
            // }
          }
          Lyric lyric = LyricUtil.formatLyric(lrcString);
          setState(() {
            panel = new LyricPanel(
              musicId: player.music.id,
              platform: player.music.platform,
              lyric: lyric,
            );
          });
        } catch (e) {
          print("加载歌词失败");
        }
      }
    }
  }

  //改变歌曲
  onMusicPanelChanged() {
    setState(() {
      panel = null;
    });
    resetPanelData();
  }
}
