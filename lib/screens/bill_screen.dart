import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import '../services/connectivity_service.dart';
import '../utils/colors.dart'; // Custom colors file
import 'no_internet_screen.dart';
import 'pay_screen.dart';

class OnlinePaymentScreen extends StatefulWidget {
  const OnlinePaymentScreen({super.key});

  @override
  _OnlinePaymentScreenState createState() => _OnlinePaymentScreenState();
}

class _OnlinePaymentScreenState extends State<OnlinePaymentScreen> {
  final ConnectivityService _connectivityService = ConnectivityService();
  late StreamSubscription<bool> _subscription;
  bool _hasInternet = true;
  final TextEditingController _trackingIdController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
  }

  void _initializeConnectivity() {
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
    _trackingIdController.dispose();
    super.dispose();
  }

  Future<void> _fetchPaymentDetailsAndNavigate() async {
    final trackingId = _trackingIdController.text.trim();
    if (trackingId.isEmpty) {
      _showSnackbar('Please enter a valid Tracking ID');
      return;
    }

    final url = Uri.parse('http://64.23.143.44:8000/get-charges/$trackingId');
    //final url = Uri.parse('http://192.168.175.53:8000/get-charges/$trackingId');
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final double boxCharges = double.tryParse(data['box_charges'].toString()) ?? 0.0;
        final double fridgeCharges = double.tryParse(data['freight_charges'].toString()) ?? 0.0;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PayScreen(
              trackingId: trackingId,
              boxCharges: boxCharges,
              fridgeCharges: fridgeCharges,
            ),
          ),
        );
      } else {
        _showSnackbar('Failed to fetch payment details');
      }
    } catch (e) {
      _showSnackbar('Please check your internet connection.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }



  Future<bool> _onWillPop() async {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return false;
    }
    return true;
  }

  double dynamicFontSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double aspectRatio = screenWidth / screenHeight;

    if (aspectRatio < 0.5) {
      return baseSize * 0.8;
    } else if (aspectRatio > 0.7) {
      return baseSize * 1.2;
    }
    return baseSize;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: _onWillPop,
        child: Container(
      child: Scaffold(
        backgroundColor: background_color,
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: screenHeight * 0.04),
                        Image.asset(
                          'assets/images/pay.png',
                          height: screenHeight * 0.2,
                        ),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                          child: Column(
                            children: [
                              SizedBox(height: screenHeight * 0.04),
                              Text(
                                'To settle your pending payment, please enter the correct Tracking Number',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.roboto(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.05),
                              CustomTextField(
                                controller: _trackingIdController,
                                label: 'Enter Your Tracking Id',
                                keyboardType: TextInputType.name,
                              ),
                              SizedBox(height: screenHeight * 0.04),
                              // ElevatedButton(
                              //   onPressed: _isLoading ? null : _fetchPaymentDetailsAndNavigate,
                              //   style: ElevatedButton.styleFrom(
                              //     padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                              //     backgroundColor: button_color,
                              //     minimumSize: Size(double.infinity, screenHeight * 0.06),
                              //     shape: RoundedRectangleBorder(
                              //       borderRadius: BorderRadius.circular(10),
                              //     ),
                              //   ),
                              //   child: _isLoading
                              //       ? CircularProgressIndicator(color: button_color)
                              //       : Text(
                              //     'Pay Now',
                              //     style: GoogleFonts.roboto(
                              //       fontSize: screenWidth * 0.05,
                              //       fontWeight: FontWeight.bold,
                              //       color: Colors.black,
                              //     ),
                              //   ),
                              // ),

                              ElevatedButton(
                                onPressed: _isLoading ? null : _fetchPaymentDetailsAndNavigate,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                                  backgroundColor: button_color,
                                  minimumSize: Size(double.infinity, screenHeight * 0.06),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: _isLoading
                                    ? CircularProgressIndicator(color: Colors.white)
                                    : Shimmer.fromColors(
                                        baseColor: Colors.black, // Normal text color
                                        highlightColor: Colors.white, // Shimmer effect color
                                        child: Text(
                                          'Pay Now',
                                          style: GoogleFonts.roboto(
                                            fontSize: screenWidth * 0.05,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black, // Default color (for when shimmer is off)
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
        ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        color: app_bar_color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: Offset(0, screenHeight * 0.004),
            blurRadius: screenHeight * 0.004,
          ),
        ],
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.roboto(
          fontSize: screenWidth * 0.045,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.roboto(
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
            borderSide: BorderSide(color: Colors.black, width: screenWidth * 0.005),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
            borderSide: BorderSide(
              color: Colors.black,
              width: screenWidth * 0.007,
            ),
          ),
        ),
      ),
    );
  }
}


