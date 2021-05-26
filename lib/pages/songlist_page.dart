import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_music/api/netease.dart';
import 'package:cloud_music/dialog/music_tile_dialog.dart';
import 'package:cloud_music/entity/play_queue.dart';
import 'package:cloud_music/entity/playlist_detail.dart';
import 'package:cloud_music/provider/player_store.dart';
import 'package:cloud_music/routers/routers.dart';
import 'package:cloud_music/utils/numbers.dart';
import 'package:cloud_music/widget/load_data_builder.dart';
import 'package:flutter/material.dart';
import 'package:cloud_music/widget/platform_logo.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SonglistPage extends StatefulWidget {
  //参数
  final int id;

  const SonglistPage({Key key, this.id}) : super(key: key);

  @override
  _SonglistPageState createState() => _SonglistPageState();
}

class _SonglistPageState extends State<SonglistPage> {
  @override
  Widget build(BuildContext context) {
    const double HEIGHT_HEADER = 280 + kToolbarHeight;

    return Scaffold(
      body: Container(
          child: LoadDataBuilder<PlaylistDetail>(
              api: neteaseApi.getSonglistDetail,
              params: {'id': widget.id},
              builder: (context, data) {
                return CustomScrollView(
                  slivers: <Widget>[
                    // CustomSliverAppBar(headInfo: data),
                    SliverAppBar(
                      title: Text('歌单'),
                      leading: GestureDetector(
                        child: Icon(
                          Icons.arrow_back_ios_outlined,
                        ),
                        onTap: () {
                          Routes.pop(context);
                        },
                      ),
                      pinned: true,
                      expandedHeight: HEIGHT_HEADER,
                      //空间大小可变的组件
                      flexibleSpace: FlexibleSpaceBar(
                        background: SongListHeader(headInfo: data),
                      ),
                      bottom: MusicListHeader(data),
                    ),
                    SliverList(
                        delegate: SliverChildListDelegate(
                            [SongListBuild(songListInfo: data)]))
                  ],
                );
              })),
    );
  }
}

class SongListHeader extends StatelessWidget {
  final PlaylistDetail headInfo;

  const SongListHeader({Key key, this.headInfo}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final FlexibleSpaceBarSettings settings =
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    final double deltaExtent = settings.maxExtent - settings.minExtent;
    // print('currentExtent:' + settings.currentExtent.toString());
    // print('minExtent:' + settings.minExtent.toString());
    // print('maxExtent:' + settings.maxExtent.toString());
    // 0.0 -> Expanded
    // 1.0 -> Collapsed to toolbar
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
    return Container(
      child: Stack(
        children: [
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
                    imageUrl: headInfo.coverUrl,
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
                child: SongListInfo(headInfo: headInfo),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//播放全部action
class MusicListHeader extends StatelessWidget implements PreferredSizeWidget {
  final PlaylistDetail headInfo;

  final Widget tail;

  MusicListHeader(this.headInfo, {this.tail});

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
            if (headInfo.musicList.length > 0) {
              player.play(
                  id: headInfo.musicList[0].id,
                  platform: headInfo.musicList[0].platform,
                  playQueue: PlayQueue(
                      queueId: headInfo.id,
                      queueTitle: headInfo.name,
                      queue: headInfo.musicList));
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
                  "(共${headInfo.trackCount}首)",
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

//歌单信息
class SongListInfo extends StatelessWidget {
  final PlaylistDetail headInfo;

  const SongListInfo({Key key, this.headInfo}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + kToolbarHeight),
          child: Column(
            children: <Widget>[
              Container(
                height: 146,
                padding: EdgeInsets.only(top: 20),
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 16),
                    AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                        child: Stack(
                          children: <Widget>[
                            Hero(
                              tag: headInfo.heroTag,
                              child: CachedNetworkImage(
                                  imageUrl: headInfo.coverUrl),
                            ),
                            Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                    Colors.black54,
                                    Colors.black26,
                                    Colors.transparent,
                                    Colors.transparent,
                                  ])),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(Icons.headset,
                                        color: Theme.of(context)
                                            .primaryIconTheme
                                            .color,
                                        size: 12),
                                    Text(getFormattedNumber(headInfo.playCount),
                                        style: Theme.of(context)
                                            .primaryTextTheme
                                            .bodyText2
                                            .copyWith(fontSize: 11))
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 10),
                          Text(
                            headInfo.name,
                            style: Theme.of(context)
                                .primaryTextTheme
                                .headline6
                                .copyWith(fontSize: 17),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 10),
                          InkWell(
                            onTap: () {
                              Routes.navigateTo(context, '/test');
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4, bottom: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                          imageUrl:
                                              headInfo.creator["avatarUrl"]),
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.only(left: 4)),
                                  Text(
                                    headInfo.creator["nickname"],
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .bodyText2,
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Theme.of(context)
                                        .primaryIconTheme
                                        .color,
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _HeaderAction(
                      Icons.comment,
                      headInfo.commentCount > 0
                          ? headInfo.commentCount.toString()
                          : "评论"),
                  _HeaderAction(
                      Icons.share,
                      headInfo.shareCount > 0
                          ? headInfo.shareCount.toString()
                          : "分享"),
                  _HeaderAction(Icons.file_download, '下载'),
                  // _HeaderAction(Icons.check_box, "多选", onSelectionTap),
                ],
              ),
            ],
          ),
        ),
      ),
    ] //..removeWhere((v) => v == null),
        );
  }
}

class _HeaderAction extends StatelessWidget {
  _HeaderAction(this.icon, this.action);

  final IconData icon;

  final String action;

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).primaryTextTheme;

    return InkResponse(
      onTap: () {},
      splashColor: textTheme.bodyText2.color,
      child: Opacity(
        opacity: 0.5,
        child: Column(
          children: <Widget>[
            Icon(
              icon,
              color: textTheme.bodyText2.color,
            ),
            const Padding(padding: EdgeInsets.only(top: 4)),
            Text(
              action,
              style: textTheme.caption.copyWith(fontSize: 13),
            )
          ],
        ),
      ),
    );
  }
}

//歌曲列表
class SongListBuild extends StatelessWidget {
  final PlaylistDetail songListInfo;

  const SongListBuild({Key key, this.songListInfo}) : super(key: key);

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
              children: songListInfo.musicList.map((item) {
                return _playItem(item, context, songListInfo);
              }).toList(),
            )
          ],
        ),
      ),
    );
  }

  Widget _playItem(item, context, PlaylistDetail songListInfo) {
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
                    queueId: songListInfo.id,
                    queueTitle: songListInfo.name,
                    queue: songListInfo.musicList));
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
