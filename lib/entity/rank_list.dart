class RankList {
  int id;
  String name;
  List<Tracks> tracks;
  String updateFrequency;
  String coverImgUrl;

  RankList(
      {this.id,
      this.name,
      this.tracks,
      this.updateFrequency,
      this.coverImgUrl});

  RankList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    if (json['tracks'] != null) {
      tracks = new List<Tracks>();
      json['tracks'].forEach((v) {
        tracks.add(new Tracks.fromJson(v));
      });
    }
    updateFrequency = json['updateFrequency'];
    coverImgUrl = json['coverImgUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    if (this.tracks != null) {
      data['tracks'] = this.tracks.map((v) => v.toJson()).toList();
    }
    data['updateFrequency'] = this.updateFrequency;
    data['coverImgUrl'] = this.coverImgUrl;
    return data;
  }
}

class Tracks {
  String first;
  String second;

  Tracks({this.first, this.second});

  Tracks.fromJson(Map<String, dynamic> json) {
    first = json['first'];
    second = json['second'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['first'] = this.first;
    data['second'] = this.second;
    return data;
  }
}
