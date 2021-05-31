import 'package:cloud_music/provider/index_store.dart';
import 'package:cloud_music/repository/global_repository.dart';
import 'package:cloud_music/routers/routers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_music/pages/main/home/netease_home.dart';

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
        backgroundColor: Color(0xFFf1503B),
        // iconTheme: IconThemeData(color: Colors.black),
        // textTheme: Theme.of(context).primaryTextTheme,
        // brightness: Theme.of(context).primaryColorBrightness,
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
            borderRadius: BorderRadius.all(Radius.circular(50.0.w)),
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
              style: TextStyle(fontSize: 26.0.sp),
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                enabled: false, //禁用
                focusColor: Colors.black,
                border: OutlineInputBorder(
                    borderSide:
                        BorderSide.none), //border不能直接使用InputBorder.none，否则文字不居中
                hintText: '搜索',
                hintStyle: TextStyle(fontSize: 26.0.sp),
                prefixIcon: Icon(Icons.search, color: Colors.black45),
                prefixStyle: TextStyle(fontSize: 24.sp),
              ),
            ),
          ),
        ),
        actions: [PlatformDropdown()],
      ),
      body: NeteaseHome(),
    );
  }
}

//平台下拉选择框
class PlatformDropdown extends StatelessWidget {
  final List itemList = [
    {'name': '网易云', 'value': 1},
    // {'name': '酷狗', 'value': 2},
    {'name': '酷我', 'value': 3},
  ];

  @override
  Widget build(BuildContext context) {
    IndexStore indexStore = IndexStore.of(context);
    int currentPlatform = indexStore.currentPlatform;
    //保存到全部变量中，便于发送请求时获取
    GlobalData.instance.platform = currentPlatform;
    return Container(
      height: 35,
      margin: EdgeInsets.only(right: 10),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          items: itemList.map((item) {
            return DropdownMenuItem(
              child: Text(item['name'],
                  style: TextStyle(color: Color(0xff4a4a4a))),
              value: item['value'],
            );
          }).toList(),
          hint: Text('请选择'),
          value: currentPlatform,
          onChanged: (value) {
            indexStore.setCurrentPlatform(value);
          },
          style: TextStyle(
            //设置文本框里面文字的样式
            color: Colors.white,
            fontSize: 16,
          ),
          //自定义已选样式
          selectedItemBuilder: (BuildContext context) {
            return itemList.map((item) {
              return Text(item['name']);
            }).toList();
          },
          isDense: true, //是否降低按钮的高度
          iconSize: 25.0,
          iconEnabledColor: Colors.white,
        ),
      ),
    );
  }
}
