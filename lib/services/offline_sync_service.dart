import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final offlineSyncServiceProvider = Provider<OfflineSyncService>(
  (ref) =>
      throw UnimplementedError('OfflineSyncService has not been initialized'),
);

class OfflineSyncService {
  final _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<void> initialize() async {
    await _processPendingOperations();

    _subscription = _connectivity.onConnectivityChanged.listen(
      (status) async {
        final hasConnection = status.contains(ConnectivityResult.mobile) ||
            status.contains(ConnectivityResult.wifi) ||
            status.contains(ConnectivityResult.ethernet);
        if (hasConnection) {
          await _processPendingOperations();
        }
      },
    );
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
  }

  Future<void> enqueueOperation(Map<String, dynamic> payload) async {
    final box = Hive.box('offline_queue');
    final List<dynamic> operations =
        List<dynamic>.from(box.get('operations', defaultValue: <dynamic>[]));
    operations.add(payload);
    await box.put('operations', operations);
  }

  Future<void> _processPendingOperations() async {
    final box = Hive.box('offline_queue');
    final List<dynamic> operations =
        List<dynamic>.from(box.get('operations', defaultValue: <dynamic>[]));

    if (operations.isEmpty) {
      return;
    }

    // TODO(anyone): Implement actual sync with backend once API is available
    operations.clear();
    await box.put('operations', operations);
  }
}
