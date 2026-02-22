import 'package:econoris_app/data/repositories/operations/operation_repository.dart';
import 'package:econoris_app/data/repositories/operations/operation_repository_impl.dart';
import 'package:econoris_app/data/repositories/operations/operation_repository_local.dart';
import 'package:econoris_app/data/repositories/operations/operation_repository_remote.dart';
import 'package:econoris_app/providers/data/services/api/operations/operation_api_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance asynchrone d'[OperationRepository].
final operationRepositoryProvider = Provider<OperationRepository>((ref) {
  final remote = OperationRepositoryRemote(operationApiClient: ref.read(operationApiClientProvider));
  final local = OperationRepositoryLocal();

  return OperationRepositoryImpl(remote: remote, local: local);
});
