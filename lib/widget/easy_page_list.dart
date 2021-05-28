import 'package:cloud_music/entity/page_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:async/async.dart';

class EasyPageList<T> extends StatefulWidget {
  final Function api;
  final Map params;
  final Widget Function(BuildContext context, List result) builder;
  final Widget Function(BuildContext context) errorBuilder;
  final WidgetBuilder loadingBuilder;
  final WidgetBuilder finishedBuilder;

  const EasyPageList({
    Key key,
    @required this.api,
    this.params,
    @required this.builder,
    this.errorBuilder,
    this.loadingBuilder,
    this.finishedBuilder,
  }) : super(key: key);

  static Widget buildSimpleLoadingWidget<T>(BuildContext context) {
    return SimpleLoading(height: 200);
  }

  static Widget buildSimpleFailedWidget(BuildContext context) {
    return SimpleFailed(
      message: "服务器开小差了~",
      retry: () {
        EasyPageList.of(context).refresh();
      },
    );
  }

  static Widget buildSimpleFinishedWidget = Container(child: Text("加载完成"));

  static _EasyPageListState<T> of<T>(BuildContext context) {
    // findAncestorStateOfType()可以从当前节点沿着widget树向上查找指定类型的StatefulWidget对应的State对象。
    // 注意：context必须为EasyPageList子节点的context
    return context.findAncestorStateOfType<_EasyPageListState>();
  }

  @override
  _EasyPageListState createState() => _EasyPageListState<T>();
}

class _EasyPageListState<T> extends State<EasyPageList> {
  CancelableOperation _loadingTask;

  //每页条数
  int limit = 50;
  //页码
  int offset = 1;
  //总条数
  int total = 0;
  //是否加载中
  bool get isLoading => _loadingTask != null;
  //列表数据
  List<T> list;
  //是否加载失败
  bool isError = false;
  //是否加载完成
  bool get isFinished => (list != null && !isLoading && list.length >= total);

  @override
  void initState() {
    super.initState();
    // refresh();
  }

  ///refresh data
  // force: true在加载过程中强制刷新
  Future<void> refresh({bool force: false}) async {
    print("下拉刷新");
    offset = 1;
    Map pagetion = {'limit': limit, 'offset': offset};
    if (widget.params != null) {
      var params = new Map.from(widget.params);
      pagetion.addAll(params);
    }
    _loadData(params: pagetion, force: force);
  }

  Future<void> load({bool force: false}) async {
    print("上拉加载");
    Map pagetion = {'limit': limit, 'offset': offset};
    if (widget.params != null) {
      var params = new Map.from(widget.params);
      pagetion.addAll(params);
    }
    _loadData(params: pagetion, force: force);
  }

  Future _loadData({Map params, bool force = false}) {
    assert(force != null);

    if (_loadingTask != null && !force) {
      return _loadingTask.value;
    }
    _loadingTask?.cancel();
    var future = widget.api(params, null, true);
    // print(future);
    _loadingTask = CancelableOperation<PageResult<List<T>>>.fromFuture(future)
      ..value.then((result) {
        print("加载成功");
        assert(result != null, "result can not be null");
        total = result.total;
        list = list ?? [];
        list.addAll(result.list);
        isError = false;
        offset += 1;
      }).catchError((e, StackTrace stack) {
        print("加载失败:" + e.toString());
        isError = true;
      }).whenComplete(() {
        print("加载完成");
        _loadingTask = null;
        setState(() {});
      });
    //notify if should be in loading status
    setState(() {});
    return _loadingTask.value;
  }

  @override
  void dispose() {
    super.dispose();
    _loadingTask?.cancel();
    _loadingTask = null;
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      firstRefresh: true,
      header: MaterialHeader(),
      // footer: ClassicalFooter(
      //   enableHapticFeedback: false,
      //   // bgColor: Colors.white,
      //   // textColor: Colors.pink,
      //   // infoColor: Colors.pink,
      //   loadText: '上拉加载',
      //   loadingText: '加载中...',
      //   loadReadyText: '释放加载',
      //   loadedText: '',
      //   loadFailedText: '加载失败',
      //   showInfo: false,
      //   noMoreText: '我也是有底线的',
      // ),
      // bottomBouncing: false, //底部回弹
      child: _buildContent(),
      onRefresh: () async {
        refresh();
      },
      onLoad: () async {
        load();
      },
    );
  }

  Widget _buildContent() {
    // if (baseResult == null) {
    //   return (widget.loadingBuilder ??
    //       EasyPageList.buildSimpleLoadingWidget)(context);
    // }
    if (isError) {
      return LoadErrorWidget(
        errorBuilder:
            widget.errorBuilder ?? EasyPageList.buildSimpleFailedWidget,
      );
    }
    List<Widget> pageWidget = [];
    if (list != null) {
      Widget listTep = widget.builder(context, list);
      pageWidget.add(listTep);
    }
    if (isFinished) {
      pageWidget.add(
          widget.finishedBuilder ?? EasyPageList.buildSimpleFinishedWidget);
    }
    return Column(children: pageWidget);
  }
}

// 加载错误组件
class LoadErrorWidget extends StatelessWidget {
  final Widget Function(BuildContext context) errorBuilder;

  const LoadErrorWidget({Key key, @required this.errorBuilder})
      : assert(errorBuilder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return errorBuilder(context);
  }
}

// 内置默认loading时的widget
class SimpleLoading extends StatelessWidget {
  final double height;

  const SimpleLoading({Key key, this.height = 200}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: height),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// 内置默认fail时的widget
class SimpleFailed extends StatelessWidget {
  final VoidCallback retry;

  final String message;

  const SimpleFailed({Key key, this.retry, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 200),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            message != null ? Text(message) : Container(),
            SizedBox(height: 8),
            RaisedButton(
              child: Text(MaterialLocalizations.of(context)
                  .refreshIndicatorSemanticLabel),
              onPressed: retry,
            )
          ],
        ),
      ),
    );
  }
}
