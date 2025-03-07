import 'dart:async';
import 'package:flutter/material.dart';
import 'screens/no_internet_screen.dart';
import 'services/connectivity_service.dart';
import 'screens/splash_screen.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock orientation to portrait mode
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) {
    runApp( MyApp());
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ConnectivityService _connectivityService = ConnectivityService();
  late StreamSubscription<bool> _subscription;
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    // Listen to the connection status changes
    _subscription = _connectivityService.connectionStatusStream.listen((hasConnection) {
      setState(() {
        _hasInternet = hasConnection;
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF001F54),
      ),
      home: _hasInternet ? SplashScreen() : NoInternetScreen(),
    );
  }
}
