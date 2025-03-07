import 'dart:async';
import 'package:embassycargo/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class OtpVerificationScreen extends StatefulWidget {
  final Map<String, dynamic> orderDetails;

  OtpVerificationScreen({required this.orderDetails});

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final int _otpLength = 6;
  List<TextEditingController> _otpControllers = [];
  Timer? _timer;
  int _remainingTime = 40;
  bool _isResendDisabled = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(_otpLength, (_) => TextEditingController());
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Collect OTP from all TextFields
  String _getOtpFromFields() {
    return _otpControllers.map((controller) => controller.text.trim()).join();
  }
  void showSuccessAnimation(BuildContext context) {
    // Show the success animation dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Lottie.asset(
          'assets/animations/order_success.json', // path to your animation
          repeat: false,
          onLoaded: (composition) {
            // Once the animation is loaded, set up a delay to close the dialog
            Future.delayed(
              composition.duration,
                  () {
                Navigator.pop(context); // Close the animation dialog
              },
            );
          },
        ),
      ),
    );

    // After a delay (3 seconds), navigate through the screens
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pop(); // Close the success animation dialog

      // Close the OTP verified dialog (if it's open)
      Navigator.of(context).pop(); // Close OTP verified screen

      // Navigate back to the home screen, removing the booking and OTP screens from the stack
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/home', // Your home screen route
            (Route<dynamic> route) => false, // Remove all previous routes (booking and OTP)
      );
    });
  }
  // Verify OTP and save the order if OTP is correct
  Future<void> verifyOtp() async {
    final enteredOtp = _getOtpFromFields();

    // Validate if OTP is fully entered
    if (enteredOtp.length != _otpLength) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please enter a valid OTP",style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      )),backgroundColor: Colors.blue,));
      return;
    }

    final url = Uri.parse('http://64.23.143.44:8000/create_order'); // API URL

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'order_details': widget.orderDetails,
          'entered_otp': enteredOtp,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        // Successfully created the order, navigate back
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Order created successfully",style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        )),backgroundColor: Colors.blue,));
        // Navigator.pop(context);
        showSuccessAnimation(context);
      } else {
        // OTP verification failed
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Invalid OTP or OTP expired",style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        )),backgroundColor: Colors.blue,));
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Error during API call
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e",style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      )),backgroundColor: Colors.blue,));
    }
  }

  // Start the OTP resend timer
  void _startTimer() {
    setState(() {
      _isResendDisabled = true;
      _remainingTime = 180;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _isResendDisabled = false;
          _timer?.cancel();
        }
      });
    });
  }

  // Resend OTP logic
  Future<void> _resendOtp() async {
    final url = Uri.parse('http://64.23.143.44:8000/send_otp'); // API URL
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'sender_number': widget.orderDetails['sender_number'],
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("OTP resent successfully",style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        )),backgroundColor: Colors.blue,));
        _startTimer();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Failed to resend OTP",style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        )),backgroundColor: Colors.blue,));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e",style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      )),backgroundColor: Colors.blue,));
    }
  }

  // Format the remaining time for the timer
  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  // Build OTP input fields
  Widget _buildOTPFields(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(_otpLength, (index) {
        return SizedBox(
          width: screenWidth * 0.12,
          child: TextFormField(
            controller: _otpControllers[index],
            maxLength: 1,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontSize: 24,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              counterText: '',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.black,
                  width: 2.0,
                ),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < _otpLength - 1) {
                FocusScope.of(context).nextFocus();
              }
              if (value.isEmpty && index > 0) {
                FocusScope.of(context).previousFocus();
              }
            },
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: background_color,
      appBar: AppBar(
        title: Text(
          'OTP Verification',
          style: GoogleFonts.roboto(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: app_bar_color,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.05),
            Text(
              "Verify Your Number",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              "Enter the OTP sent to your phone",
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: screenHeight * 0.04),
            _buildOTPFields(screenWidth),
            SizedBox(height: screenHeight * 0.04),
            _isLoading
                ? CircularProgressIndicator(color: button_color,)
                : ElevatedButton(
              onPressed: verifyOtp,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: button_color,
                minimumSize: const Size(double.infinity, 0), // Ensures full width
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Same border radius
                ),
              ),
              child: Text(
                "Verify OTP",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            TextButton(
              onPressed: _isResendDisabled ? null : _resendOtp,
              child: Text(
                _isResendDisabled
                    ? "Resend OTP in ${_formatTime(_remainingTime)}"
                    : "Resend OTP",
                style: TextStyle(
                  fontSize: 16,
                  color:
                  _isResendDisabled ? Colors.black : Colors.purple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



