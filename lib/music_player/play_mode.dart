import 'package:flutter/material.dart';

// 播放模式
class PlayMode {
  final int index;

  const PlayMode._internal(this.index);

  static const shuffle = PlayMode._internal(0);
  static const single = PlayMode._internal(1);
  static const sequence = PlayMode._internal(2);

  factory PlayMode.undefined(int index) {
    assert(!const [0, 1, 2].contains(index), "index can not be 0,1,2");
    return PlayMode(index);
  }

  factory PlayMode(int index) {
    if (index == 0) {
      return shuffle;
    } else if (index == 1) {
      return single;
    } else if (index == 2) {
      return sequence;
    } else {
      return PlayMode._internal(index);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PlayMode && index == other.index;

  @override
  int get hashCode => index.hashCode;

  @override
  String toString() {
    switch (index) {
      case 0:
        return "PlayMode.shuffle";
      case 1:
        return "PlayMode.single";
      case 2:
        return "PlayMode.sequence";
      default:
        return "PlayMode.undefined($index)";
    }
  }

  PlayMode get next {
    if (this == PlayMode.sequence) {
      return PlayMode.shuffle;
    } else if (this == PlayMode.shuffle) {
      return PlayMode.single;
    } else {
      return PlayMode.sequence;
    }
  }

  IconData get icon {
    if (this == PlayMode.single) {
      return Icons.repeat_one;
    } else if (this == PlayMode.shuffle) {
      return Icons.shuffle;
    } else {
      return Icons.repeat;
    }
  }

  String get name {
    if (this == PlayMode.single) {
      return "单曲循环";
    } else if (this == PlayMode.shuffle) {
      return "随机播放";
    } else {
      return "列表循环";
    }
  }
}
