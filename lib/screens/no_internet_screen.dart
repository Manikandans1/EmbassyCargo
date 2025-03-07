import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Importing Lottie package for animation
import '../utils/colors.dart'; // Ensure this points to your color configuration
import 'home_screen.dart'; // Import your connectivity service if needed

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({Key? key}) : super(key: key);

  // Function to simulate retrying connection
  void _retryConnection(BuildContext context) {
    // Show a message when retry is clicked
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Retrying connection...',style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        )),backgroundColor: Colors.blue,
        duration: Duration(seconds: 2), // You can adjust the duration
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      // Simulate going back to the HomeScreen on successful retry
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()), // Replace with actual screen
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: background_color,
      body: OrientationBuilder(
        builder: (context, orientation) {
          double animationWidth = orientation == Orientation.portrait ? screenWidth * 0.9 : screenWidth * 0.5;
          double animationHeight = animationWidth * 0.9;

          double textSize = screenWidth < 400 ? 16 : 18; // Adjust font size for small devices

          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/animations/no_internet.json',
                    width: animationWidth,
                    height: animationHeight,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Text(
                    'No Internet Connection',
                    style: TextStyle(
                      color: Colors.purple, // Use the accentColor
                      fontSize: 18, // Consistent font size as the Login button
                      fontWeight: FontWeight.bold, // Same bold weight
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  ElevatedButton(
                    onPressed: () => _retryConnection(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15), // Same vertical padding
                      //backgroundColor: Colors.blue, // Keep primaryColor
                      backgroundColor: button_color, // Keep primaryColor
                      minimumSize: const Size(double.infinity, 0), // Ensures full width
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Same border radius
                      ),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        color: Colors.black, // Use the accentColor
                        fontSize: 18, // Consistent font size as the Login button
                        fontWeight: FontWeight.bold, // Same bold weight
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
