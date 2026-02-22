import 'package:econoris_app/domain/use_cases/subscriptions/subscription_screen_usecase.dart';
import 'package:econoris_app/providers/data/repositories/subscriptions/subscription_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance de [SubscriptionScreenUseCase].
final subscriptionScreenUseCaseProvider = Provider<SubscriptionScreenUseCase>((ref) {
  final subscriptionRepository = ref.read(subscriptionRepositoryProvider);
  return SubscriptionScreenUseCase(subscriptionRepository: subscriptionRepository);
});
