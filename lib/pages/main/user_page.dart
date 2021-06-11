import 'package:cloud_music/pages/main/user/_profile_like.dart';
import 'package:cloud_music/pages/main/user/_profile_mini.dart';
import 'package:cloud_music/provider/user_account.dart';
import 'package:cloud_music/repository/global_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:logging/logging.dart';
// import 'package:quiet/part/part.dart';

import './user/_playlists.dart';
import './user/_preset_grid.dart';
import './user/_profile.dart';

class UserPage extends StatefulWidget {
  @override
  createState() => _UserPageState();
}

class _UserPageState extends State<UserPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  ScrollController _scrollController = ScrollController();

  TabController _tabController;

  bool _scrollerAnimating = false;
  bool _tabAnimating = false;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: PlayListType.values.length, vsync: this);
    _tabController.addListener(_onUserSelectedTab);
  }

  //切换tab
  void _onUserSelectedTab() {
    // logger.info("_onUserSelectedTab : ${_tabController.index} ${_tabController.indexIsChanging}");
    if (_scrollerAnimating || _tabAnimating) {
      return;
    }
    _scrollToPlayList(PlayListType.values[_tabController.index]);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    //顶部信息栏高度
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      margin: EdgeInsets.only(top: statusBarHeight),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: SliverCustomHeaderDelegate(
              collapsedHeight: 50,
              expandedHeight: 51,
              paddingTop: MediaQuery.of(context).padding.top, //上边刘海高度
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                UserProfileSection(),
                PresetGridSection(),
                // ProfileLike(),
              ],
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: MyPlayListsHeaderDelegate(_tabController),
          ),
          // NotificationListener 滚动通知
          NotificationListener<PlayListTypeNotification>(
            onNotification: (notification) {
              _updateCurrentTabSelection(notification.type);
              return true;
            },
            child: UserPlayListSection(
              scrollController: _scrollController,
            ),
          ),
        ],
      ),
    );
  }

  void _computeScroller(
      void callback(PlayListSliverKey sliverKey, List<Element> children,
          int start, int end)) {
    SliverMultiBoxAdaptorElement playListSliver;
    void playListSliverFinder(Element element) {
      if (element.widget.key is PlayListSliverKey) {
        playListSliver = element;
      } else if (playListSliver == null) {
        element.visitChildElements(playListSliverFinder);
      }
    }

    // to find PlayListSliver.
    context.visitChildElements(playListSliverFinder);

    final PlayListSliverKey sliverKey =
        playListSliver.widget.key as PlayListSliverKey;
    assert(playListSliver != null, "can not find sliver");
    assert(sliverKey != null, "can not find sliver");

    // logger.info("sliverKey : created position: ${sliverKey.createdPosition} ${sliverKey.favoritePosition}");

    final List<Element> children = [];
    playListSliver.visitChildElements((element) {
      children.add(element);
    });
    if (children.isEmpty) {
      return;
    }
    final start = _index(children.first);
    final end = _index(children.last);
    if (end <= start) {
      return;
    }
    // logger.info("position start - end -> $start - $end");
    callback(sliverKey, children, start, end);
  }

  void _scrollToPlayList(PlayListType type) {
    _scrollerAnimating = true;

    _computeScroller((sliverKey, children, start, end) {
      final target = type == PlayListType.created
          ? sliverKey.createdPosition
          : sliverKey.favoritePosition;
      final position = _scrollController.position;
      if (target >= start && target <= end) {
        Element toShow = children[target - start];
        position
            .ensureVisible(toShow.renderObject,
                duration: const Duration(milliseconds: 300),
                curve: Curves.linear)
            .whenComplete(() {
          _scrollerAnimating = false;
        });
      } else if (target < start) {
        position
            .ensureVisible(
          children.first.renderObject,
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        )
            .then((_) {
          WidgetsBinding.instance.scheduleFrameCallback((timeStamp) {
            _scrollToPlayList(type);
          });
        });
      } else if (target > end) {
        position
            .ensureVisible(
          children.last.renderObject,
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
        )
            .then((_) {
          WidgetsBinding.instance.scheduleFrameCallback((timeStamp) {
            _scrollToPlayList(type);
          });
        });
      }
    });
  }

  static int _index(Element element) {
    int index;
    void _findIndex(Element e) {
      if (e.widget is IndexedSemantics) {
        index = (e.widget as IndexedSemantics).index;
      } else {
        e.visitChildElements(_findIndex);
      }
    }

    element.visitChildElements(_findIndex);
    assert(index != null, "can not get index for element $element");
    return index;
  }

  @override
  bool get wantKeepAlive => true;

  void _updateCurrentTabSelection(PlayListType type) async {
    if (_tabController.index == type.index) {
      return;
    }
    if (_tabController.indexIsChanging || _scrollerAnimating || _tabAnimating) {
      return;
    }
    _tabAnimating = true;
    _tabController.animateTo(type.index, duration: kTabScrollDuration);
    Future.delayed(kTabScrollDuration + Duration(milliseconds: 100))
        .whenComplete(() {
      _tabAnimating = false;
    });
  }
}

//动态展示头部header
class SliverCustomHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double collapsedHeight;

  final double expandedHeight;
  final double paddingTop;
  String statusBarMode = 'dark';

  SliverCustomHeaderDelegate({
    this.collapsedHeight,
    this.expandedHeight,
    this.paddingTop,
  });

  // 收起状态下组件的高度；
  @override
  double get minExtent => this.collapsedHeight + this.paddingTop;
  // 展开状态下组件的高度；
  @override
  double get maxExtent => this.expandedHeight + this.paddingTop;

  // 类似于react中的shouldComponentUpdate；
  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  void updateStatusBarBrightness(shrinkOffset) {
    if (shrinkOffset > 50 && this.statusBarMode == 'dark') {
      this.statusBarMode = 'light';
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ));
    } else if (shrinkOffset <= 50 && this.statusBarMode == 'light') {
      this.statusBarMode = 'dark';
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
      ));
    }
  }

  Color makeStickyHeaderBgColor(shrinkOffset) {
    final int alpha = (shrinkOffset / (this.maxExtent - this.minExtent) * 255)
        .clamp(0, 255)
        .toInt();
    return Color.fromARGB(alpha, 255, 255, 255);
  }

  // Color makeStickyHeaderTextColor(shrinkOffset, isIcon) {
  //   if (shrinkOffset <= 50) {
  //     return isIcon ? Colors.white : Colors.transparent;
  //   } else {
  //     final int alpha = (shrinkOffset / (this.maxExtent - this.minExtent) * 255)
  //         .clamp(0, 255)
  //         .toInt();
  //     return Color.fromARGB(alpha, 0, 0, 0);
  //   }
  // }
  double makeUserAccountOpacity(shrinkOffset) {
    double opacity = shrinkOffset / this.maxExtent;
    opacity = 1 - opacity;
    if (opacity <= 0) {
      return 0;
    } else {
      return opacity;
    }
  }

  // 构建渲染的内容
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    this.updateStatusBarBrightness(shrinkOffset);
    //控件build完成再更新否则报setState() or markNeedsBuild() called during build.
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      UserAccount.of(context, listen: false)
          .setUserOpacity(this.makeUserAccountOpacity(shrinkOffset));
    });
    double opacity = this.makeUserAccountOpacity(shrinkOffset) <= 0.2 ? 1 : 0;
    return Container(
      height: this.maxExtent,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        // fit: StackFit.expand,
        children: <Widget>[
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              color: this.makeStickyHeaderBgColor(shrinkOffset),
              child: Container(
                  height: this.collapsedHeight,
                  alignment: Alignment.center,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Opacity(
                        opacity: opacity,
                        child: MiniUserProfile(),
                      ),
                      Positioned(
                        left: 15,
                        top: 14,
                        child: GestureDetector(
                            onTap: () {
                              //打开侧边栏
                              var _slideKey = GlobalData.instance.slideKey;
                              if (_slideKey != null) {
                                _slideKey.currentState.openOrClose();
                              }
                            },
                            child: Icon(Icons.dehaze)),
                      )
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
