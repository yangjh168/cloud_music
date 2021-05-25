import 'package:cloud_music/entity/song_menu.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:async/async.dart';
import 'package:cloud_music/entity/base_result.dart';

typedef LoadDataWidgetBuilder<T> = Widget Function(
    BuildContext context, T result);

void _defaultFailedHandler(BuildContext context, e, StackTrace stack) {
  debugPrint("error:\n ${e.toString()}");
}

class LoadDataBuilder<T> extends StatefulWidget {
  final Map params;
  final Function api;
  final LoadDataWidgetBuilder<T> builder;
  final Widget Function(BuildContext context, BaseResult result) errorBuilder;
  final void Function(BuildContext context, Object e, StackTrace stack) onError;

  final WidgetBuilder loadingBuilder;
  const LoadDataBuilder(
      {Key key,
      @required this.api,
      @required this.builder,
      this.loadingBuilder,
      this.params,
      this.onError = _defaultFailedHandler,
      this.errorBuilder})
      : assert(api != null),
        assert(builder != null),
        super(key: key);

  static Widget buildSimpleLoadingWidget<T>(BuildContext context) {
    return SimpleLoading(height: 200);
  }

  static Widget buildSimpleFailedWidget(
      BuildContext context, BaseResult result) {
    return SimpleFailed(
      message: result.msg,
      retry: () {
        LoadDataBuilder.of(context).refresh();
      },
    );
  }

  static _LoadDataBuilderState<T> of<T>(BuildContext context) {
    // findAncestorStateOfType()可以从当前节点沿着widget树向上查找指定类型的StatefulWidget对应的State对象。
    // 注意：context必须为LoadDataBuilder子节点的context
    return context.findAncestorStateOfType<_LoadDataBuilderState>();
  }

  @override
  _LoadDataBuilderState createState() => _LoadDataBuilderState<T>();
}

class _LoadDataBuilderState<T> extends State<LoadDataBuilder> {
  bool get isLoading => _loadingTask != null;

  CancelableOperation _loadingTask;

  BaseResult<T> baseResult;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  LoadDataBuilder<T> get widget => super.widget;

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
    Future _future = widget.api(widget.params, null, true);
    _loadingTask = CancelableOperation<T>.fromFuture(_future)
      ..value.then((result) {
        print("加载成功");
        assert(result != null, "result can not be null");
        baseResult = BaseResult.success<T>(result);
      }).catchError((e, StackTrace stack) {
        assert(e is Map, "未知错误：$e，请检查api是否提供正确，或api中是否存在awiat!");
        baseResult = BaseResult.error<T>(code: e.code, msg: e.msg);
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

  void _onError(e, StackTrace stack) {
    if (widget.onError != null) {
      widget.onError(context, e, stack);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _loadingTask?.cancel();
    _loadingTask = null;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading == true) {
      return (widget.loadingBuilder ??
          LoadDataBuilder.buildSimpleLoadingWidget)(context);
    }
    if (baseResult != null) {
      if (baseResult.isSuccess == true) {
        return widget.builder(context, baseResult.data);
      } else {
        return LoadErrorWidget(
          errorBuilder:
              widget.errorBuilder ?? LoadDataBuilder.buildSimpleFailedWidget,
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
