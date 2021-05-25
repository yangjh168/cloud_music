import 'package:cloud_music/api/netease.dart';
import 'package:cloud_music/entity/playlist_detail.dart';
import 'package:cloud_music/provider/user_account.dart';
import 'package:cloud_music/routers/routers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cloud_music/component/component.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:logging/logging.dart';
// import 'package:cloud_music/model/playlist_detail.dart';
// import 'package:cloud_music/part/part.dart';
// import 'package:cloud_music/repository/netease.dart';

// import '../playlist_tile.dart';

enum PlayListType { created, favorite }

class PlayListsGroupHeader extends StatelessWidget {
  final String name;
  final int count;

  const PlayListsGroupHeader({Key key, @required this.name, this.count})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        color: Theme.of(context).backgroundColor,
        child: Container(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Text("$name($count)"),
              Spacer(),
              Icon(Icons.add),
              Icon(Icons.more_vert),
            ],
          ),
        ),
      ),
    );
  }
}

class MainPlayListTile extends StatelessWidget {
  final PlaylistDetail data;
  final bool enableBottomRadius;

  const MainPlayListTile({
    Key key,
    @required this.data,
    this.enableBottomRadius = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        borderRadius: enableBottomRadius
            ? const BorderRadius.vertical(bottom: Radius.circular(4))
            : null,
        color: Theme.of(context).backgroundColor,
        // child: Container(
        //   child: PlaylistTile(playlist: data),
        // ),
      ),
    );
  }
}

const double _kPlayListHeaderHeight = 48;

const double _kPlayListDividerHeight = 10;

class MyPlayListsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;

  MyPlayListsHeaderDelegate(this.tabController);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _MyPlayListsHeader(controller: tabController);
  }

  @override
  double get maxExtent => _kPlayListHeaderHeight;

  @override
  double get minExtent => _kPlayListHeaderHeight;

  @override
  bool shouldRebuild(covariant MyPlayListsHeaderDelegate oldDelegate) {
    return oldDelegate.tabController != tabController;
  }
}

class _MyPlayListsHeader extends StatelessWidget
    implements PreferredSizeWidget {
  final TabController controller;

  const _MyPlayListsHeader({Key key, this.controller}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(_kPlayListHeaderHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TabBar(
        controller: controller,
        labelColor: Theme.of(context).textTheme.bodyText1.color,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: [
          Tab(text: context.strings["created_song_list"]),
          Tab(text: context.strings["favorite_song_list"]),
        ],
      ),
    );
  }
}

class PlayListTypeNotification extends Notification {
  final PlayListType type;

  PlayListTypeNotification({@required this.type});
}

class PlayListSliverKey extends ValueKey {
  final int createdPosition;
  final int favoritePosition;

  const PlayListSliverKey({this.createdPosition, this.favoritePosition})
      : super("_PlayListSliverKey");
}

// 歌单列表
class UserPlayListSection extends StatefulWidget {
  const UserPlayListSection({
    Key key,
    this.scrollController,
  }) : super(key: key);
  final ScrollController scrollController;

  @override
  _UserPlayListSectionState createState() => _UserPlayListSectionState();
}

class _UserPlayListSectionState extends State<UserPlayListSection> {
  // final logger = Logger("_UserPlayListSectionState");

  final _dividerKey = GlobalKey();

  int _dividerIndex = -1;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScrolled);
  }

  @override
  void didUpdateWidget(covariant UserPlayListSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.scrollController.removeListener(_onScrolled);
    widget.scrollController.addListener(_onScrolled);
  }

  @override
  void dispose() {
    super.dispose();
    widget.scrollController.removeListener(_onScrolled);
  }

  void _onScrolled() {
    if (_dividerIndex < 0) {
      return;
    }
    final RenderSliverList global = context.findRenderObject();
    RenderObject child = global.firstChild;
    while (child != null && global.indexOf(child) != _dividerIndex) {
      child = global.childAfter(child);
    }
    if (child == null) {
      return;
    }
    final offset = global.childMainAxisPosition(child);
    const height = _kPlayListHeaderHeight + _kPlayListDividerHeight / 2;
    PlayListTypeNotification(
            type:
                offset > height ? PlayListType.created : PlayListType.favorite)
        .dispatch(context);
  }

  @override
  Widget build(BuildContext context) {
    if (!UserAccount.of(context).isLogin) {
      return _singleSliver(child: notLogin(context));
    }
    final userId = UserAccount.of(context).userId;
    return FutureBuilder(
        future: neteaseApi.getHotSearchList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var result = snapshot.data;
            final created = result.where((p) => p.creator["userId"] == userId);
            final subscribed =
                result.where((p) => p.creator["userId"] != userId);
            _dividerIndex = 2 + created.length;
            return SliverList(
              key: PlayListSliverKey(
                  createdPosition: 1, favoritePosition: 3 + created.length),
              delegate: SliverChildListDelegate.fixed([
                SizedBox(height: _kPlayListDividerHeight),
                PlayListsGroupHeader(
                    name: context.strings["created_song_list"],
                    count: created.length),
                ..._playlistWidget(created),
                SizedBox(height: _kPlayListDividerHeight, key: _dividerKey),
                PlayListsGroupHeader(
                    name: context.strings["favorite_song_list"],
                    count: subscribed.length),
                ..._playlistWidget(subscribed),
                SizedBox(height: _kPlayListDividerHeight),
              ], addAutomaticKeepAlives: false),
            );
          } else {
            return Center(
              child: Text('加载中...'),
            );
          }
        });
  }

  Widget notLogin(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(20.0.w),
          child: Ink(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15.0.w)),
                color: Colors.white),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      vertical: 14.0.h, horizontal: 20.0.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('创建歌单',
                          style:
                              TextStyle(color: Color(0xFF999999), fontSize: 14))
                    ],
                  ),
                ),
                Container(
                  child: Container(
                    height: 150.h,
                    child: Column(
                      children: [
                        Text(context.strings["playlist_login_description"],
                            style: TextStyle(
                                color: Color(0xFF999999), fontSize: 14)),
                        TextButton(
                          child: Text(context.strings["login_right_now"]),
                          onPressed: () {
                            // Routes.navigateTo(context, '/AllList');
                            // Navigator.of(context).pushNamed(pageLogin);
                          },
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.all(20.0.w),
          child: Ink(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15.0.w)),
                color: Colors.white),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      vertical: 14.0.h, horizontal: 20.0.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('收藏歌单',
                          style:
                              TextStyle(color: Color(0xFF999999), fontSize: 14))
                    ],
                  ),
                ),
                Container(
                  child: Container(
                    height: 150.h,
                    child: Center(
                        child: Text(context.strings["empty_favorite_song_list"],
                            style: TextStyle(
                                color: Color(0xFF999999), fontSize: 14))),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Iterable<Widget> _playlistWidget(Iterable<PlaylistDetail> details) {
    if (details.isEmpty) {
      return const [];
    }
    final list = details.toList(growable: false);
    final List<Widget> widgets = <Widget>[];
    for (int i = 0; i < list.length; i++) {
      widgets.add(MainPlayListTile(
          data: list[i], enableBottomRadius: i == list.length - 1));
    }
    return widgets;
  }

  static Widget _singleSliver({@required Widget child}) {
    return SliverList(
      delegate: SliverChildListDelegate([child]),
    );
  }
}
