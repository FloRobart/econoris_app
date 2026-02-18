import 'package:econoris_app/data/repositories/subscriptions/subscriptions_repository.dart';
import 'package:econoris_app/data/repositories/subscriptions/subscriptions_repository_impl.dart';
import 'package:econoris_app/data/repositories/subscriptions/subscriptions_repository_local.dart';
import 'package:econoris_app/data/repositories/subscriptions/subscriptions_repository_remote.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance asynchrone d'[SubscriptionsRepository].
final subscriptionsRepositoryProvider = FutureProvider<SubscriptionsRepository>((ref) async {
  final remote = SubscriptionsRepositoryRemote();
  final local = SubscriptionsRepositoryLocal();

  return SubscriptionsRepositoryImpl(remote: remote, local: local);
});
