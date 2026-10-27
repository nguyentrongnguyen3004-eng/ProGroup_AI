import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  AppSettings._();

  static final AppSettings instance = AppSettings._();

  ThemeMode _themeMode = ThemeMode.system;
  String _language = 'vi';
  bool _notificationsEnabled = true;

  ThemeMode get themeMode => _themeMode;

  String get language => _language;

  Locale get locale => Locale(_language);

  bool get notificationsEnabled => _notificationsEnabled;

  bool get isEnglish => _language == 'en';

  /// Khởi tạo và đọc cài đặt đã lưu từ SharedPreferences khi mở app
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Đọc giao diện sáng/tối
      final savedTheme = prefs.getString('app_theme_mode');
      if (savedTheme != null) {
        switch (savedTheme) {
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'system':
          default:
            _themeMode = ThemeMode.system;
            break;
        }
      }

      // Đọc ngôn ngữ
      final savedLang = prefs.getString('app_language');
      if (savedLang == 'vi' || savedLang == 'en') {
        _language = savedLang!;
      }

      // Đọc cài đặt thông báo
      _notificationsEnabled = prefs.getBool('app_notifications') ?? true;

      notifyListeners();
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final modeStr = switch (mode) {
        ThemeMode.dark => 'dark',
        ThemeMode.light => 'light',
        ThemeMode.system => 'system',
      };
      await prefs.setString('app_theme_mode', modeStr);
    } catch (_) {}
  }

  Future<void> setLanguage(String language) async {
    if (language != 'vi' && language != 'en') return;
    if (_language == language) return;

    _language = language;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_language', language);
    } catch (_) {}
  }

  Future<void> setNotifications(bool value) async {
    if (_notificationsEnabled == value) return;

    _notificationsEnabled = value;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('app_notifications', value);
    } catch (_) {}
  }
}
