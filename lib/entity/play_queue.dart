import 'package:cloud_music/entity/music.dart';
import 'package:flutter/cupertino.dart';

class PlayQueue {
  final int queueId;

  /// nullable
  final String queueTitle;

  /// nullable
  final Map extras;

  final List<Music> queue;

  bool get isEmpty => queue.isEmpty;

  const PlayQueue(
      {@required this.queueId,
      @required this.queueTitle,
      this.extras,
      @required this.queue})
      : assert(queueId != null),
        assert(queueTitle != null),
        assert(queue != null);

  factory PlayQueue.fromMap(Map map) {
    return PlayQueue(
      queueId: map['queueId'],
      queueTitle: map['queueTitle'],
      extras: map['extras'],
      queue: (map['queue'] as List)
          .cast<Map>()
          .map((e) => Music.fromMap(e))
          .toList(),
    );
  }

  Map toMap() {
    return {
      "queueId": queueId,
      "queueTitle": queueTitle,
      "extras": extras,
      "queue": queue.map((e) => e.toMap()).toList(),
    };
  }

  const PlayQueue.empty()
      : this(
            queueId: 0, queueTitle: "empty", queue: const [], extras: const {});
}
