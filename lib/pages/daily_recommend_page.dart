import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_music/api/common.dart';
import 'package:cloud_music/dialog/music_tile_dialog.dart';
import 'package:cloud_music/entity/music.dart';
import 'package:cloud_music/entity/play_queue.dart';
import 'package:cloud_music/provider/player_store.dart';
import 'package:cloud_music/widget/load_data_builder.dart';
import 'package:flutter/material.dart';
import 'package:cloud_music/widget/platform_logo.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DailyRecommendPage extends StatefulWidget {
  //参数
  final int id;

  const DailyRecommendPage({Key key, this.id}) : super(key: key);

  @override
  _DailyRecommendPageState createState() => _DailyRecommendPageState();
}

class _DailyRecommendPageState extends State<DailyRecommendPage> {
  @override
  Widget build(BuildContext context) {
    const double HEIGHT_HEADER = 280 + kToolbarHeight;

    return Scaffold(
      body: Container(
          child: LoadDataBuilder<List<Music>>(
              api: commonApi.getDailyRecommendList,
              params: {'platform': 3},
              builder: (context, data) {
                return CustomScrollView(
                  slivers: <Widget>[
                    SliverAppBar(
                      elevation: 0,
                      pinned: true,
                      automaticallyImplyLeading: false,
                      expandedHeight: HEIGHT_HEADER,
                      //空间大小可变的组件
                      flexibleSpace: DailyRecommendHeader(),
                      bottom: MusicListHeader(data),
                    ),
                    SliverList(
                        delegate: SliverChildListDelegate(
                            [SongListBuild(musicList: data)]))
                  ],
                );
              })),
    );
  }
}

class DailyRecommendHeader extends StatelessWidget {
  final String backgroundUrl =
      'https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3566088443,3713209594&fm=26&gp=0.jpg';

  @override
  Widget build(BuildContext context) {
    final FlexibleSpaceBarSettings settings =
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    final double deltaExtent = settings.maxExtent - settings.minExtent;
    final double opacity =
        (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent)
            .clamp(0.0, 1.0);

    //为content 添加 底部的 padding
    double bottomPadding = 0;
    SliverAppBar sliverBar =
        context.findAncestorWidgetOfExactType<SliverAppBar>();
    if (sliverBar != null && sliverBar.bottom != null) {
      bottomPadding = sliverBar.bottom.preferredSize.height;
    }

    return ClipRect(
      //裁剪超出内容,不然BackdropFilter会超出
      child: Stack(
        fit: StackFit.expand,
        children: [
          //背景添加视差滚动效果
          Positioned(
            top: -Tween<double>(begin: 0.0, end: deltaExtent / 4.0)
                .transform(opacity),
            left: 0,
            right: 0,
            height: settings.maxExtent,
            child: Stack(
              fit: StackFit.passthrough,
              children: <Widget>[
                CachedNetworkImage(
                    imageUrl: backgroundUrl,
                    fit: BoxFit.cover,
                    width: 120,
                    height: 1),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(color: Colors.black.withOpacity(0.3)),
                ),
                Container(color: Colors.black.withOpacity(0.3))
              ],
            ),
          ),
          Positioned(
            top: settings.currentExtent - settings.maxExtent,
            left: 0,
            right: 0,
            height: settings.maxExtent,
            child: Opacity(
              opacity: 1 - opacity,
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomPadding),
                child: ExpandBox(background: backgroundUrl),
              ),
            ),
          ),
          Column(
            children: [
              AppBar(
                leading: BackButton(),
                automaticallyImplyLeading: false,
                title: Text('每日歌曲推荐'),
                backgroundColor: Colors.transparent,
                elevation: 0,
                titleSpacing: 16,
              )
            ],
          )
        ],
      ),
    );
  }
}

//播放全部action
class MusicListHeader extends StatelessWidget implements PreferredSizeWidget {
  final List<Music> musicList;

  final Widget tail;

  MusicListHeader(this.musicList, {this.tail});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        child: InkWell(
          onTap: () {
            PlayerStore player = PlayerStore.of(context, listen: false);
            if (musicList.length > 0) {
              player.play(
                  id: musicList[0].id,
                  platform: musicList[0].platform,
                  playQueue: PlayQueue(
                      queueId: 0, queueTitle: '每日推荐', queue: musicList));
            }
          },
          child: SizedBox.fromSize(
            size: preferredSize,
            child: Row(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(left: 16)),
                Icon(
                  Icons.play_circle_outline,
                  color: Theme.of(context).iconTheme.color,
                ),
                Padding(padding: EdgeInsets.only(left: 4)),
                Text(
                  "播放全部",
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                Padding(padding: EdgeInsets.only(left: 2)),
                Text(
                  "(共${musicList.length}首)",
                  style: Theme.of(context).textTheme.caption,
                ),
                Spacer(),
                tail,
              ]..removeWhere((v) => v == null),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

//展开区域内容
class ExpandBox extends StatelessWidget {
  final String background;

  ExpandBox({Key key, this.background}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CachedNetworkImage(
          imageUrl: background, fit: BoxFit.cover, width: 120, height: 1),
    );
  }
}

//歌曲列表
class SongListBuild extends StatelessWidget {
  final List<Music> musicList;

  const SongListBuild({Key key, this.musicList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        decoration:
            BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5.0))),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      bottom:
                          BorderSide(width: 0.5, color: Color(0xFFf5f5f5)))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('单曲', style: TextStyle(fontWeight: FontWeight.bold))
                ],
              ),
            ),
            Wrap(
              children: musicList.map((item) {
                return _playItem(item, context, musicList);
              }).toList(),
            )
          ],
        ),
      ),
    );
  }

  Widget _playItem(item, context, List<Music> musicList) {
    return Ink(
      color: Colors.white,
      child: InkWell(
        onTap: () async {
          //点击音乐
          // var playable = await neteaseApi
          //     .checkMusic({'id': item.id, 'platform': item.platform});
          // if (!playable) {
          //   print("音乐不可用");
          //   // showDialog(context: context, builder: (context) => DialogNoCopyRight());
          //   return;
          // }

          // final res = await neteaseApi
          //     .getMusicDetail({'id': item.id, 'platform': item.platform});
          // Music music = Music.fromMap(res);
          // PlayerStore player = PlayerStore.of(context, listen: false);
          // if (player.music == null || player.music.id != music.id) {
          //   player.play(music: music, playList: songList);
          // }
          PlayerStore player = PlayerStore.of(context, listen: false);
          if (player.music == null || player.music.id != item.id) {
            player.play(
                id: item.id,
                platform: item.platform,
                playQueue: PlayQueue(
                    queueId: 0, queueTitle: '每日推荐', queue: musicList));
          }
        },
        child: Container(
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(width: 0.5, color: Color(0xFFf5f5f5)))),
          padding: EdgeInsets.only(left: 15, top: 10, bottom: 10),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${item.title}',
                          style: TextStyle(
                              color: Color(0XFF666666), fontSize: 24.0.sp)),
                      Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 5),
                            child: PlatformLogo(platform: item.platform),
                          ),
                          Expanded(
                            child: Text(
                              '${item.subTitle}',
                              style: TextStyle(
                                  color: Color(0XFF666666), fontSize: 24.0.sp),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_vert_outlined),
                onPressed: () {
                  MusicTileDialog.show(context, item);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
