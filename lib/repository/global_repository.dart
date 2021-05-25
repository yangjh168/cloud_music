import 'package:cloud_music/widget/slide_container.dart';
import 'package:flutter/material.dart';

GlobalData globalData = new GlobalData();

class GlobalData {
  GlobalKey<ContainerState> slideKey;

  setSlideKey(key) {
    slideKey = key;
  }

  getSlideKey() {
    return slideKey;
  }
}
