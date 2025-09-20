import 'package:flutter/material.dart';
import 'app.dart';
import 'services/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeManager.instance.load();
  // initialize notifier with loaded value
  ThemeManager.instance.notifier.value = ThemeManager.instance.mode;
  runApp(const EconorisApp());
}