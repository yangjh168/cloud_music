import 'package:cloud_music/api/common.dart';
import 'package:cloud_music/dialog/music_tile_dialog.dart';
import 'package:cloud_music/entity/music.dart';
import 'package:cloud_music/provider/index_store.dart';
import 'package:cloud_music/provider/player_store.dart';
import 'package:cloud_music/provider/search_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_music/routers/routers.dart';
import 'package:cloud_music/widget/platform_logo.dart';
import 'package:fluttertoast/fluttertoast.dart';

//定义通知类
class CustomNotification extends Notification {
  final int data;
  CustomNotification(this.data);
}

class SearchPage extends StatefulWidget {
  final String query;
  SearchPage({Key key, this.query}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin {
  TextEditingController _queryTextController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  String query; //搜索关键字
  int platform;
  List<Music> resultList; //搜索结果集
  //搜索历史仓库
  SearchStore _searchHistory = SearchStore();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    setState(() {
      query = widget.query ?? '';
      platform = IndexStore.of(context, listen: false).currentPlatform;
    });
  }

  // 显示搜索结果
  void _search() async {
    _focusNode?.unfocus();
    // _currentBody = _SearchBody.results;
    String keyword = _queryTextController.text;
    if (keyword.isEmpty) {
      Fluttertoast.showToast(
        msg: "请输入搜索内容",
        gravity: ToastGravity.CENTER,
      );
      return;
    }
    _searchHistory.insertSearchHistory(keyword);
    var res = await commonApi
        .getSearchResultList({'keyword': keyword, 'platform': platform});
    List<Music> songs = (res['list'] as List)
        .cast<Map>()
        .map((item) => Music.fromMap(item))
        .toList();
    setState(() {
      resultList = songs;
    });
  }

  //关闭搜索
  void _closeSearch(BuildContext context, dynamic result) {
    // _currentBody = null;
    _focusNode?.unfocus();
    Routes.pop(context, result);
    // Navigator.of(context)
    //   // ..popUntil((Route<dynamic> route) => route == _route)
    //   ..pop(result);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Semantics(
      explicitChildNodes: true,
      scopesRoute: true,
      namesRoute: true,
      label: '搜索',
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Color(0xFFf1503B),
          // iconTheme: IconThemeData(color: Colors.black),
          // textTheme: Theme.of(context).primaryTextTheme,
          brightness: Theme.of(context).primaryColorBrightness,
          leading: Container(
            margin: EdgeInsets.only(left: 15),
            child: GestureDetector(
              child: Icon(
                Icons.arrow_back_ios_outlined,
              ),
              onTap: () {
                _closeSearch(context, null);
              },
            ),
          ),
          leadingWidth: 40.0,
          title: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(50.0)),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            constraints: BoxConstraints(maxHeight: 35),
            alignment: Alignment.center,
            child: TextField(
              controller: _queryTextController,
              focusNode: _focusNode,
              onSubmitted: (String _) {
                ////同样是点击键盘完成按钮时触发的回调，该回调有参数，参数即为当前输入框中的值。(String){}
                _search();
              },
              onChanged: (val) {},
              textAlignVertical: TextAlignVertical.bottom,
              style: TextStyle(fontSize: 15),
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                focusColor: Colors.black,
                border: OutlineInputBorder(borderSide: BorderSide.none),
                hintText: '请输入',
                hintStyle: TextStyle(fontSize: 15),
                // prefixIcon: Icon(Icons.search, color: Colors.black45),
                // prefixStyle: TextStyle(fontSize: 24.sp),
                prefixIcon: NotificationListener<CustomNotification>(
                  onNotification: (notification) {
                    // 收到子Widget通知，更新数据
                    setState(() {
                      platform = notification.data;
                    });
                    return false;
                  },
                  child: PlatformDropdown(platform: platform),
                ),
                // suffixIcon: GestureDetector(
                //   onTap: () {},
                //   child: Icon(Icons.camera_alt_outlined, color: Colors.black45),
                // ),
                // suffixStyle: TextStyle(fontSize: 24.sp),
              ),
            ),
          ),
          actions: [
            Container(
              padding: EdgeInsets.only(right: 15),
              child: Center(
                child: GestureDetector(
                  child: Text("搜索",
                      style: TextStyle(color: Colors.white, fontSize: 16.0)),
                  onTap: () {
                    _search();
                  },
                ),
              ),
            ),
          ],
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _searchBody(context),
        ),
      ),
    );
  }

  Widget _searchBody(BuildContext context) {
    List<String> searchHistory =
        SearchStore.of(context, listen: true).searchHistory;
    if (resultList != null && resultList.isNotEmpty) {
      return SearchResultPage(resultList: resultList);
    } else {
      if (searchHistory != null && searchHistory.isNotEmpty) {
        return Container(
          color: Colors.white,
          child: _hotWrapList(searchHistory),
        );
      } else {
        return KeyedSubtree(
          // key: const ValueKey<_SearchBody>(_SearchBody.suggestions),
          child: buildSuggestions(context),
        );
      }
    }
  }

  //热门搜索列表
  Widget _hotWrapList(searchHistory) {
    print(searchHistory);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(20.0.w),
          alignment: Alignment.centerLeft,
          child: Text('搜索历史', style: TextStyle(color: Color(0xFF666666))),
        ),
        Container(
          padding: EdgeInsets.only(left: 20.0.w, right: 20.0.w, bottom: 20.0.w),
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 20.0.w,
            runSpacing: 20.0.w,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: searchHistory.map<Widget>((name) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _queryTextController.text = name;
                    _search();
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.all(Radius.circular(10.0.w))),
                  padding: EdgeInsets.symmetric(
                      vertical: 10.0.w, horizontal: 20.0.w),
                  child: Text(
                    name,
                    style:
                        TextStyle(fontSize: 24.0.sp, color: Color(0xFF666666)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  //搜索建议
  Widget buildSuggestions(BuildContext context) {
    // final suggestionList = query.isEmpty
    //     ? recentSuggest
    //     : searchList.where((input) => input.startsWith(query)).toList();
    // return ListView.builder(
    //     itemCount: suggestionList.length,
    //     itemBuilder: (context, index) => ListTile(
    //           title: RichText(
    //             text: TextSpan(
    //                 text: suggestionList[index].substring(0, query.length),
    //                 style: TextStyle(
    //                     color: Colors.black, fontWeight: FontWeight.bold),
    //                 children: [
    //                   TextSpan(
    //                       text: suggestionList[index].substring(query.length),
    //                       style: TextStyle(color: Colors.grey))
    //                 ]),
    //           ),
    //         ));
    return Center(
      child: Text('搜索内容'),
    );
  }
}

//搜索结果
class SearchResultPage extends StatelessWidget {
  final List<Music> resultList;

  const SearchResultPage({Key key, this.resultList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      // header: SpaceHeader(),
      // footer: BezierBounceFooter(),
      // footer: ClassicalFooter(
      //   enableHapticFeedback: false,
      //   bgColor: Colors.white,
      //   textColor: Colors.pink,
      //   infoColor: Colors.pink,
      //   loadText: '上拉加载',
      //   loadingText: '加载中...',
      //   loadReadyText: '释放加载',
      //   loadedText: '',
      //   loadFailedText: '加载失败',
      //   showInfo: false,
      //   noMoreText: '我也是有底线的',
      // ),
      // bottomBouncing: false, //底部回弹
      topBouncing: false,
      child: ListView(
        children: [
          singleMusicCard(context),
        ],
      ),
      onRefresh: null,
      onLoad: () async {
        // _getHotGoodsList();
      },
    );
  }

  Widget singleMusicCard(context) {
    return Container(
      margin: EdgeInsets.all(20.0.w),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5.0))),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    bottom: BorderSide(width: 0.5, color: Color(0xFFf5f5f5)))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('单曲', style: TextStyle(fontWeight: FontWeight.bold))
              ],
            ),
          ),
          Wrap(
            children: resultList.map<Widget>((item) {
              return _playItem(item, context);
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget _playItem(item, context) {
    return Ink(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          PlayerStore player = PlayerStore.of(context, listen: false);
          if (player.music == null || player.music.id != item.id) {
            player.play(music: item);
          }
        },
        child: Container(
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(width: 0.5, color: Color(0xFFf5f5f5)))),
          padding: EdgeInsets.only(left: 15, top: 5, bottom: 5),
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

//平台下拉选择框
class PlatformDropdown extends StatelessWidget {
  final int platform;
  final List itemList = [
    {'name': '网易云', 'value': 1},
    // {'name': '酷狗', 'value': 2},
    {'name': '酷我', 'value': 3},
  ];

  PlatformDropdown({Key key, this.platform}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // IndexStore indexStore = IndexStore.of(context, listen: false);
    // int currentPlatform = indexStore.currentPlatform;
    //保存到全部变量中，便于发送请求时获取
    // GlobalData.instance.platform = currentPlatform;
    Color fontColor = Colors.black87;
    return Container(
      // height: 35,
      margin: EdgeInsets.only(right: 10, left: 15),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          items: itemList.map((item) {
            return DropdownMenuItem(
              // child: Text(item['name'], style: TextStyle(color: Color(0xff4a4a4a))),
              child: Text(item['name']),
              value: item['value'],
            );
          }).toList(),
          hint: Text('请选择'),
          value: platform,
          onChanged: (value) {
            // indexStore.setCurrentPlatform(value);
            CustomNotification(value).dispatch(context);
          },
          style: TextStyle(
            //设置文本框里面文字的样式
            color: fontColor,
            fontSize: 15,
          ),
          //自定义已选样式
          selectedItemBuilder: (BuildContext context) {
            return itemList.map((item) {
              return Text(item['name']);
            }).toList();
          },
          isDense: true, //是否降低按钮的高度
          iconSize: 25.0,
          iconEnabledColor: fontColor,
        ),
      ),
    );
  }
}
