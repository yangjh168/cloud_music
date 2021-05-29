import 'package:cloud_music/provider/audio_store.dart';
import 'package:flutter/material.dart';
import 'package:cloud_music/model/lyric.dart';

typedef void PositionChangeHandler(int millisecond);

class LyricPanel extends StatefulWidget {
  final int musicId;

  final int platform;

  final Lyric lyric;

  LyricPanel({this.musicId, this.platform, this.lyric});

  @override
  State<StatefulWidget> createState() {
    return new LyricState();
  }
}

class LyricState extends State<LyricPanel> {
  int index = 0;
  LyricModel currentModel;

  @override
  void initState() {
    super.initState();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    AudioStore audioStore = AudioStore.of(context);
    this.onAudioPositionChanged(audioStore);
    return new Container(
      child: new Center(
        child: new Container(
          padding: EdgeInsets.only(bottom: 10.0),
          child: Column(
            children: <Widget>[
              Text(
                currentModel != null ? currentModel.lrc : "",
                style: new TextStyle(
                  color: Colors.white,
                ),
              ),
              Text(
                currentModel != null ? currentModel.tlyric : "",
                style: new TextStyle(
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildLyricItems(Lyric lyric) {
    List<Widget> items = new List();
    for (LyricModel model in lyric.list) {
      if (model != null && model.lrc != null) {
        items.add(new Center(
          child: new Container(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text(
              model.lrc,
              style: new TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ));
      }
    }
    return items;
  }

  resetIndex(audioStore) {
    if (audioStore.position != null) {
      int ms = audioStore.position.inMilliseconds;
      for (int i = 0; i < widget.lyric.list.length; i++) {
        LyricModel model = widget.lyric.list[i];
        if (ms >= model.millisecond) {
          index = i;
        } else {
          break;
        }
      }
      setState(() {
        currentModel = widget.lyric.list[index];
      });
    }
  }

  onAudioPositionChanged(audioStore) {
    if (audioStore.position != null) {
      int ms = audioStore.position.inMilliseconds;
      // ms 在前一个之前或者后一个之后，就需要重新定位index了
      if ((index > 0 && ms <= widget.lyric.list[index - 1].millisecond) ||
          (index < widget.lyric.list.length - 1 &&
              ms >= widget.lyric.list[index + 1].millisecond)) {
        resetIndex(audioStore);
        return;
      }
      LyricModel model = widget.lyric.list[index];
      if (ms > model.millisecond) {
        if (index < widget.lyric.list.length - 1) index++;
        setState(() {
          currentModel = model;
        });
      }
    }
  }
}
