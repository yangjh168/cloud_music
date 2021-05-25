class SongMenu {
  int id;
  String name;
  String picUrl;
  int playCount;

  SongMenu({this.id, this.name, this.picUrl, this.playCount});

  SongMenu.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    picUrl = json['picUrl'];
    playCount = json['playCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['picUrl'] = this.picUrl;
    data['playCount'] = this.playCount;
    return data;
  }
}
