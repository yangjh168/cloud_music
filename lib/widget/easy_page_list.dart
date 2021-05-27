import 'package:cloud_music/dio/dio_utils.dart';
import 'package:cloud_music/entity/base_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:async/async.dart';

class EasyPageList<T> extends StatefulWidget {
  final Function api;
  final Map params;
  final Widget Function(BuildContext context, T result) builder;
  final Widget Function(BuildContext context, BaseResult result) errorBuilder;
  final WidgetBuilder loadingBuilder;

  const EasyPageList({
    Key key,
    @required this.api,
    @required this.builder,
    this.params,
    this.loadingBuilder,
    this.errorBuilder,
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

  BaseResult<T> baseResult;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  ///refresh data
  // force: true在加载过程中强制刷新
  Future<void> refresh({bool force: false}) async {
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
    _loadingTask = CancelableOperation<T>.fromFuture(
      Future(() async {
        return await widget.api(pagetion.addAll(widget.params), null, true);
      }),
    )..value.then((result) {
        print("加载成功");
        assert(result != null, "result can not be null");
        baseResult = BaseResult.success<T>(result);
      }).catchError((e, StackTrace stack) {
        if (e is NetError) {
          baseResult = BaseResult.error<T>(code: e.code, msg: e.msg);
        } else {
          // assert(e is Map, "未知错误：$e，请检查api是否提供正确，或api中是否存在awiat!");
          baseResult = BaseResult.error<T>(code: 500, msg: '未知错误');
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
    var ss = widget.api;
    return EasyRefresh(
      header: MaterialHeader(),
      bottomBouncing: false, //底部回弹
      child: buildContent(),
      onRefresh: () async {
        refresh();
      },
    );
  }

  Widget buildContent() {
    if (isLoading == true) {
      return (widget.loadingBuilder ??
          EasyPageList.buildSimpleLoadingWidget)(context);
    }
    if (baseResult != null) {
      if (baseResult.isSuccess == true) {
        return widget.builder(context, baseResult.data);
      } else {
        return LoadErrorWidget(
          errorBuilder:
              widget.errorBuilder ?? EasyPageList.buildSimpleFailedWidget,
          result: baseResult,
        );
      }
    } else {
      return Text("");
    }
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
