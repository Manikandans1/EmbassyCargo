import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../services/connectivity_service.dart';
import 'no_internet_screen.dart';
import 'trackingdetails_screen.dart';
import '../utils/colors.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({Key? key}) : super(key: key);

  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final ConnectivityService _connectivityService = ConnectivityService();
  late StreamSubscription<bool> _subscription;
  bool _noInternetScreenShown = false;
  final TextEditingController _trackingIdController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _connectivityService.checkConnectivity().then((hasConnection) {
      if (!hasConnection && !_noInternetScreenShown) {
        _showNoInternetScreen();
      }
    });

    _subscription = _connectivityService.connectionStatusStream.listen((hasConnection) {
      if (!hasConnection && !_noInternetScreenShown) {
        _showNoInternetScreen();
      } else if (hasConnection && _noInternetScreenShown) {
        Navigator.pop(context);
        _noInternetScreenShown = false;
      }
    });
  }

  void _showNoInternetScreen() {
    _noInternetScreenShown = true;
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

  Future<void> _trackPackage() async {
    String trackingId = _trackingIdController.text.trim();

    if (trackingId.isEmpty) {
      _showSnackBar('Please enter a valid tracking ID.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      //real server
      final responseSender = await _fetchTrackingData(
          // 'http://192.168.137.1:8000/tracking/details/$trackingId');
          'http://64.23.143.44:8000/tracking/details/$trackingId');
      final responseReceiver = await _fetchTrackingData(
          'http://64.23.143.44:8000/orders/$trackingId/details/');

      if (responseSender != null || responseReceiver != null) {
        Map<String, dynamic> mergedData = {
          ...?responseSender,
          ...?responseReceiver,
        };

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrackingDetailsScreen(trackingData: mergedData),
          ),
        );
      } else {
        _showSnackBar('Tracking ID not found. Please check and try again.');
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<Map<String, dynamic>?> _fetchTrackingData(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching data from $url: $e');
      return null;
    }
  }

  void _showSnackBar(String message) {
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      child: Scaffold(
        backgroundColor: background_color, // Transparent to show the gradient
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.04),
                Image.asset(
                  'assets/images/tracking.png',
                  height: screenHeight * 0.2,
                ),
                SizedBox(height: screenHeight * 0.04),
                Text(
                  'Enter your package tracking number to track your parcel',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                CustomTextField2(
                  controller: _trackingIdController,
                  label: 'Enter Your Tracking ID',
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: screenHeight * 0.04),
                _isLoading
                    ? const CircularProgressIndicator(color: button_color)
                    : ElevatedButton(
                  onPressed: _trackPackage,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                    backgroundColor: button_color, // Button color matching gradient
                    minimumSize: Size(double.infinity, screenHeight * 0.06),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Track Parcel',
                    style: GoogleFonts.roboto(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class CustomTextField2 extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;

  const CustomTextField2({
    Key? key,
    required this.controller,
    required this.label,
    required this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: app_bar_color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(0, 4),
            blurRadius: 4,
          ),
        ],
        borderRadius: BorderRadius.circular(10),
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
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black, width: 2.0),
          ),
        ),
      ),
    );
  }
}
