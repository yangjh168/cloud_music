import 'dart:io';

import 'package:cloud_music/Cache/key_value_cache.dart';
import 'package:path_provider/path_provider.dart';

///cache key for lyric
class LyricCacheKey implements CacheKey {
  final int musicId;

  LyricCacheKey(this.musicId) : assert(musicId != null);

  @override
  String getKey() {
    return musicId.toString();
  }
}

LyricCache lyricCache;

class LyricCache implements Cache<String> {
  LyricCache._(Directory dir)
      : provider =
            FileCacheProvider(dir, maxSize: 20 * 1024 * 1024 /* 20 Mb */);

  final FileCacheProvider provider;

  static Future<LyricCache> initLyricCache() async {
    if (lyricCache != null) {
      return lyricCache;
    }
    var temp = await getTemporaryDirectory();
    var dir = Directory(temp.path + "/lyrics/");
    if (!(await dir.exists())) {
      dir = await dir.create();
    }
    lyricCache = LyricCache._(dir);
    return lyricCache;
  }

  @override
  Future<String> get(CacheKey key) async {
    final file = provider.getFile(key);
    if (await file.exists()) {
      return file.readAsStringSync();
    }
    provider.touchFile(file);
    return null;
  }

  @override
  Future<bool> update(CacheKey key, String t) async {
    var file = provider.getFile(key);
    if (await file.exists()) {
      file.delete();
    }
    file = await file.create();
    await file.writeAsString(t);
    try {
      return await file.exists();
    } finally {
      provider.checkSize();
    }
  }
}
