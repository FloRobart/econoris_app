import 'package:econoris_app/data/repositories/operations/operations_repository.dart';
import 'package:econoris_app/data/repositories/operations/operations_repository_impl.dart';
import 'package:econoris_app/data/repositories/operations/operations_repository_local.dart';
import 'package:econoris_app/data/repositories/operations/operations_repository_remote.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance asynchrone d'[OperationsRepository].
final operationsRepositoryProvider = FutureProvider<OperationsRepository>((ref) async {
  final remote = OperationsRepositoryRemote();
  final local = OperationsRepositoryLocal();

  return OperationsRepositoryImpl(remote: remote, local: local);
});
