import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../services/connectivity_service.dart';
import '../utils/colors.dart';
import 'login_screen.dart';
import 'no_internet_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final ConnectivityService _connectivityService = ConnectivityService();
  late StreamSubscription<bool> _subscription;
  bool _hasInternet = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  //final String _registerUrl = 'http://192.168.137.1:8000/register/'; // Use your server IP or base URL
   final String _registerUrl = "http://64.23.143.44:8000/register/"; // Use your server IP or base URL

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _subscription = _connectivityService.connectionStatusStream.listen((hasConnection) {
      setState(() {
        _hasInternet = hasConnection;
      });
      if (!_hasInternet) {
        _showNoInternetScreen();
      } else {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    });
  }

  void _checkConnectivity() async {
    _hasInternet = await _connectivityService.checkConnectivity();
    if (!_hasInternet) {
      _showNoInternetScreen();
    }
  }

  void _showNoInternetScreen() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const NoInternetScreen()));
  }

  @override
  void dispose() {
    _subscription.cancel();
    _connectivityService.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  Future<void> _registerUser() async {
    // Start loading
    setState(() {
      _isLoading = true;
    });

    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar('Please fill in all fields', Colors.red);
      setState(() {
        _isLoading = false; // Stop loading
      });
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('Passwords do not match', Colors.red);
      setState(() {
        _isLoading = false; // Stop loading
      });
      return;
    }

    try {
      final Map<String, dynamic> requestData = {
        'user_name': name,
        'user_number': phone,
        'user_password': password,
      };

      print('Request Data: $requestData'); // Debug line

      final response = await http.post(
        Uri.parse(_registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar('Registration Successful', Colors.green);

        // Navigate to login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        final responseData = json.decode(response.body);
        _showSnackBar('Error: ${responseData['detail'] ?? 'Unknown error'}', Colors.red);
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e', Colors.red);
    } finally {
      // Stop loading
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }






  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
  }) {
    IconData getIcon(String label) {
      switch (label.toLowerCase()) {
        case 'name':
          return Icons.person;
        case 'mobile number':
          return Icons.phone;
        case 'password':
        case 'confirm password':
          return Icons.lock;
        default:
          return Icons.input;
      }
    }

    return Container(
        decoration: BoxDecoration(
          color: app_bar_color,
        boxShadow: [
        BoxShadow(
        color: Colors.black.withOpacity(0.25), // Shadow color
        offset: const Offset(0, 4), // Shadow position
        blurRadius: 4, // Blur effect
        ),],
          borderRadius: BorderRadius.circular(10),
      ),
      child : TextField(
      controller: controller,
      obscureText: isPassword,
        style: GoogleFonts.roboto(
          fontSize: dynamicFontSize(context, 18), // Responsive font size
          fontWeight: FontWeight.bold,
          color: Colors.white, // Navy blue text color
        ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.roboto(
          fontSize: dynamicFontSize(context, 18), // Responsive font size
          fontWeight: FontWeight.normal,
          color: Colors.white, // Navy blue text color
        ),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.3),
        prefixIcon: Icon(getIcon(label), color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black, width: 2.0),
        ),
      ),
    )
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: background_color,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            Image.asset(
              'assets/images/logo.png',
              height: MediaQuery.of(context).size.height * 0.2,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            //SizedBox(height: screenHeight * 0.02),
            Text(
              'REGISTER',
              style: GoogleFonts.roboto(
              fontSize: dynamicFontSize(context, 35), // Responsive font size
              fontWeight: FontWeight.bold,
              color: Colors.purple,
              letterSpacing: 1.2,  // Slight spacing for better readability
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  color: Colors.black26,
                  blurRadius: 3,  // Adds a subtle shadow to the title
                ),
              ],
            ),),
            SizedBox(height: screenHeight * 0.04),
            _buildInputField(controller: _nameController, label: 'Name'),
            SizedBox(height: screenHeight * 0.02),
            _buildInputField(controller: _phoneController, label: 'Mobile Number'),
            SizedBox(height: screenHeight * 0.02),
            _buildInputField(controller: _passwordController, label: 'Password', isPassword: true),
            SizedBox(height: screenHeight * 0.02),
            _buildInputField(controller: _confirmPasswordController, label: 'Confirm Password', isPassword: true),
            SizedBox(height: screenHeight * 0.03),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15), // Same vertical padding
                backgroundColor: _isLoading ? Colors.grey : button_color, // Change color during loading
                minimumSize: const Size(double.infinity, 0), // Ensures full width
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Same border radius
                ),
              ),
              onPressed: _isLoading ? null : _registerUser, // Disable button when loading
              child: _isLoading
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: button_color, // Spinner color
                  ),
                ],
              )
                  : Text(
                'Register',
                style: GoogleFonts.roboto(
                  fontSize: dynamicFontSize(context, 20), // Responsive font size
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),




            SizedBox(height: screenHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 Text(
                  "Already have an account?",
                  style: GoogleFonts.roboto(
                    fontSize: dynamicFontSize(context, 16), // Responsive font size
                    fontWeight: FontWeight.w500,
                    color: Colors.black, // Navy blue text color
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child:  Text(
                    "Login",
                    style: GoogleFonts.roboto(
                      fontSize: dynamicFontSize(context, 17), // Responsive font size
                      fontWeight: FontWeight.bold,
                      color: Colors.purple, // Navy blue text color
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
