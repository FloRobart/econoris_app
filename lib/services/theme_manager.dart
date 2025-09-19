import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager {
  ThemeMode mode;
  ThemeManager._(this.mode);

  static final ThemeManager instance = ThemeManager._(ThemeMode.system);

  static const _key = 'theme_mode';

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final v = sp.getString(_key) ?? 'system';
    mode = _fromString(v);
  }

  ThemeMode _fromString(String s) {
    switch (s) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  String _toString(ThemeMode m) {
    switch (m) {
      case ThemeMode.light: return 'light';
      case ThemeMode.dark: return 'dark';
      default: return 'system';
    }
  }

  final ValueNotifier<ThemeMode> notifier = ValueNotifier(ThemeMode.system);

  Future<void> setMode(ThemeMode m) async {
    mode = m;
    notifier.value = m;
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_key, _toString(m));
  }
}
