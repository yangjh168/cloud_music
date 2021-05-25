import 'package:cloud_music/Cache/lyric_cache.dart';
import 'package:cloud_music/api/netease.dart';
import 'package:cloud_music/entity/music.dart';
import 'package:cloud_music/model/lyric.dart';
import 'package:cloud_music/music_player/playing_list.dart';
import 'package:cloud_music/music_player/utils/lyric.dart';
import 'package:cloud_music/music_player/widget/lyricPannel.dart';
import 'package:cloud_music/provider/player_store.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'animate/pointer.dart';
import 'animate/disc.dart';
import 'package:flutter/scheduler.dart';

class PlayerPage extends StatefulWidget {
  final Color color;

  PlayerPage({this.color: Colors.white});

  @override
  State<StatefulWidget> createState() => new PlayerPageState();
}

class PlayerPageState extends State<PlayerPage> with TickerProviderStateMixin {
  LyricPanel panel;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      // resetPanelData();
      // player.onDurationChanged(this.onDurationChanged);
      // player.onAudioPositionChanged(this.onAudioPositionChanged);
      // player.onStatusChanged(this.onPlayerStatus);
      // player.onError(this.onError);
      // player.onMusicChanged(this.onMusicChanged);
      // player.onCompleted(this.onPlayerCompleted);
    });
  }

  @override
  void deactivate() {
    // player.offDurationChanged(this.onDurationChanged);
    // player.offAudioPositionChanged(this.onAudioPositionChanged);
    // player.offStatusChanged(this.onPlayerStatus);
    // player.offError(this.onError);
    // player.offMusicChanged(this.onMusicChanged);
    // player.offCompleted(this.onPlayerCompleted);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    PlayerStore player = PlayerStore.of(context);
    Music music = player.music;
    if (music == null) {
      return Container();
    }
    bool isPlaying = player.isPlaying;
    if (panel != null) {
      if (panel.musicId != music.id || panel.platform != music.platform) {
        print("重新加载歌词");
        print(panel.musicId != music.id);
        print(panel.platform != music.platform);
        this.onMusicPanelChanged();
      }
    } else {
      if (isPlaying) {
        print("开始加载歌词");
        this.onMusicPanelChanged();
      }
    }
    return Stack(
      children: <Widget>[
        new Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: NetworkImage(music.album.coverImageUrl),
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
              Stack(
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
                                        image: AssetImage(
                                            "assets/images/play.png"),
                                      ),
                                    ),
                                  ),
                                )
                              : Text('')
                        ],
                      )),
                  new Pointer(isPlaying: isPlaying),
                ],
              ),
              new Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: buildPannel(context, player),
              ),
            ],
          ),
        ),
      ],
    );
  }

  //初始化数据
  resetPanelData() async {
    print("加载歌词");
    PlayerStore player = PlayerStore.of(context, listen: false);
    if (player.music != null) {
      var id = player.music.id;
      if (player.music.platform == 1) {
        try {
          //先从文件缓存中查找，没有再发送请求获取
          final lyricCache = await LyricCache.initLyricCache();
          final key = LyricCacheKey(id);
          String cached = await lyricCache.get(key);
          String lrcString;
          // String tlyricString;
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
                lyric: lyric);
          });
        } catch (e) {
          print("加载歌词失败");
        }
      }
    }
  }

  //持续时间事件
  // onDurationChanged(Duration duration) {
  //   setState(() {
  //     this.duration = duration;
  //     if (position != null) {
  //       this.sliderValue = (position.inSeconds / duration.inSeconds);
  //     }
  //   });
  // }

  // // 更新音频的当前位置事件
  // onAudioPositionChanged(Duration position) {
  //   setState(() {
  //     this.position = position;

  //     if (duration != null) {
  //       this.sliderValue = (position.inSeconds / duration.inSeconds);
  //     }
  //   });
  // }

  // //播放错误事件
  // onError(String e) {
  //   Scaffold.of(context).showSnackBar(
  //     new SnackBar(
  //       content: new Text(e),
  //     ),
  //   );
  // }

  //改变歌曲
  onMusicPanelChanged() {
    setState(() {
      panel = null;
    });
    resetPanelData();
  }

  // // 音频播放完毕事件
  // onPlayerCompleted() {
  //   print('onPlayerCompleted =======================');
  //   player.next();
  // }

  Widget buildPannel(BuildContext context, PlayerStore player) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: buildContent(context, player),
    );
  }

  List<Widget> buildContent(BuildContext context, PlayerStore player) {
    //进度
    double sliderValue;
    if (player.position != null && player.duration != null) {
      sliderValue = (player.position.inSeconds / player.duration.inSeconds);
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
                player.isPlaying ? Icons.pause : Icons.play_arrow,
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
          if (player.duration != null) {
            int seconds = (player.duration.inSeconds * newValue).round();
            player.seek(new Duration(seconds: seconds));
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
        child: buildTimer(context, player),
      ),
    ];

    if (panel != null) {
      list.insert(0, panel);
    }

    return list;
  }

  Widget buildTimer(BuildContext context, PlayerStore player) {
    final style = new TextStyle(color: widget.color);
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        new Text(
          player.position == null ? "--:--" : formatDuration(player.position),
          style: style,
        ),
        new Text(
          player.duration == null ? "--:--" : formatDuration(player.duration),
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
}
