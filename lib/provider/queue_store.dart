import 'package:cloud_music/entity/music.dart';
import 'package:cloud_music/entity/play_queue.dart';
import 'package:cloud_music/entity/playlist_detail.dart';
import 'package:cloud_music/provider/player_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:cloud_music/hive/extensions.dart';

class QueueStore extends ChangeNotifier {
  // 根据BuildContext获取 [QueueStore]
  static QueueStore of(BuildContext context, {bool listen = true}) {
    return Provider.of<QueueStore>(context, listen: listen);
  }

  // 单例模式
  // 工厂模式
  factory QueueStore() => _getInstance();
  static QueueStore get instance => _getInstance();
  static QueueStore _instance;
  QueueStore._internal() {
    // 初始化
  }
  static QueueStore _getInstance() {
    if (_instance == null) {
      _instance = new QueueStore._internal();
    }
    return _instance;
  }

  //默认队列
  PlayQueue get defaultQueue => this.queueList[0].toPlayQueue();

  //收藏队列
  PlayQueue get favorQueue => this.queueList[1].toPlayQueue();

  //全部队列列表
  List<PlaylistDetail> queueList;

  //默认队列添加歌曲
  defaultQueueAddMusic(Music music) {
    if (!this.queueList[0].musicList.contains(music)) {
      this.queueList[0].musicList.add(music);
      PlayerStore.instance.playerBox.saveSongList(this.queueList);
      notifyListeners();
    }
  }

  //添加队列到歌单列表
  addPlaylistDetail(PlaylistDetail playlistDetail) {
    this.queueList.add(playlistDetail);
    PlayerStore.instance.playerBox.saveSongList(this.queueList);
    notifyListeners();
  }

  //歌单列表删除某队列
  removePlayQueue(PlaylistDetail playlistDetail) {
    this.queueList.remove(playlistDetail);
    PlayerStore.instance.playerBox.saveSongList(this.queueList);
    notifyListeners();
  }
}
