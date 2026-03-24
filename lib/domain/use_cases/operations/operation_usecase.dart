import 'package:econoris_app/data/repositories/operations/operation_repository.dart';
import 'package:econoris_app/data/repositories/subscriptions/subscription_repository.dart';
import 'package:econoris_app/domain/models/operations/operation.dart';
import 'package:econoris_app/domain/models/subscriptions/subscription.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance de [OperationUseCase].
final operationUseCaseProvider = Provider<OperationUseCase>((ref) {
  final operationRepository = ref.read(operationRepositoryProvider);
  final subscriptionRepository = ref.read(subscriptionRepositoryProvider);

  return OperationUseCase(
    operationRepository: operationRepository,
    subscriptionRepository: subscriptionRepository,
  );
});

/// Use case class for the home screen
class OperationUseCase {
  OperationUseCase({
    required this.operationRepository,
    required this.subscriptionRepository,
  });

  final OperationRepository operationRepository;
  final SubscriptionRepository subscriptionRepository;

  /*=====*/
  /* GET */
  /*=====*/
  /// Fetches a list of operations from the repository.
  Future<List<Operation>> getOperations() {
    return operationRepository.getOperations();
  }

  /// Fetches a list of subscriptions from the repository.
  Future<List<Subscription>> getSubscriptions() {
    return subscriptionRepository.getSubscriptions();
  }

  /*======*/
  /* POST */
  /*======*/
  Future<Operation> addOperation(Operation body) {
    return operationRepository.addOperation(body);
  }

  /*=====*/
  /* PUT */
  /*=====*/
  // Future<Operation> updateOperation(int id, Operation body) {
  //   return operationRepository.updateOperation(id, body);
  // }

  /*========*/
  /* DELETE */
  /*========*/
}
