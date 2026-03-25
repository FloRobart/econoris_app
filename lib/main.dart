import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app.dart';
import 'config/app_config.dart';

void main() {
  /// Keep binding initialization and runApp in the same zone.
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      /// Set system UI mode to manual to control status bar and navigation bar visibility
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      );

      /// Capture Flutter framework errors
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        debugPrint('FlutterError caught: ${details.exceptionAsString()}');
        if (details.stack != null) debugPrint(details.stack.toString());
      };

      // Load environment variables from .env
      // await dotenv.load(fileName: '.env');

      // Initialize immutable Config values from dotenv
      AppConfig.load();

      // Initialize intl locale data for formatting dates/numbers (French)
      await initializeDateFormatting('fr_FR');
      Intl.defaultLocale = 'fr_FR';

      runApp(const ProviderScope(child: App()));
    },
    (error, stack) {
      debugPrint('Uncaught zone error: $error');
      debugPrint(stack.toString());
    },
  );
}
