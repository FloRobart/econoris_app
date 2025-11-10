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

  /// Force refresh of all three endpoints.
  Future<void> fetchAll(String jwt) {
    if (jwt.isEmpty) return Future.value();
    if (_ongoingFetch != null) return _ongoingFetch!;

    // Start the fetch and keep the Future in _ongoingFetch so concurrent
    // callers reuse it.
    _ongoingFetch = _doFetch(jwt);
    return _ongoingFetch!;
  }

  Future<void> _doFetch(String jwt) async {
    try {
      final futs = <Future<dynamic>>[
        ApiService.getProfile(jwt),
        ApiService.getOperations(jwt),
        ApiService.getSubscriptions(jwt),
      ];
      final results = await Future.wait(futs);

      // parse profile
      final profileResp = results[0] as dynamic;
      if (profileResp != null && profileResp.statusCode >= 200 && profileResp.statusCode < 300) {
        try {
          final j = jsonDecode(profileResp.body);
          if (j is Map<String, dynamic>) profile = j;
        } catch (_) {
          profile = null;
        }
      } else {
        profile = null;
      }

      // parse operations
      final opsResp = results[1] as dynamic;
      if (opsResp != null && opsResp.statusCode >= 200 && opsResp.statusCode < 300) {
        try {
          final body = opsResp.body;
          if (body.isEmpty) {
            operations = [];
          } else {
            final parsed = jsonDecode(body);
            List<dynamic> list;
            if (parsed is List) {
              list = parsed;
            } else if (parsed is Map && parsed['rows'] is List) {
              list = parsed['rows'];
            } else if (parsed is Map && parsed['data'] is List) {
              list = parsed['data'];
            } else if (parsed is Map && parsed['operations'] is List) {
              list = parsed['operations'];
            } else if (parsed is Map) {
              list = [parsed];
            } else {
              list = [];
            }
            final ops = list.map((e) => Operation.fromJson(Map<String, dynamic>.from(e as Map))).toList();
            ops.sort((a, b) => b.levyDate.compareTo(a.levyDate));
            operations = ops;
          }
        } catch (e) {
          operations = null;
        }
      } else {
        operations = null;
      }

      // parse subscriptions
      final subsResp = results[2] as dynamic;
      if (subsResp != null && subsResp.statusCode >= 200 && subsResp.statusCode < 300) {
        try {
          final body = subsResp.body;
          if (body.isEmpty) {
            subscriptions = [];
          } else {
            final parsed = jsonDecode(body);
            List<dynamic> list;
            if (parsed is List) {
              list = parsed;
            } else if (parsed is Map && parsed['rows'] is List) {
              list = parsed['rows'];
            } else if (parsed is Map && parsed['data'] is List) {
              list = parsed['data'];
            } else if (parsed is Map && parsed['subscriptions'] is List) {
              list = parsed['subscriptions'];
            } else if (parsed is Map) {
              list = [parsed];
            } else {
              list = [];
            }
            final subs = list.map((e) => Subscription.fromJson(Map<String, dynamic>.from(e as Map))).toList();
            subs.sort((a, b) => b.startDate.compareTo(a.startDate));
            subscriptions = subs;
          }
        } catch (_) {
          subscriptions = null;
        }
      } else {
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

  /// Clear stored data (e.g. on logout / account deletion)
  void clear() {
    operations = null;
    subscriptions = null;
    profile = null;
    try {
      refreshNotifier.value++;
    } catch (_) {}
  }

  /// Insert or update a subscription from a parsed JSON object returned
  /// by the API. If the subscription id already exists we replace it,
  /// otherwise we insert it and keep the list sorted by startDate desc.
  void upsertSubscriptionFromJson(Map<String, dynamic> json) {
    try {
      final sub = Subscription.fromJson(Map<String, dynamic>.from(json));
      subscriptions ??= <Subscription>[];
      final idx = subscriptions!.indexWhere((s) => s.id == sub.id);
      if (idx >= 0) {
        subscriptions![idx] = sub;
      } else {
        subscriptions!.add(sub);
      }
      subscriptions!.sort((a, b) => b.startDate.compareTo(a.startDate));
      try {
        refreshNotifier.value++;
      } catch (_) {}
    } catch (_) {
      // ignore parse errors
    }
  }

  /// Remove a subscription by id from the in-memory store and notify.
  void removeSubscriptionById(int id) {
    if (subscriptions == null) return;
    subscriptions!.removeWhere((s) => s.id == id);
    try {
      refreshNotifier.value++;
    } catch (_) {}
  }
}
