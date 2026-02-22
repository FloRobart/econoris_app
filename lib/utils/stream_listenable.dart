import 'dart:async';
import 'package:flutter/foundation.dart';

/// Simple adapter to convert a [Stream<T>] into a [Listenable] (via
/// [ChangeNotifier]). It keeps the latest value available via [value] and
/// notifies listeners on every stream event.
/// https://github.com/flutter/flutter/issues/108128
class StreamListenable extends ChangeNotifier {
  StreamListenable(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
