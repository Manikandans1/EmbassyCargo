// lib/services/connectivity_service.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  // Singleton pattern to ensure only one instance exists
  static final ConnectivityService _instance = ConnectivityService._internal();

  factory ConnectivityService() => _instance;

  ConnectivityService._internal() {
    // Start monitoring connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  // Current connection status
  bool hasConnection = true;

  // StreamController to broadcast connection status changes
  final _connectionStatusController = StreamController<bool>.broadcast();

  // Public stream for connection status
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  // Check initial connectivity status
  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // Update connection status and notify listeners
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    hasConnection = result != ConnectivityResult.none;
    _connectionStatusController.add(hasConnection);
  }

  // Clean up resources
  void dispose() {
    _connectivitySubscription.cancel();
    _connectionStatusController.close();
  }
}
