import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DiscAnimate extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  DiscAnimate(
      {@required Widget this.child,
      @required Animation<double> this.animation});

  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (BuildContext ctx, Widget child) {
        return Column(
          children: <Widget>[
            Container(
              margin: new EdgeInsets.symmetric(vertical: 10.0),
              child: RotationTransition(
                turns: animation,
                child: child,
              ),
            )
          ],
        );
      },
    );
  }
}

class Disc extends StatefulWidget {
  final String cover;
  final bool isPlaying;

  Disc({@required this.isPlaying, @required this.cover});

  @override
  State<StatefulWidget> createState() => new DiscState();
}

class DiscState extends State<Disc> with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;

  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(seconds: 10), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.linear);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.repeat();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isPlaying) {
      controller.forward();
    } else {
      controller.stop(canceled: false);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 68.0),
      child: DiscAnimate(
        animation: animation,
        child: Container(
          height: 420.0.h,
          width: 420.0.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              alignment: Alignment.topCenter,
              image: AssetImage("assets/images/disc.png"),
            ),
          ),
          child: Center(
            child: Container(
              height: 270.0.h,
              width: 270.0.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  alignment: Alignment.topCenter,
                  image: CachedNetworkImageProvider(widget.cover),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  dispose() {
    //路由销毁时需要释放动画资源
    controller.dispose();
    super.dispose();
  }
}
