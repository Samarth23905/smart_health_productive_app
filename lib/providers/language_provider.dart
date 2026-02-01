import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const _prefKey = 'selected_locale';
  Locale? _locale;
  Locale? get locale => _locale;

  LanguageProvider([this._locale]);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey);
    if (code != null) _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_prefKey);
    } else {
      await prefs.setString(_prefKey, locale.languageCode);
    }
  }
}