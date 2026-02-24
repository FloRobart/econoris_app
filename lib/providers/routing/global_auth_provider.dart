import 'package:econoris_app/data/services/auth/global_auth_notifier.dart';
import 'package:econoris_app/data/services/auth/global_auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final globalAuthProvider = NotifierProvider<GlobalAuthNotifier, AuthStatus>(
  GlobalAuthNotifier.new,
);
