import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:cloud_music/entity/user_detail_bean.dart';
// import 'package:cloud_music/repository/netease.dart';

///登录状态
class UserAccount extends ChangeNotifier {
  //用户信息透明度
  double userOpacity = 1;

  setUserOpacity(double opacity) {
    userOpacity = opacity;
    notifyListeners();
  }

  // final logger = Logger("UserAccount");

  ///get user info from persistence data
  static Future<Map> getPersistenceUser() async {
    // return await neteaseLocalData[_persistenceKey];
    var profileMap = {
      'avatarUrl':
          'https://pic4.zhimg.com/80/v2-0e98d843ef66ae5e9ec846a7c5f98224_720w.jpg?source=1940ef5c',
      'nickname': '卡布奇诺专属',
    };
    UserProfile profile = UserProfile.fromJsonMap(profileMap);
    return {
      'level': 10,
      'listenSongs': null,
      'userPoint': null,
      'mobileSign': null,
      'pcSign': null,
      'profile': profile,
      'peopleCanSeeMyPlayRecord': null,
      'bindings': null,
      'adValid': null,
      'code': null,
      'createTime': null,
      'createDays': null,
    };
  }

  ///根据BuildContext获取 [UserAccount]
  static UserAccount of(BuildContext context, {bool listen = true}) {
    return Provider.of<UserAccount>(context, listen: listen);
  }

  static const _persistenceKey = 'neteaseLoginUser';

  // Future<Result<Map>> login(String phone, String password) async {
  //   final result = await neteaseRepository.login(phone, password);
  //   if (result.isValue) {
  //     final json = result.asValue.value;
  //     final userId = json["account"]["id"];

  //     final userDetailResult = await neteaseRepository.getUserDetail(userId);
  //     if (userDetailResult.isError) {
  //       return Result.error("can not get user detail");
  //     }
  //     _userDetail = userDetailResult.asValue.value;
  //     neteaseLocalData[_persistenceKey] = _userDetail.toJson();
  //     notifyListeners();
  //   }
  //   return result;
  // }

  void logout() {
    _userDetail = null;
    notifyListeners();
    // neteaseLocalData[_persistenceKey] = null;
    // neteaseRepository.logout();
  }

  UserAccount(Map user) {
    if (user != null) {
      try {
        _userDetail = UserDetail.fromJsonMap(user);
      } catch (e) {
        // logger.severe("can not read user: $e");
        // neteaseLocalData["neteaseLocalData"] = null;
      }
      //访问api，刷新登陆状态
      // neteaseRepository.refreshLogin().then((login) async {
      //   if (!login || _userDetail == null) {
      //     logout();
      //   } else {
      //     // refresh user
      //     final result =
      //         await neteaseRepository.getUserDetail(_userDetail.profile.userId);
      //     if (result.isValue) {
      //       _userDetail = result.asValue.value;
      //       neteaseLocalData[_persistenceKey] = _userDetail.toJson();
      //       notifyListeners();
      //     }
      //   }
      // }, onError: (e) {
      //   debugPrint("refresh login status failed \n $e");
      // });
    }
  }

  UserDetail _userDetail;

  UserDetail get userDetail => _userDetail;

  UserProfile get profile => userDetail.profile;

  ///当前是否已登录
  bool get isLogin {
    return _userDetail != null;
  }

  ///当前登录用户的id
  ///null if not login
  int get userId {
    if (!isLogin) {
      return null;
    }
    return _userDetail.profile.userId;
  }
}
