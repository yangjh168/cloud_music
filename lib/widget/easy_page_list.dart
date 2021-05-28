import 'package:cloud_music/dio/dio_utils.dart';
import 'package:cloud_music/entity/base_result.dart';
import 'package:cloud_music/entity/page_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:async/async.dart';

class EasyPageList<T> extends StatefulWidget {
  final Function api;
  final Map params;
  final Widget Function(BuildContext context, List result) builder;
  final Widget Function(BuildContext context, BaseResult result) errorBuilder;
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

  static Widget buildSimpleFailedWidget(
      BuildContext context, BaseResult result) {
    return SimpleFailed(
      message: result.msg,
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
  int limit = 50;
  int offset = 0;

  bool get isLoading => _loadingTask != null;

  CancelableOperation _loadingTask;

  BaseResult<PageResult<List<T>>> baseResult;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  ///refresh data
  // force: true在加载过程中强制刷新
  Future<void> refresh({bool force: false}) async {
    print("刷新数据");
    _loadData(widget.api, force: false);
  }

  Future _loadData(Function future, {bool force = false}) {
    assert(future != null);
    assert(force != null);

    if (_loadingTask != null && !force) {
      return _loadingTask.value;
    }
    _loadingTask?.cancel();
    var pagetion = {'limit': limit, 'offset': offset};
    var newParams =
        widget.params != null ? pagetion.addAll(widget.params) : pagetion;
    var sfuture = widget.api(newParams, null, true);
    print(sfuture);
    _loadingTask = CancelableOperation<PageResult<List<T>>>.fromFuture(sfuture)
      ..value.then((result) {
        print("加载成功");
        print(result);
        assert(result != null, "result can not be null");
        baseResult = BaseResult.success<PageResult<List<T>>>(result);
      }).catchError((e, StackTrace stack) {
        print("加载失败:" + e.toString());
        if (e is NetError) {
          baseResult = BaseResult.error(code: e.code, msg: e.msg);
        } else {
          // assert(e is Map, "未知错误：$e，请检查api是否提供正确，或api中是否存在awiat!");
          baseResult = BaseResult.error(code: 500, msg: '未知错误');
        }
        _onError(e, stack);
      }).whenComplete(() {
        print("加载完成");
        _loadingTask = null;
        setState(() {});
      });
    //notify if should be in loading status
    setState(() {});
    return _loadingTask.value;
  }

  void _onError(e, StackTrace stack) {}

  @override
  void dispose() {
    super.dispose();
    _loadingTask?.cancel();
    _loadingTask = null;
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      header: MaterialHeader(),
      bottomBouncing: false, //底部回弹
      child: _buildContent(),
      onRefresh: () async {
        refresh();
      },
    );
  }

  Widget _buildContent() {
    if (baseResult == null || isLoading) {
      return (widget.loadingBuilder ??
          EasyPageList.buildSimpleLoadingWidget)(context);
    }
    if (baseResult.isSuccess == false) {
      return LoadErrorWidget(
        errorBuilder:
            widget.errorBuilder ?? EasyPageList.buildSimpleFailedWidget,
        result: baseResult,
      );
    }
    List<Widget> pageWidget = [];
    print(baseResult.data.list);
    Widget listTep = widget.builder(context, baseResult.data.list);
    pageWidget.add(listTep);
    if ((baseResult.data.list).length >= baseResult.data.total) {
      pageWidget.add(
          widget.finishedBuilder ?? EasyPageList.buildSimpleFinishedWidget);
    }
    return Column(children: pageWidget);
  }
}

// 加载错误组件
class LoadErrorWidget extends StatelessWidget {
  final BaseResult result;
  final Widget Function(BuildContext context, BaseResult result) errorBuilder;

  const LoadErrorWidget(
      {Key key, @required this.result, @required this.errorBuilder})
      : assert(errorBuilder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return errorBuilder(context, result);
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
