import 'package:econoris_app/data/repositories/subscriptions/subscription_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// Fournit une instance de [SubscriptionScreenUseCase].
final subscriptionScreenUseCaseProvider = Provider<SubscriptionScreenUseCase>((ref) {
  final subscriptionRepository = ref.read(subscriptionRepositoryProvider);
  return SubscriptionScreenUseCase(subscriptionRepository: subscriptionRepository);
});

/// Use case class for the subscription screen
class SubscriptionScreenUseCase {
  SubscriptionScreenUseCase({required this.subscriptionRepository});

  final SubscriptionRepository subscriptionRepository;
}