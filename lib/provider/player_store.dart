import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_music/api/common.dart';
import 'package:cloud_music/entity/music.dart';
import 'package:cloud_music/entity/play_queue.dart';
import 'package:cloud_music/entity/playlist_detail.dart';
import 'package:cloud_music/music_player/play_mode.dart';
import 'package:cloud_music/provider/audio_store.dart';
import 'package:cloud_music/provider/queue_store.dart';
// import 'package:cloud_music/music_player/player_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:cloud_music/hive/extensions.dart';

class PlayerStore extends ChangeNotifier {
  // 根据BuildContext获取 [PlayerStore]
  static PlayerStore of(BuildContext context, {bool listen = true}) {
    return Provider.of<PlayerStore>(context, listen: listen);
  }

  // 单例模式
  // 工厂模式
  factory PlayerStore(Box playerBox) => _getInstance(playerBox);
  static PlayerStore get instance => _getInstance();
  static PlayerStore _instance;
  PlayerStore._internal(Box playerBox) {
    // 初始化
    this.playerBox = playerBox;
    this.initAudioPlayer();
  }
  static PlayerStore _getInstance([Box playerBox]) {
    if (_instance == null) {
      assert(playerBox != null, "PlayerStore还没初始化，请先提供playerBox进行初始化");
      _instance = new PlayerStore._internal(playerBox);
    }
    return _instance;
  }

  // 当前播放音乐
  Music music;
  // 是否是本地资源
  final bool isLocal = false;

  // 当前播放队列
  PlayQueue playQueue;

  // 播放模式
  PlayMode playMode;

  //hive操作对象
  Box playerBox;

  void initAudioPlayer() {
    //初始默认播放模式
    this.playMode = this.playerBox.getPlayMode();
    this.playQueue = this.playerBox.getPlayQueue();
    this.music = this.playerBox.getCurrentMusic();
    QueueStore.instance.queueList = this.playerBox.getSongList();
    // print("初始化playMode:" + this.playMode.toString());
    // print("初始化playQueue:" + this.playQueue.toString());
    // print("初始化music:" + this.music.toString());
    //初始化完audioPlayer，触发更新
    notifyListeners();
  }

  //准备播放
  play(
      {Music music, PlaylistDetail playlistDetail, PlayQueue playQueue}) async {
    var _muisc = music;
    print("播放音乐：" +
        _muisc.title +
        "，id：" +
        _muisc.id.toString() +
        "，平台：" +
        _muisc.platform.toString());
    if (_muisc.url == null) {
      var playable = await commonApi
          .checkMusic({'id': _muisc.id, 'platform': _muisc.platform});
      if (playable == null) {
        Fluttertoast.showToast(
          msg: "音乐不可用",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
        return;
      }
      final res = await commonApi
          .getMusicDetail({'id': _muisc.id, 'platform': _muisc.platform});
      Music newMusic = Music.fromMap(res);
      _muisc = newMusic;
    }
    if (playlistDetail != null) {
      QueueStore.instance.addPlaylistDetail(playlistDetail);
      this.playQueue = playlistDetail.toPlayQueue();
    } else if (playQueue != null) {
      this.playQueue = playQueue;
    } else {
      QueueStore.instance.defaultQueueAddMusic(_muisc);
      this.playQueue = QueueStore.instance.defaultQueue;
    }
    this.playerBox.savePlayQueue(this.playQueue);
    if (_muisc != null) {
      this.music = _muisc;
      this.playerBox.saveCurrentMusic(_muisc);
      start();
    }
    notifyListeners();
  }

  //开始播放
  start() {
    AudioStore.instance.play(music);
  }

  //暂停
  pause() {
    AudioStore.instance.pause();
  }

  //继续播放
  resume() {
    AudioStore.instance.resume();
  }

  //处理播放、暂停按钮事件
  playHandle() {
    PlayerState status = AudioStore.instance.status;
    if ((status == PlayerState.STOPPED || status == PlayerState.COMPLETED) &&
        this.music != null) {
      start();
    } else if (status == PlayerState.PLAYING) {
      pause();
    } else if (status == PlayerState.PAUSED) {
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
    play(music: this.playQueue.queue[i], playQueue: this.playQueue);
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
    play(music: this.playQueue.queue[i], playQueue: this.playQueue);
  }

  //设置播放模式
  setPlayMode(PlayMode mode) {
    this.playMode = mode;
    this.playerBox.savePlayMode(mode);
    notifyListeners();
  }

  //歌单队列添加歌曲
  queueAddMusic(Music music) {
    print("添加歌曲到队列");
    this.playQueue.queue.add(music);
    this.playerBox.savePlayQueue(this.playQueue);
    notifyListeners();
  }

  //歌单队列删除歌曲
  queueRemoveMusic(Music music) {
    this.playQueue.queue.remove(music);
    this.playerBox.savePlayQueue(this.playQueue);
    notifyListeners();
  }

  //下一首播放
  nextPlay(Music music) {
    //如果队列中存在该歌曲，则删除后再在指定位置插入
    if (this.playQueue.queue.indexOf(music) != -1) {
      this.playQueue.queue.remove(music);
    }
    int index = this.playQueue.queue.indexOf(this.music);
    if (index != -1) {
      this.playQueue.queue.insert(index + 1, music);
      this.playerBox.savePlayQueue(this.playQueue);
      notifyListeners();
    } else {
      this.play(music: music, playQueue: this.playQueue);
    }
  }
}
