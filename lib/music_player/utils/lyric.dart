import 'dart:core';
import 'package:cloud_music/model/lyric.dart';

RegExp reg = new RegExp(r'(\[\d\d:\d\d.*\])');

class LyricUtilTextModel {
  final int time;
  final String text;
  LyricUtilTextModel(this.time, this.text);
}

class LyricUtilMapValueModel {
  String lrc;
  String tlyric;
  LyricUtilMapValueModel(this.lrc, this.tlyric);
}

class LyricUtil {
  static Lyric formatLyric(String lrcString) {
    final map = new Map<int, LyricUtilMapValueModel>();
    for (String line in lrcString.split('\n')) {
      if (line == null || line == '') {
        continue;
      }
      LyricUtilTextModel v = getLyric(line);
      if (v.time == -1) {
        continue;
      }
      map[v.time] = new LyricUtilMapValueModel(v.text, '');
    }
    // if (tlyricString != null) {
    //   for (String line in tlyricString.split('\n')) {
    //     if (line == null || line == '') {
    //       continue;
    //     }
    //     LyricUtilTextModel v = getLyric(line);
    //     if (v.time == -1) {
    //       continue;
    //     }
    //     if (map[v.time] != null) {
    //       map[v.time].tlyric = v.text;
    //     }
    //   }
    // }
    final list = new List<LyricModel>();
    map.forEach((key, value) {
      LyricModel v = new LyricModel(key, value.lrc, value.tlyric);
      list.add(v);
    });
    return new Lyric(list);
  }

  static LyricUtilTextModel getLyric(String line) {
    Iterable<Match> matches = reg.allMatches(line);
    if (matches.isEmpty) {
      return new LyricUtilTextModel(-1, '');
    }
    String matchString = matches.elementAt(0).group(0);
    String lyricText = line.replaceAll(matchString, '');
    String timeString = matchString.replaceAll('[', '').replaceAll(']', '');
    String m = timeString.split(':')[0];
    String s = timeString.split(':')[1].split('.')[0];
    String ms = timeString.split(':')[1].split('.')[1];
    int time = int.parse(m) * 60 * 1000 + int.parse(s) * 1000 + int.parse(ms);
    return new LyricUtilTextModel(time, lyricText);
  }
}
