import 'package:cloud_music/entity/play_queue.dart';
import 'package:hive/hive.dart';
import 'package:cloud_music/music_player/play_mode.dart';
import 'package:cloud_music/entity/music.dart';

const _key_play_queue = "quiet_player_queue";
const _key_current_playing = "quiet_current_playing";
const _key_play_mode = "quiet_play_mode";

extension PlayerActionExtensions on Box {
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
