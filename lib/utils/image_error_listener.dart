import 'package:flutter/foundation.dart';

/// Default image error handler that forwards to FlutterError.
class ImageErrorListener {
  const ImageErrorListener();

  void call(Object error, StackTrace? stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(exception: error, stack: stackTrace),
    );
  }
}
