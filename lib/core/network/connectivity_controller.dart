import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityControllerProvider =
    StateNotifierProvider<ConnectivityController, ConnectivityState>(
  (ref) => ConnectivityController(),
);

class ConnectivityController extends StateNotifier<ConnectivityState> {
  ConnectivityController() : super(const ConnectivityState.initial()) {
    _subscription =
        _connectivity.onConnectivityChanged.listen(_onStatusChanged);
    _connectivity.checkConnectivity().then(_onStatusChanged);
  }

  final _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void _onStatusChanged(List<ConnectivityResult> results) {
    final hasConnection = results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);
    state = hasConnection
        ? const ConnectivityState.online()
        : const ConnectivityState.offline();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class ConnectivityState {
  const ConnectivityState._(
      {required this.isOnline, required this.hasEverConnected});

  const ConnectivityState.initial()
      : this._(isOnline: true, hasEverConnected: false);

  const ConnectivityState.online()
      : this._(isOnline: true, hasEverConnected: true);

  const ConnectivityState.offline()
      : this._(isOnline: false, hasEverConnected: true);

  final bool isOnline;
  final bool hasEverConnected;
}
