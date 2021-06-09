import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CacheImage extends StatelessWidget {
  //图片链接
  final String url;
  //圆角
  final BorderRadius borderRadius;

  final BoxFit fit;

  const CacheImage({Key key, @required this.url, this.borderRadius, this.fit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: _buildCachedImage(),
      );
    } else {
      return _buildCachedImage();
    }
  }

  Widget _buildCachedImage() {
    return CachedNetworkImage(
      imageUrl: url,
      placeholder: (context, url) => Container(
        color: Color(0XFFf7f8fa),
        child: Center(
          child: Icon(Icons.image_outlined, size: 48.sp),
        ),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
      fit: fit != null ? fit : BoxFit.cover,
    );
  }
}
