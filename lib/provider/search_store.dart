import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _KEY_HISTORY = "key_search_history";

class SearchStore extends ChangeNotifier {
  ///根据BuildContext获取 [SearchStore]
  static SearchStore of(BuildContext context, {bool listen = true}) {
    return Provider.of<SearchStore>(context, listen: listen);
  }

  List<String> searchHistory = [];

  //初始化
  SearchStore() {
    scheduleMicrotask(() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      searchHistory = preferences.getStringList(_KEY_HISTORY) ?? [];
      notifyListeners();
    });
  }

  //清空搜索历史
  void clearSearchHistory() async {
    if (!searchHistory.isNotEmpty) return;
    searchHistory.clear();
    notifyListeners();
    final preference = await SharedPreferences.getInstance();
    await preference.remove(_KEY_HISTORY);
  }

  //插入搜索历史
  void insertSearchHistory(String query) async {
    print("插入搜索历史：" + query);
    // debugPrint('insert history $query init = $_init , searchHistory = $searchHistory');
    // if (!searchHistory.isNotEmpty) return;
    searchHistory.remove(query);
    searchHistory.insert(0, query);
    while (searchHistory.length > 10) {
      searchHistory.removeLast();
    }
    notifyListeners();

    final preference = await SharedPreferences.getInstance();
    preference.setStringList(_KEY_HISTORY, searchHistory);
  }
}
