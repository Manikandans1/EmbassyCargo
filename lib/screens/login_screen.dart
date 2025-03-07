import 'dart:async';
import 'dart:convert';
import 'package:embassycargo/models/login_request.dart';
import 'package:embassycargo/screens/home_screen.dart';
import 'package:embassycargo/screens/no_internet_screen.dart';
import 'package:embassycargo/screens/register_screen.dart';
import 'package:embassycargo/services/api_service.dart';
import 'package:embassycargo/services/connectivity_service.dart';
import 'package:embassycargo/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final ConnectivityService _connectivityService = ConnectivityService();
  final ApiService _apiService = ApiService();
  late StreamSubscription<bool> _subscription;
  bool _hasInternet = true;
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _connectivityService.checkConnectivity().then((hasConnection) {
      setState(() {
        _hasInternet = hasConnection;
      });
      if (!_hasInternet) {
        _showNoInternetScreen();
      }
    });

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

  void _showNoInternetScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NoInternetScreen()),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    _connectivityService.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Set loading state to true at the beginning
    setState(() {
      _isLoading = true;
    });

    final mobile = _mobileController.text.trim();
    final password = _passwordController.text.trim();

    // Validate input fields
    if (mobile.isEmpty || password.isEmpty) {
      _showErrorSnackBar('Please fill in all fields');
      setState(() {
        _isLoading = false; // Reset loading state
      });
      return;
    }

    try {
      // Create login request object
      final loginRequest = LoginRequest(username: mobile, password: password);
      print('Sending login request: ${loginRequest.toJson()}');

      // Send login request to the API
      final response = await _apiService.loginUser(loginRequest);

      // Save the access token to SharedPreferences if login is successful
      if (response.accessToken != null) {
        await SharedPreferences.getInstance().then((prefs) {
          prefs.setString('accessToken', response.accessToken);
          prefs.setString('tokenType', response.tokenType);
        });

        // Show success feedback
        _showSuccessSnackBar('Login successful!');

        // Navigate to HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        _showErrorSnackBar('Failed to log in. Please try again.');
      }
    } catch (e) {
      print('Error during login: $e');
      _showErrorSnackBar('Failed to log in. Please try again.');
    } finally {
      // Reset loading state in finally block
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
          style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
          style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),),
        backgroundColor: primaryColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
            // Login Title
           // SizedBox(height: screenHeight * 0.02),
            Text(
              'LOGIN',
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
              ),
            ),
            SizedBox(height: screenHeight * 0.04),

            // Mobile Input Field
            _buildInputField(
              context,
              controller: _mobileController,
              label: 'Mobile Number',
              icon: Icons.phone,
            ),
            SizedBox(height: screenHeight * 0.03),

            // Password Input Field
            _buildInputField(
              context,
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock,
              isPassword: true,
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: TextButton(
                  onPressed: () {
                    // Navigate to the ForgotPasswordScreen when clicked
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                    );
                  },
                  child: Text(
                    'Forget?',
                    style: GoogleFonts.roboto(
                      fontSize: dynamicFontSize(context, 16), // Responsive font size
                      fontWeight: FontWeight.bold,
                      color: button_color, // Navy blue text color
                    ),
                  ),
                ),
              ),

            ),
            SizedBox(height: screenHeight * 0.03),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: _isLoading ? Colors.grey : button_color, // Disable color when loading
                minimumSize: const Size(double.infinity, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _isLoading ? null : _login, // Disable button while loading
              child: _isLoading
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: button_color, // Adjust loading indicator color
                    //strokeWidth: 2.0, // Make the indicator lightweight
                  ),
                ],
              )
                  : Text(
                'Login',
                style: GoogleFonts.roboto(
                  fontSize: dynamicFontSize(context, 20),
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
                  "Don’t have an account?",
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
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child:  Text(
                    "Sign Up",
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
  Widget _buildInputField(
      BuildContext context, {
        required TextEditingController controller,
        required String label,
        required IconData icon,
        bool isPassword = false,
        Widget? suffixIcon,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: app_bar_color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25), // Shadow color
            offset: const Offset(0, 4), // Shadow position
            blurRadius: 4, // Blur effect
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
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
          prefixIcon: Icon(icon, color: Colors.white),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.grey.withOpacity(0.3), // Background color of the input field
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.grey, // Border color
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.black, // Border color when focused
              width: 2.0,
            ),
          ),
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

//------------forgot Password Screen-----------------------

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _requestOTP() async {
    final String phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter your mobile number.",
          style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,),),
          backgroundColor: primaryColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // API call to request OTP
      final response = await http.post(
        //Uri.parse('http://192.168.137.1:8000/forgot-password/'),
        Uri.parse("http://64.23.143.44:8000/forgot-password/"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"user_number": phoneNumber}),
      );

      if (response.statusCode == 200) {
        // Success, navigate to ResetPasswordScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(userNumber: phoneNumber),
          ),
        );
      } else {
        // Error handling
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send OTP. Please try again.",
            style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,),),
            backgroundColor: primaryColor,),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: background_color,
      appBar: AppBar(
        //backgroundColor: Colors.blue,
        backgroundColor: app_bar_color,
        centerTitle: true,
        title: Text(
          'Forgot Password',
          style: GoogleFonts.roboto(
            fontSize: dynamicFontSize(context, 22), // Responsive font size
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,  // Slight spacing for better readability
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                color: Colors.black26,
                blurRadius: 3,  // Adds a subtle shadow to the title
              ),
            ],
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Change back arrow color
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.12),
            Image.asset(
              'assets/images/tracking.png',
              height: MediaQuery.of(context).size.height * 0.2,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                filled: true,
                fillColor: app_bar_color,
                labelStyle: GoogleFonts.roboto(
                  fontSize: dynamicFontSize(context, 18), // Responsive font size
                  fontWeight: FontWeight.normal,
                  color: Colors.grey, // Navy blue text color
                ), // Set label color to black
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey, width: 2.0),
                ),
              ),
              style: GoogleFonts.roboto(
                fontSize: dynamicFontSize(context, 18), // Responsive font size
                fontWeight: FontWeight.bold,
                color: Colors.white, // Navy blue text color
              ), // Change text color to black
            ),
            SizedBox(height: 25),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _requestOTP,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                //backgroundColor: Colors.blue,
                backgroundColor: button_color,
                minimumSize: const Size(double.infinity, 0), // Ensures full width
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Same border radius
                ),
              ),
              child: Text(
                'Request OTP',
                style: GoogleFonts.roboto(
                  fontSize: dynamicFontSize(context, 20), // Responsive font size
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Navy blue text color
                ),
              ),
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





class ResetPasswordScreen extends StatefulWidget {
  final String userNumber; // Passed from the ForgotPasswordScreen

  ResetPasswordScreen({required this.userNumber});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    final String otp = _otpController.text.trim();
    final String newPassword = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (otp.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields.",
            style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,)),
          backgroundColor: primaryColor,),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match.",
              style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,)),
        backgroundColor: primaryColor,),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // API call to reset the password
      final response = await http.post(
        //Uri.parse('http://192.168.137.1:8000/reset-password/'),
        Uri.parse("http://64.23.143.44:8000/reset-password/"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "user_number": widget.userNumber,
          "otp": otp,
          "new_password": newPassword,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Password reset successfully.",
                style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,)),
            backgroundColor: primaryColor,),
        );
        Navigator.popUntil(context, (route) => route.isFirst); // Go back to login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to reset password.",
                style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,)),
            backgroundColor: primaryColor,),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        //backgroundColor: Colors.blue,
        backgroundColor: secondary,
        centerTitle: true,
        title: Text(
          'Reset Password',
          style: GoogleFonts.roboto(
            fontSize: dynamicFontSize(context, 22), // Responsive font size
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,  // Slight spacing for better readability
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                color: Colors.black26,
                blurRadius: 3,  // Adds a subtle shadow to the title
              ),
            ],
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Change back arrow color
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            Image.asset(
              'assets/images/tracking.png',
              height: MediaQuery.of(context).size.height * 0.2,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'OTP',
                filled: true,
                fillColor: Colors.white,
                labelStyle: GoogleFonts.roboto(
                  fontSize: dynamicFontSize(context, 18), // Responsive font size
                  fontWeight: FontWeight.normal,
                  color: Colors.black, // Navy blue text color
                ), // Label color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black, width: 2.0),
                ),
              ),
              style: GoogleFonts.roboto(
                fontSize: dynamicFontSize(context, 18), // Responsive font size
                fontWeight: FontWeight.bold,
                color: Colors.black, // Navy blue text color
              ), // Change text color
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                filled: true,
                fillColor: Colors.white,
                labelStyle: GoogleFonts.roboto(
                  fontSize: dynamicFontSize(context, 18), // Responsive font size
                  fontWeight: FontWeight.normal,
                  color: Colors.black, // Navy blue text color
                ), // Label color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black, width: 2.0),
                ),
              ),
              style: GoogleFonts.roboto(
                fontSize: dynamicFontSize(context, 18), // Responsive font size
                fontWeight: FontWeight.bold,
                color: Colors.black, // Navy blue text color
              ), // Change text color
            ),
            SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                filled: true,
                fillColor: Colors.white,
                labelStyle: GoogleFonts.roboto(
                  fontSize: dynamicFontSize(context, 18), // Responsive font size
                  fontWeight: FontWeight.normal,
                  color: Colors.black, // Navy blue text color
                ),// Label color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black, width: 2.0),
                ),
              ),
              style: GoogleFonts.roboto(
                fontSize: dynamicFontSize(context, 18), // Responsive font size
                fontWeight: FontWeight.bold,
                color: Colors.black, // Navy blue text color
              ), // Change text color
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _resetPassword,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15), // Same vertical padding
                //backgroundColor: Colors.blue, // Keep primaryColor
                backgroundColor: secondary, // Keep primaryColor
                minimumSize: const Size(double.infinity, 0), // Ensures full width
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Same border radius
                ),
              ),
              child: Text(
                'Reset Password',
                style: GoogleFonts.roboto(
                  fontSize: dynamicFontSize(context, 20), // Responsive font size
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Navy blue text color
                ),
              ),
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
