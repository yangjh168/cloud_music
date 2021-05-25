import 'package:flutter/material.dart';

class PlatformLogo extends StatelessWidget {
  final int platform;

  const PlatformLogo({Key key, this.platform}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: buildLogo(),
      width: 20,
      height: 20,
    );
  }

  Widget buildLogo() {
    if (platform == 2) {
      return Image.asset('images/logo_kugou.jpg');
    } else if (platform == 3) {
      return Image.asset('images/logo_kuwo.jpg');
    } else {
      return Image.asset('images/icon_logo.png');
    }
  }
}
