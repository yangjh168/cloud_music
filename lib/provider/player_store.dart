import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_music/api/netease.dart';
import 'package:cloud_music/entity/music.dart';
import 'package:cloud_music/entity/play_queue.dart';
import 'package:cloud_music/music_player/play_mode.dart';
// import 'package:cloud_music/music_player/player_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:cloud_music/hive/extensions.dart';

class PlayerStore extends ChangeNotifier {
  // 根据BuildContext获取 [PlayerStore]
  static PlayerStore of(BuildContext context, {bool listen = true}) {
    return Provider.of<PlayerStore>(context, listen: listen);
  }

  // 播放器
  final AudioPlayer audioPlayer = new AudioPlayer();
  // 当前播放音乐
  Music music;
  // 当前播放状态
  AudioPlayerState status = AudioPlayerState.STOPPED;
  // 当前播放时间
  Duration duration;
  // 音频的当前位置
  Duration position;
  // 播放队列
  PlayQueue playQueue;
  // 音量
  final double volume = 1.0;
  // 是否是本地资源
  final bool isLocal = false;
  // 当前是否播放状态
  bool get isPlaying => (status == AudioPlayerState.PLAYING);
  // 播放模式
  PlayMode playMode;

  Box playerBox;

  // 构造函数
  PlayerStore(Box playerBox) {
    this.playerBox = playerBox;
    this.initAudioPlayer();
  }
  // 初始化播放器的监听事件
  void initAudioPlayer() {
    audioPlayer
      //音频播放完毕事件
      ..onPlayerCompletion.listen((void s) {
        next();
        notifyListeners();
      })
      // 改变状态事件
      ..onPlayerStateChanged.listen((AudioPlayerState state) {
        print("播放器状态改变");
        this.status = state;
        notifyListeners();
      })
      // 播放错误事件
      ..onPlayerError.listen((String e) {
        print("播放错误");
        notifyListeners();
      })
      //持续时间事件
      ..onDurationChanged.listen((value) {
        this.duration = value;
        notifyListeners();
      })
      //更新音频的当前位置事件
      ..onAudioPositionChanged.listen((value) {
        this.position = value;
        notifyListeners();
      });

    //初始默认播放模式
    // this.playMode = PlayMode.sequence;
    this.playMode = this.playerBox.getPlayMode();
    this.playQueue = this.playerBox.getPlayQueue();
    this.music = this.playerBox.getCurrentMusic();
    print("初始化playMode:" + this.playMode.toString());
    print("初始化playQueue:" + this.playQueue.toString());
    print("初始化music:" + this.music.toString());
    //初始化完audioPlayer，触发更新
    notifyListeners();
  }

  // PlayerController transportControls = PlayerController(this);

  //准备播放
  play({int id, int platform, PlayQueue playQueue}) async {
    print("播放音乐：" + id.toString() + platform.toString());

    var playable =
        await neteaseApi.checkMusic({'id': id, 'platform': platform});
    if (playable == null) {
      print("音乐不可用");
      // showDialog(context: context, builder: (context) => DialogNoCopyRight());
      return;
    }

    final res =
        await neteaseApi.getMusicDetail({'id': id, 'platform': platform});
    Music music = Music.fromMap(res);

    if (playQueue != null) {
      this.playQueue = playQueue;
    } else {
      if (this.playQueue.queue.indexOf(music) == -1) {
        this.playQueue.queue.add(music);
      }
    }
    this.playerBox.savePlayQueue(this.playQueue);
    if (music != null) {
      this.music = music;
      this.playerBox.saveCurrentMusic(music);
    }
    start();
  }

  //开始播放
  start() {
    if (this.music != null) {
      audioPlayer.play(
        this.music.url,
        isLocal: this.isLocal,
        volume: this.volume,
      );
    }
  }

  //暂停
  pause() {
    audioPlayer.pause();
  }

  //继续播放
  resume() {
    audioPlayer.resume();
  }

  // 跳过音频
  seek(Duration d) {
    audioPlayer.seek(d);
  }

  //处理播放、暂停按钮事件
  playHandle() {
    if ((status == AudioPlayerState.STOPPED ||
            status == AudioPlayerState.COMPLETED) &&
        this.music != null) {
      start();
    } else if (status == AudioPlayerState.PLAYING) {
      pause();
    } else if (status == AudioPlayerState.PAUSED) {
      resume();
    }
  }

  //处理上一首按钮事件
  previous() {
    print("上一首");
    if (this.playQueue.queue.isEmpty) {
      return;
    }
    int index = this.playQueue.queue.indexOf(music);
    if (index == -1) {
      return;
    }
    int i = index - 1;
    if (i < 0) {
      i = this.playQueue.queue.length - 1;
    }
    play(
        id: this.playQueue.queue[i].id,
        platform: this.playQueue.queue[i].platform);
  }

  //处理下一首按钮事件
  next() {
    print("下一首");
    if (this.playQueue.queue == null) {
      return;
    }
    int index = this.playQueue.queue.indexOf(music);
    if (index == -1) {
      return;
    }
    int i = index + 1;
    if (i >= this.playQueue.queue.length) {
      i = 0;
    }
    play(
        id: this.playQueue.queue[i].id,
        platform: this.playQueue.queue[i].platform);
  }

  //设置播放模式
  setPlayMode(PlayMode mode) {
    this.playMode = mode;
    this.playerBox.savePlayMode(mode);
  }

  //歌单队列添加歌曲
  queueAddMusic(Music music) {
    print("添加歌曲到队列");
    this.playQueue.queue.add(music);
    this.playerBox.savePlayQueue(this.playQueue);
  }

  //歌单队列删除歌曲
  queueRemoveMusic(Music music) {
    this.playQueue.queue.remove(music);
    this.playerBox.savePlayQueue(this.playQueue);
  }
}
