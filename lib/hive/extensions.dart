import 'package:cloud_music/entity/play_queue.dart';
import 'package:cloud_music/entity/playlist_detail.dart';
import 'package:hive/hive.dart';
import 'package:cloud_music/music_player/play_mode.dart';
import 'package:cloud_music/entity/music.dart';

const _key_queue_list = "quiet_queue_list";
const _key_play_queue = "quiet_player_queue";
const _key_current_playing = "quiet_current_playing";
const _key_play_mode = "quiet_play_mode";

extension PlayerActionExtensions on Box {
  //所有歌单列表
  void saveSongList(List<PlaylistDetail> queueList) {
    List<Map> list = queueList.map<Map>((item) => item.toMap()).toList();
    put(_key_queue_list, list);
  }

  List<PlaylistDetail> getSongList() {
    final queueList = get(_key_queue_list);
    if (queueList == null) {
      return [
        PlaylistDetail(
            0,
            '默认列表',
            [],
            'https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3566088443,3713209594&fm=26&gp=0.jpg',
            null,
            0,
            '',
            false,
            0,
            0,
            0,
            0),
        PlaylistDetail(
            0,
            '收藏列表',
            [],
            'https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3566088443,3713209594&fm=26&gp=0.jpg',
            null,
            0,
            '',
            false,
            0,
            0,
            0,
            0),
      ];
    } else {
      List<PlaylistDetail> list = (queueList as List)
          ?.cast<Map>()
          ?.map<PlaylistDetail>((item) => PlaylistDetail.fromMap(item))
          ?.toList();
      return list;
    }
  }

  //播放队列
  void savePlayQueue(PlayQueue playQueue) {
    put(_key_play_queue, playQueue.toMap());
  }

  PlayQueue getPlayQueue() {
    final playQueue = get(_key_play_queue);
    if (playQueue == null) {
      return new PlayQueue(queueId: 0, queueTitle: '默认队列', queue: []);
    } else {
      return PlayQueue.fromMap(playQueue);
    }
  }

  //当前播放的音乐
  void saveCurrentMusic(Music music) {
    put(_key_current_playing, music.toMap());
  }

  Music getCurrentMusic() {
    final map = get(_key_current_playing);
    if (map == null) {
      return null;
    } else {
      return Music.fromMap(map);
    }
  }

  //播放模式
  void savePlayMode(PlayMode mode) {
    put(_key_play_mode, {"mode": mode.index});
  }

  PlayMode getPlayMode() {
    final map = get(_key_play_mode);
    if (map == null) {
      return PlayMode.sequence;
    } else {
      int mode = map["mode"] ?? PlayMode.sequence.index;
      return PlayMode(mode);
    }
  }
}
