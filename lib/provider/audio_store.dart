import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_music/entity/play_queue.dart';
import 'package:cloud_music/provider/player_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class AudioStore extends ChangeNotifier {
  // 根据BuildContext获取 [AudioStore]
  static AudioStore of(BuildContext context, {bool listen = true}) {
    return Provider.of<AudioStore>(context, listen: listen);
  }

  // 单例模式
  // 工厂模式
  factory AudioStore() => _getInstance();
  static AudioStore get instance => _getInstance();
  static AudioStore _instance;
  AudioStore._internal() {
    // 初始化
    this.initAudioPlayer();
  }
  static AudioStore _getInstance() {
    if (_instance == null) {
      _instance = new AudioStore._internal();
    }
    return _instance;
  }

  // 播放器
  final AudioPlayer audioPlayer = new AudioPlayer();

  // 当前播放状态
  PlayerState status = PlayerState.STOPPED;
  // 当前播放时间
  Duration duration;
  // 音频的当前位置
  Duration position;
  // 播放队列
  PlayQueue playQueue;
  // 音量
  final double volume = 1.0;

  // 当前是否播放状态
  bool get isPlaying => (status == PlayerState.PLAYING);

  //是否播放错误
  bool isError = false;

  // 初始化播放器的监听事件
  void initAudioPlayer() {
    audioPlayer
      //音频播放完毕事件
      ..onPlayerCompletion.listen((void s) {
        if (!this.isError) {
          print("播放完成，开始下一首");
          if (PlayerStore.instance != null) PlayerStore.instance.next();
        }
      })
      // 改变状态事件
      ..onPlayerStateChanged.listen((PlayerState state) {
        print("播放器状态改变");
        this.status = state;
        notifyListeners();
      })
      // 播放错误事件
      ..onPlayerError.listen((String e) {
        this.isError = true;
        Fluttertoast.showToast(
          msg: "播放错误",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
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

    //初始化完audioPlayer，触发更新
    notifyListeners();
  }

  //开始播放
  play(music, {bool isLocal = true}) async {
    audioPlayer.stop();
    print("开始播放，歌曲链接：" + music.url.toString());
    String path;
    var info = await DefaultCacheManager().getFileFromCache(music.url);
    print("缓存中是否有该歌曲：" + (info != null).toString());
    if (info != null) {
      path = info.file.path;
    } else {
      var file = await DefaultCacheManager().getSingleFile(music.url);
      path = file.dirname + '/' + file.basename;
    }
    print("本地歌曲链接：" + path);
    if (path != null) {
      this.isError = false;
      audioPlayer.play(
        path,
        isLocal: isLocal,
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
    // if ((status == PlayerState.STOPPED ||
    //         status == PlayerState.COMPLETED) &&
    //     this.music != null) {
    //   start();
    // } else
    if (status == PlayerState.PLAYING) {
      pause();
    } else if (status == PlayerState.PAUSED) {
      resume();
    }
  }
}
