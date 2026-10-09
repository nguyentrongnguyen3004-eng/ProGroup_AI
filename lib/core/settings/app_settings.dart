import 'package:flutter/material.dart';

class AppSettings extends ChangeNotifier {
  AppSettings._();

  static final AppSettings instance = AppSettings._();

  ThemeMode _themeMode = ThemeMode.system;
  String _language = 'vi';
  bool _notificationsEnabled = true;

  ThemeMode get themeMode => _themeMode;

  String get language => _language;

  bool get notificationsEnabled => _notificationsEnabled;

  bool get isEnglish => _language == 'en';

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();
  }

  void setLanguage(String language) {
    if (language != 'vi' && language != 'en') return;
    if (_language == language) return;

    _language = language;
    notifyListeners();
  }

  void setNotifications(bool value) {
    if (_notificationsEnabled == value) return;

    _notificationsEnabled = value;
    notifyListeners();
  }
}
