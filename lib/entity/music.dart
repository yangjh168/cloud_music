import 'package:cloud_music/entity/model.dart';

class Music {
  Music({
    this.platform,
    this.id,
    this.title,
    this.url,
    this.album,
    this.artist,
    int mvId,
  }) : this.mvId = mvId ?? 0;

  final int platform;

  final int id;

  final String title;

  final String url;

  final Album album;

  final List<Artist> artist;

  ///歌曲mv id,当其为0时,表示没有mv
  final int mvId;

  String get imageUrl => album.coverImageUrl;

  String get artistString => artist.map((e) => e.name).join('/');

  String get subTitle {
    var ar = artist.map((a) => a.name).join('/');
    var al = album.name;
    return "$al - $ar";
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Music && platform == other.platform && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Music{platform: $platform, id: $id, title: $title, url: $url, album: $album, artist: $artist}';
  }

  static Music fromMap(Map map) {
    if (map == null) {
      return null;
    }
    return Music(
        platform: map["platform"],
        id: map["id"],
        title: map["title"],
        url: map["url"],
        album: Album.fromMap(map["album"]),
        mvId: map['mvId'] ?? 0,
        artist:
            (map["artist"] as List).cast<Map>().map(Artist.fromMap).toList());
  }

  Music merge({
    int platform,
    int id,
    String title,
    String url,
    Album album,
    List<Artist> artist,
    int mvId,
  }) {
    return Music(
      platform: platform ?? this.platform,
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      album: album ?? this.album,
      artist: artist ?? this.artist,
      mvId: mvId ?? this.mvId,
    );
  }
}

extension MusicExt on Music {
  Map toMap() {
    return {
      "platform": platform,
      "id": id,
      "title": title,
      "url": url,
      "subTitle": subTitle,
      'mvId': mvId,
      "album": album.toMap(),
      "artist": artist.map((e) => e.toMap()).toList()
    };
  }
}
