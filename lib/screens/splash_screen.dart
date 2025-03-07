import 'package:embassycargo/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/connectivity_service.dart';
import 'home_screen.dart';
import 'no_internet_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  final ConnectivityService _connectivityService = ConnectivityService();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Adjust the duration as needed
    );

    // Fade animation for the logo and app name
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    // Scale animation for the logo
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // Rotation animation for the logo
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Start the animation and check connectivity
    _controller.forward();
    _checkConnectivityAndNavigate();
  }

  Future<void> _checkConnectivityAndNavigate() async {
    await Future.delayed(const Duration(seconds: 4)); // Adjust splash duration as needed
    bool hasInternet = await _connectivityService.checkConnectivity();
    _navigateBasedOnConnectivity(hasInternet);
  }

  void _navigateBasedOnConnectivity(bool hasInternet) {
    Navigator.of(context).pushReplacement(
      _createFadeRoute(hasInternet ? HomeScreen() : NoInternetScreen()),
    );
  }

  Route _createFadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0; // Start opacity
        const end = 1.0;   // End opacity
        const curve = Curves.easeIn; // Curve of the animation

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var fadeAnimation = animation.drive(tween);

        return FadeTransition(
          opacity: fadeAnimation,
          child: child,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the controller to free resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background_color,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive size scaling based on screen width
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          double logoSize = screenWidth * 0.5; // Logo will take 50% of the screen width
          double fontSize = screenWidth * 0.08; // Font size is 8% of screen width

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo with rotation, scaling, and fading in
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: RotationTransition(
                      turns: _rotationAnimation,
                      child: Image.asset(
                        'assets/images/logo.png', // Your logo file path
                        width: logoSize,  // Adjusted size for different screens
                        height: logoSize, // Adjusted size for different screens
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Space between logo and text
                // App name with fade-in animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Embassy Cargo', // Your app name
                    style: GoogleFonts.roboto(
                      fontSize: dynamicFontSize(context, fontSize), // Responsive font size
                      fontWeight: FontWeight.bold,
                      color: primaryColor, // Purple text color
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Method to dynamically adjust font size based on screen width
  double dynamicFontSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return baseSize * 0.85; // Smaller screens get slightly smaller font sizes
    } else if (screenWidth > 600) {
      return baseSize * 1.2; // Larger screens get slightly larger font sizes
    }
    return baseSize; // Default size for medium screens
  }
}
