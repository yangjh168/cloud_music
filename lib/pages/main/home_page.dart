import 'package:cloud_music/repository/global_repository.dart';
import 'package:cloud_music/routers/routers.dart';
import 'package:flutter/material.dart';
import 'package:cloud_music/pages/main/home/home_index.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
  }

  // 重新销毁
  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        // titleSpacing: 10.0,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.only(left: 15),
          child: GestureDetector(
            child: Icon(
              Icons.dehaze,
            ),
            onTap: () {
              //打开侧边栏
              var _slideKey = GlobalData.instance.slideKey;
              if (_slideKey != null) {
                _slideKey.currentState.openOrClose();
              }
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
          child: GestureDetector(
            onTap: () {
              Routes.navigateTo(context, '/searchPage');
            },
            child: TextField(
              textAlignVertical:
                  TextAlignVertical.bottom, //文字偏上用TextAlignVertical.bottom修正
              style: TextStyle(fontSize: 15),
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                enabled: false, //禁用
                focusColor: Colors.black,
                border: OutlineInputBorder(
                    borderSide:
                        BorderSide.none), //border不能直接使用InputBorder.none，否则文字不居中
                hintText: '搜索',
                hintStyle: TextStyle(fontSize: 15),
                prefixIcon: Icon(Icons.search, color: Colors.black45),
                prefixStyle: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ),
      ),
      body: HomeIndex(),
    );
  }
}
