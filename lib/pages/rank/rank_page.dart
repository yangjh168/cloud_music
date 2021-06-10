import 'package:cloud_music/api/common.dart';
import 'package:cloud_music/entity/rank_list.dart';
import 'package:cloud_music/routers/routers.dart';
import 'package:cloud_music/widget/cache_image.dart';
import 'package:cloud_music/widget/page_load_future.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RankPage extends StatefulWidget {
  RankPage({
    Key key,
  }) : super(key: key);

  @override
  RankPageState createState() => RankPageState();
}

class RankPageState extends State<RankPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("排行榜"),
      ),
      body: SingleChildScrollView(
        child: PageLoadFuture(
          futures: [commonApi.getRankTopList()],
          builder: (context, data) {
            var rank = data[0];
            return Column(
              children: [
                RankCard(
                  child: Ink(
                    padding: EdgeInsets.only(left: 20.w, right: 20.w),
                    color: Colors.white,
                    child: Column(
                      children: (rank['rank'] as List).map<Widget>((item) {
                        return _rankItem(item);
                      }).toList(),
                    ),
                  ),
                ),
                RankCard(
                    title: "更多榜单",
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.only(left: 20.w, right: 20.w),
                      child: GridView.count(
                        childAspectRatio: 0.7, //宽高比
                        crossAxisSpacing: 20.w,
                        shrinkWrap: true,
                        crossAxisCount: 3,
                        physics: NeverScrollableScrollPhysics(), //关闭滚动
                        children: (rank['other'] as List).map<Widget>((item) {
                          return _playItem(item, context);
                        }).toList(),
                      ),
                    )),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _rankItem(RankList item) {
    return Container(
      height: 150.h,
      child: InkWell(
        onTap: () {
          Routes.navigateTo(context, '/songlistPage', params: {'id': item.id});
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5.h),
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    height: 140.h,
                    width: 140.h,
                    child: CacheImage(
                      borderRadius: BorderRadius.circular(5),
                      url: item.coverImgUrl,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: item.tracks.asMap().keys.map((index) {
                      var song = item.tracks[index];
                      return RichText(
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        text: TextSpan(
                          style: TextStyle(fontSize: 24.0.sp),
                          children: <TextSpan>[
                            TextSpan(
                              text: (index + 1).toString() + '.' + song.first,
                              style: new TextStyle(
                                color: Colors.black87,
                              ),
                            ),
                            TextSpan(
                              text: ' - ' + song.second,
                              style: TextStyle(
                                color: Color(0xFF999999),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _playItem(item, context) {
    return InkWell(
      onTap: () {
        Routes.navigateTo(context, '/songlistPage', params: {'id': item.id});
      },
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 230.w,
            child: CacheImage(
              borderRadius: BorderRadius.circular(5),
              url: item.coverImgUrl,
            ),
          ),
          Text(item.name,
              softWrap: true,
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(color: Color(0XFF666666), fontSize: 24.0.sp)),
        ],
      ),
    );
  }
}

class RankCard extends StatelessWidget {
  final String title;
  final Widget child;

  const RankCard({Key key, this.title, this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    if (title != null) {
      list.add(_buildTitle());
    }
    list.add(child);

    return Container(
      margin: EdgeInsets.all(20.0.w),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15.0.w))),
      child: Column(
        children: list,
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.0.h, horizontal: 20.0.w),
      decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border(bottom: BorderSide(width: 0.5, color: Color(0xFFf5f5f5)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
