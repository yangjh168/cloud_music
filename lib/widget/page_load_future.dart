import 'package:flutter/material.dart';
import 'dart:async';

class PageLoadFuture extends StatefulWidget {
  final List<Future> futures;

  final Function(BuildContext context, List<dynamic> data) builder;

  const PageLoadFuture(
      {Key key, @required this.futures, @required this.builder})
      : super(key: key);

  @override
  _PageLoadFutureState createState() => _PageLoadFutureState();
}

class _PageLoadFutureState extends State<PageLoadFuture> {
  List _data;

  @override
  void initState() {
    super.initState();
    Future.wait(widget.futures).then((data) {
      setState(() {
        _data = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) {
      return Container(
        constraints: BoxConstraints(minHeight: 200),
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 1),
        ),
      );
    }
    return widget.builder(context, _data);
  }
}
