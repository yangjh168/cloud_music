import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_music/api/common.dart';
import 'package:cloud_music/entity/song_menu.dart';
import 'package:cloud_music/routers/routers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_music/widget/easy_page_list.dart';

class PlaylistPlazzPage extends StatefulWidget {
  @override
  _PlaylistPlazzPageState createState() => _PlaylistPlazzPageState();
}

class _PlaylistPlazzPageState extends State<PlaylistPlazzPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController _controller;

  List categoryList;

  @override
  bool get wantKeepAlive => true;

  // 重新初始化
  @override
  void initState() {
    super.initState();
    this.getPlaylistHotCategoryData();
  }

  // 获取热门歌曲分类
  void getPlaylistHotCategoryData() async {
    List list = await commonApi.getPlaylistHotCategory();
    list.insert(0, {'id': 0, 'name': '全部'});
    this.setState(() {
      categoryList = list;
      _controller = TabController(length: list.length, vsync: this);
    });
  }

  // 重新销毁
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (categoryList == null) {
      return Text("");
    }
    if (categoryList.isEmpty) {
      return Container(
        child: Text("加载数据失败"),
      );
    }
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.white,
        // titleTextStyle: TextStyle(color: Colors.black),
        title: Text('歌单广场'),
        bottom: TabBar(
          controller: _controller,
          isScrollable: true, //tab可滚动
          tabs: categoryList.map((item) {
            return Tab(text: item['name']);
          }).toList(),
        ),
      ),
      body: TabBarView(
          controller: _controller,
          children: categoryList.map((item) {
            return PlaylistTabViewItem(item: item);
          }).toList()),
    );
  }
}

class PlaylistTabViewItem extends StatefulWidget {
  final Map item;
  const PlaylistTabViewItem({Key key, this.item}) : super(key: key);
  @override
  _PlaylistTabViewItemState createState() => _PlaylistTabViewItemState();
}

class _PlaylistTabViewItemState extends State<PlaylistTabViewItem>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return EasyPageList<SongMenu>(
      params: {'cat': widget.item['name']},
      api: commonApi.getPlaylistList,
      builder: (BuildContext context, data) {
        return Container(
          padding: EdgeInsets.all(20.w),
          child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(), //关闭滚动,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 0.7, //显示区域宽高相等
                crossAxisSpacing: 20.w,
                crossAxisCount: 3, //每行三列
              ),
              itemCount: data.length,
              itemBuilder: (context, index) {
                return _playItem(data[index], context);
              }),
        );
      },
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
            alignment: Alignment.center,
            color: Colors.black12,
            margin: EdgeInsets.only(bottom: 10.0.h),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: CachedNetworkImage(
                imageUrl: item.picUrl,
                placeholder: (context, url) => Container(
                  width: 130,
                  height: 130,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 1,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
                fit: BoxFit.fitWidth,
              ),
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
