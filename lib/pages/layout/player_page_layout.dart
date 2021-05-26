import 'package:flutter/material.dart';
import 'package:cloud_music/widget/bottom_player_bar.dart';

class PlayerPageLayout extends StatefulWidget {
  final Widget child;

  const PlayerPageLayout({
    Key key,
    @required this.child,
  })  : assert(child != null),
        super(key: key);

  @override
  _PlayerPageLayoutState createState() => _PlayerPageLayoutState();
}

class _PlayerPageLayoutState extends State<PlayerPageLayout> {
  OverlayEntry _overlayEntry;

  @override
  void initState() {
    super.initState();
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) =>
          Positioned(bottom: 0, left: 0, right: 0, child: BottomPlayerBar()),
    );
  }

  @override
  void dispose() {
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Overlay(
        initialEntries: [
          OverlayEntry(
            builder: (BuildContext context) => widget.child,
          ),
          _overlayEntry,
        ],
      ),
    );
  }
}
