import 'package:cloud_music/component/global/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefix = 'quiet:settings:';
const _key_theme = "$_prefix:theme";
const _key_theme_mode = "$_prefix:themeMode";
const _key_copyright = "$_prefix:copyright";
const _key_skip_welcome_page = '$_prefix:skipWelcomePage';

extension SettingsProvider on BuildContext {
  Settings get settings => Settings.of(this, listen: false);
}

///登录状态
class Settings extends ChangeNotifier {
  ///根据BuildContext获取 [Settings]
  static Settings of(BuildContext context, {bool listen = true}) {
    return Provider.of<Settings>(context, listen: listen);
  }

  final SharedPreferences _preferences;

  ThemeData _theme;

  ThemeData get theme => _theme ?? quietThemes.first;

  set theme(ThemeData theme) {
    _theme = theme;
    final index = quietThemes.indexOf(theme);
    _preferences.setInt(_key_theme, index);
    notifyListeners();
  }

  ThemeData get darkTheme => quietDarkTheme;

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  set themeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    _preferences.setInt(_key_theme_mode, themeMode.index);
    notifyListeners();
  }

  bool _showCopyrightOverlay;

  bool get showCopyrightOverlay => _showCopyrightOverlay ?? true;

  set showCopyrightOverlay(bool show) {
    _showCopyrightOverlay = show;
    _preferences.setBool(_key_copyright, show);
    notifyListeners();
  }

  bool _skipWelcomePage;

  bool get skipWelcomePage => _skipWelcomePage ?? false;

  void setSkipWelcomePage() {
    _skipWelcomePage = true;
    _preferences.setBool(_key_skip_welcome_page, true);
    notifyListeners();
  }

  Settings(this._preferences) {
    _themeMode = ThemeMode.values[
        _preferences.getInt(_key_theme_mode) ?? 0]; /* default is system */
    _theme = quietThemes[
        _preferences.getInt(_key_theme) ?? 0]; /* default is NetEase Red */
    _showCopyrightOverlay = _preferences.get(_key_copyright);
    _skipWelcomePage = _preferences.get(_key_skip_welcome_page) ?? false;
  }
}
