import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/operation.dart';
import '../models/subscription.dart';
import 'api_service.dart';

/// Global data store that keeps the last fetched operations, subscriptions and
/// user profile. Use `ensureData(jwt)` to load them when needed. If any of the
/// three is missing, the store will re-request all three (max 2 attempts) to
/// ensure consistency.
class GlobalData {
  GlobalData._internal();
  static final GlobalData instance = GlobalData._internal();

  List<Operation>? operations;
  List<Subscription>? subscriptions;
  Map<String, dynamic>? profile;

  /// Notifier that updates whenever a full refresh completes. Useful for
  /// widgets that want to listen for changes.
  final ValueNotifier<int> refreshNotifier = ValueNotifier<int>(0);

  /// When a fetchAll is in progress we reuse the same Future so multiple
  /// callers awaiting ensureData won't trigger duplicate network requests.
  Future<void>? _ongoingFetch;

  /// Ensure data is present. If any of the three values is null or empty
  /// (for lists), we will fetch all three. If after the first fetch one is
  /// still missing, we retry once more.
  Future<void> ensureData(String jwt) async {
    if (jwt.isEmpty) return;
    if (_hasAll()) return;

    if (_ongoingFetch != null) {
      await _ongoingFetch;
    } else {
      await fetchAll(jwt);
    }

    if (!_hasAll()) {
      // second attempt to be sure all endpoints provide values
      if (_ongoingFetch != null) {
        await _ongoingFetch;
      } else {
        await fetchAll(jwt);
      }
    }
  }

  bool _hasAll() {
    return profile != null && operations != null && subscriptions != null;
  }

  /// Force refresh of all three endpoints. Returns the ongoing fetch future so
  /// concurrent callers share the same request.
  Future<void> fetchAll(String jwt) {
    if (jwt.isEmpty) return Future.value();
    if (_ongoingFetch != null) return _ongoingFetch!;

    _ongoingFetch = _doFetch(jwt);
    return _ongoingFetch!;
  }

  Future<void> _doFetch(String jwt) async {
    try {
      // call endpoints in parallel
      final futs = <Future<dynamic>>[
        ApiService.getProfile(jwt),
        ApiService.getOperations(jwt),
        ApiService.getSubscriptions(jwt),
      ];
      final results = await Future.wait(futs);

      // parse profile
      try {
        final profileResp = results[0] as dynamic;
        if (profileResp != null && profileResp.statusCode >= 200 && profileResp.statusCode < 300) {
          final j = jsonDecode(profileResp.body);
          if (j is Map<String, dynamic>) {
            profile = j;
          } else {
            profile = null;
          }
        } else {
          profile = null;
        }
      } catch (_) {
        profile = null;
      }

      // parse operations
      try {
        final opsResp = results[1] as dynamic;
        if (opsResp != null && opsResp.statusCode >= 200 && opsResp.statusCode < 300) {
          final body = opsResp.body ?? '';
          if (body.isEmpty) {
            operations = [];
          } else {
            final parsed = jsonDecode(body);
            final list = _extractList(parsed, ['rows', 'data', 'operations']);
            final ops = list.map((e) => Operation.fromJson(Map<String, dynamic>.from(e as Map))).toList();
            ops.sort((a, b) => b.levyDate.compareTo(a.levyDate));
            operations = ops;
          }
        } else {
          operations = null;
        }
      } catch (_) {
        operations = null;
      }

      // parse subscriptions
      try {
        final subsResp = results[2] as dynamic;
        if (subsResp != null && subsResp.statusCode >= 200 && subsResp.statusCode < 300) {
          final body = subsResp.body ?? '';
          if (body.isEmpty) {
            subscriptions = [];
          } else {
            final parsed = jsonDecode(body);
            final list = _extractList(parsed, ['rows', 'data', 'subscriptions']);
            final subs = list.map((e) => Subscription.fromJson(Map<String, dynamic>.from(e as Map))).toList();
            subs.sort((a, b) => b.startDate.compareTo(a.startDate));
            subscriptions = subs;
          }
        } else {
          subscriptions = null;
        }
      } catch (_) {
        subscriptions = null;
      }

      // notify listeners that a refresh occurred
      try {
        refreshNotifier.value++;
      } catch (_) {}
    } finally {
      _ongoingFetch = null;
    }
  }

  /// Helper to extract a list from various possible JSON shapes.
  List<dynamic> _extractList(dynamic parsed, List<String> candidateKeys) {
    if (parsed is List) return parsed;
    if (parsed is Map) {
      for (final k in candidateKeys) {
        if (parsed[k] is List) return parsed[k] as List<dynamic>;
      }
      // if it's a single object, wrap it
      return [parsed];
    }
    return <dynamic>[];
  }

  /// Clear stored data (useful on logout).
  void clear() {
    operations = null;
    subscriptions = null;
    profile = null;
    try {
      refreshNotifier.value++;
    } catch (_) {}
  }
}
