import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Lottie package for animation
import '../services/connectivity_service.dart';
import '../utils/colors.dart';
import 'no_internet_screen.dart'; // Ensure this is your no internet screen
import 'tracking_screen.dart'; // Your Tracking screen
import 'home_screen.dart'; // Your Home screen

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key});

  @override
  _OrderSuccessScreenState createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  final ConnectivityService _connectivityService = ConnectivityService();
  late StreamSubscription<bool> _subscription;
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();

    // Check initial connectivity status
    _connectivityService.checkConnectivity().then((hasConnection) {
      setState(() {
        _hasInternet = hasConnection;
      });
      if (!_hasInternet) {
        _showNoInternetScreen();
      }
    });

    // Listen to connection status changes
    _subscription = _connectivityService.connectionStatusStream.listen((hasConnection) {
      setState(() {
        _hasInternet = hasConnection;
      });

      if (!_hasInternet) {
        _showNoInternetScreen();
      }
    });
  }

  void _showNoInternetScreen() {
    // Ensure we are not on the NoInternetScreen already
    if (ModalRoute.of(context)?.settings.name != 'NoInternetScreen') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NoInternetScreen()),
      );
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: OrientationBuilder(
        builder: (context, orientation) {
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;

          // Set sizing based on orientation
          double animationWidth = orientation == Orientation.portrait
              ? screenWidth * 0.9
              : screenWidth * 0.5;
          double animationHeight = animationWidth * 0.9; // Maintain aspect ratio

          // Fixed font size with a minimum
          double textSize = 18; // Default size
          if (screenWidth < 400) {
            textSize = 16; // Smaller devices
          }

          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lottie animation for Order Success
                  Lottie.asset(
                    'assets/animations/order_success.json', // Your Lottie animation file path
                    width: animationWidth, // Adjust width based on orientation
                    height: animationHeight, // Maintain aspect ratio
                    fit: BoxFit.contain, // Ensure the animation fits nicely
                  ),
                  SizedBox(height: screenHeight * 0.04), // Space between animation and text
                  // Display message
                  Text(
                    'Order Successfully Placed',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: textSize, // Use fixed font size
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.03), // Space between text and button
                  // Track Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.015,
                        horizontal: screenWidth * 0.1, // Consistent padding
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(5),
                        ),
                      ),
                    ),
                    child: Text(
                      'Track',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16, // Fixed size for button text
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
