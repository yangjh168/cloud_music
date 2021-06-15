import 'package:cloud_music/entity/model.dart';
import 'package:cloud_music/entity/music.dart';
import 'package:cloud_music/entity/play_queue.dart';
// import 'package:cloud_music/repository/netease.dart';

Music mapJsonToMusic(Map song,
    {String artistKey = "artists", String albumKey = "album"}) {
  Map album = song[albumKey] as Map;

  List<Artist> artists = (song[artistKey] as List).cast<Map>().map((e) {
    return Artist(
      name: e["name"],
      id: e["id"],
    );
  }).toList();

  return Music(
      platform: song["platform"],
      id: song["id"],
      title: song["name"],
      mvId: song['mv'] ?? 0,
      url: "http://music.163.com/song/media/outer/url?id=${song["id"]}.mp3",
      album: Album(
          id: album["id"], name: album["name"], coverImageUrl: album["picUrl"]),
      artist: artists);
}

List<Music> mapJsonListToMusicList(List tracks,
    {String artistKey = "artists", String albumKey = "album"}) {
  if (tracks == null) {
    return null;
  }
  var list = tracks
      .cast<Map>()
      .map((e) => mapJsonToMusic(e, artistKey: artistKey, albumKey: albumKey));
  return list.toList();
}

class PlaylistDetail {
  PlaylistDetail(
    this.id,
    this.name,
    this.musicList,
    this.coverUrl,
    this.creator,
    this.trackCount,
    this.description,
    this.subscribed,
    this.subscribedCount,
    this.commentCount,
    this.shareCount,
    this.playCount,
  );

  ///null when playlist not complete loaded
  final List<Music> musicList;

  String name;

  String coverUrl;

  int id;

  int trackCount;

  String description;

  bool subscribed;

  int subscribedCount;

  int commentCount;

  int shareCount;

  int playCount;

  bool get loaded =>
      trackCount == 0 || (musicList != null && musicList.length == trackCount);

  ///tag fro hero transition
  String get heroTag => "playlist_hero_$id";

  ///
  /// properties:
  /// avatarUrl , nickname
  ///
  final Map creator;

  static PlaylistDetail fromJson(Map playlist) {
    return PlaylistDetail(
        playlist["id"],
        playlist["name"],
        mapJsonListToMusicList(playlist["tracks"],
            artistKey: "ar", albumKey: "al"),
        playlist["coverImgUrl"],
        playlist["creator"],
        playlist["trackCount"],
        playlist["description"],
        playlist["subscribed"],
        playlist["subscribedCount"],
        playlist["commentCount"],
        playlist["shareCount"],
        playlist["playCount"]);
  }

  static PlaylistDetail fromMap(Map map) {
    if (map == null) {
      return null;
    }
    return PlaylistDetail(
      map['id'],
      map['name'],
      (map['musicList'] as List)
          ?.cast<Map>()
          ?.map((m) => Music.fromMap(m))
          ?.toList(),
      map['coverUrl'],
      map['creator'],
      map['trackCount'],
      map['description'],
      map['subscribed'],
      map['subscribedCount'],
      map['commentCount'],
      map['shareCount'],
      map['playCount'],
    );
  }

  Map toMap() {
    return {
      'id': id,
      'name': name,
      'musicList': musicList?.map((m) => m.toMap())?.toList(),
      'coverUrl': coverUrl,
      'creator': creator,
      'trackCount': trackCount,
      'description': description,
      'subscribed': subscribed,
      'subscribedCount': subscribedCount,
      'commentCount': commentCount,
      'shareCount': shareCount,
      'playCount': playCount
    };
  }

  PlayQueue toPlayQueue() {
    return PlayQueue(
      queueId: this.id,
      queueTitle: this.name,
      queue: this.musicList,
    );
  }
}
