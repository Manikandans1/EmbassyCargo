import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart'; // Import Lottie package
import '../utils/colors.dart'; // Import your custom color utilities
import 'package:http/http.dart' as http;
import 'package:embassycargo/screens/keys.dart'; // Ensure 'keys.dart' has your SecretKey defined.
import 'package:flutter/foundation.dart';


class PayScreen extends StatefulWidget {
  final String trackingId;
  final double boxCharges;
  final double fridgeCharges;

  const PayScreen({
    super.key,
    required this.trackingId,
    required this.boxCharges,
    required this.fridgeCharges,
  });

  @override
  _PayScreenState createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  String? selectedPaymentOption;



  Future<bool> _onWillPop() async {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return false;
    }
    return true;
  }


  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    final totalAmount = widget.boxCharges + widget.fridgeCharges;


    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
      backgroundColor: background_color,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
          child: AppBar(
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                //color: Colors.blue,
                color: app_bar_color,
              ),
            ),
            elevation: 4,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title:  Text(
              'Payment',
              style: GoogleFonts.roboto(
                fontSize: screenWidth * 0.05, // Responsive font size
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx > 20) {
            Navigator.pop(context);
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.03),
              Text(
                'Cargo bill',
                style: GoogleFonts.roboto(
                  fontSize: screenWidth * 0.05, // Responsive font size
                  fontWeight: FontWeight.bold,
                  color: Colors.purple, // Navy blue text color
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              //summaryRow('Box Charge', '\AED ${widget.boxCharges.toStringAsFixed(2)}'),
              summaryRow('Box Charge', '\AED${widget.boxCharges.toStringAsFixed(2)}'),
              summaryRow('Freight Charge', '\AED${widget.fridgeCharges.toStringAsFixed(2)}'),
              const Divider(color: Colors.grey),
              summaryRow('Total amount', '\AED${(widget.boxCharges + widget.fridgeCharges).toStringAsFixed(2)}', isBold: true),
              SizedBox(height: screenHeight * 0.03),

              Text(
                'Payment options',
                style: GoogleFonts.roboto(
                  fontSize: screenWidth * 0.05, // Responsive font size
                  fontWeight: FontWeight.bold,
                  color: Colors.purple, // Navy blue text color
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Select payment method to proceed',
                style: GoogleFonts.roboto(
                  fontSize: screenWidth * 0.043, // Responsive font size
                  fontWeight: FontWeight.normal,
                  color: Colors.deepPurpleAccent, // Navy blue text color
                ),
              ),
              SizedBox(height: screenHeight * 0.04),

              // Payment Options
              paymentContainer(
                title: 'Card Payment',
                description: 'Pay securely using your credit or debit card.',
                icon: Icons.credit_card,
                isSelected: selectedPaymentOption == 'Card Payment',
                onTap: () {
                  setState(() {
                    selectedPaymentOption = 'Card Payment';
                  });
                },
              ),

              SizedBox(height: screenHeight * 0.03),

              paymentContainer(
                title: 'Cash on Delivery',
                description: 'Pay in cash when your order is delivered.',
                icon: Icons.attach_money,
                isSelected: selectedPaymentOption == 'Cash on Delivery',
                onTap: () {
                  setState(() {
                    selectedPaymentOption = 'Cash on Delivery';
                  });
                },
              ),
              SizedBox(height: screenHeight * 0.03),

              if (selectedPaymentOption != null)
                ElevatedButton(
                  onPressed: _isLoading
                      ? null // Disable button while loading
                      : () async {
                    setState(() {
                      _isLoading = true; // Start loading indicator
                    });

                    try {
                      if (selectedPaymentOption == 'Cash on Delivery') {
                        await _processCODPayment(context); // Process COD payment
                       } else if (selectedPaymentOption == 'Card Payment') {
                        await _processCardPayment(); // Process Card payment
                      }
                    } catch (e) {
                      _showErrorDialog(context, "Error: $e");
                    } finally {
                      setState(() {
                        _isLoading = false; // Stop loading indicator
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: button_color,
                    minimumSize: const Size(double.infinity, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: button_color) // Show loading indicator when processing
                      : Text(
                    selectedPaymentOption == 'Card Payment'
                        ? 'Proceed  \AED${totalAmount.toStringAsFixed(2)}'
                        : 'Pay  \AED${totalAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.roboto(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              SizedBox(height: screenHeight * 0.03),
            ],
          ),
        ),
      ),
        ),
    );
  }
  Future<void> _processCODPayment(BuildContext context) async {
    try {
      // Call the backend to send the order details for COD payment
      await sendOrderToBackend(paymentMethod: 'COD');
      showSuccessAnimation(context); // Show success animation on successful payment
    } catch (e) {
      _showErrorDialog(context, "Error processing COD payment: $e");
    }
  }

  Future<void> _processCardPayment() async {
    final totalAmount = widget.boxCharges + widget.fridgeCharges;

    try {
      // Initialize Stripe only if not already set
      if (1 == 1) {
        WidgetsFlutterBinding.ensureInitialized();
        Stripe.publishableKey = PublishableKey; // Add your publishable key
        await Stripe.instance.applySettings();
        //await paymentSheetInitializationn(totalAmount.toString(), "AED");
      }

      // Initialize the payment sheet
      await paymentSheetInitializationn(totalAmount.toString(), "AED");
    } catch (e) {
      _showErrorDialog(context, "Payment failed: $e");
    }
  }


  Future<void> sendOrderToBackend({required String paymentMethod}) async {
    await Future.delayed(Duration(seconds: 2)); // Simulate a delay for backend call
    print("Order sent with payment method: $paymentMethod");
  }

  Future<void> paymentSheetInitializationn(String amountToCharge, String currency) async {
    try {
      // Create payment intent
      final Map<String, dynamic>? intentPaymentData = await makeIntentForPaymentt(amountToCharge, currency);

      if (intentPaymentData != null) {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: intentPaymentData["client_secret"],
            merchantDisplayName: "Embassy Cargo",
          ),
        );

        // Show Payment Sheet
        await Stripe.instance.presentPaymentSheet();
        if (kDebugMode) {
          print("Payment successful!");
        }

        // Handle success (optional: navigate or show a success message)
        showSuccessAnimation(context);
      } else {
        if (kDebugMode) {
          print("Failed to initialize payment sheet.");
        }
      }
    } on StripeException catch (e) {
      if (kDebugMode) {
        print("StripeException: $e");
      }
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          backgroundColor: button_color, // Set the background color
          content: Text(
            "Payment Cancelled",
            style: GoogleFonts.roboto(
              fontSize: dynamicFontSize(context, 18), // Responsive font size
              fontWeight: FontWeight.bold,
              color: Colors.white, // Navy blue text color
            ), // Set the text style
            textAlign: TextAlign.center, // Center text horizontally
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Add rounded corners
          ),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error initializing payment sheet: $e");
      }
    }
  }
  Future<Map<String, dynamic>?> makeIntentForPaymentt(
      String amountToCharge, String currency) async {
    try {
      // Convert amount to cents (integer) for Stripe
      final int amountInCents = (double.parse(amountToCharge) * 100).toInt();

      final Map<String, String> paymentData = {
        "amount": amountInCents.toString(),
        "currency": currency,
        "payment_method_types[]": "card",
      };

      final response = await http.post(
        Uri.parse("https://api.stripe.com/v1/payment_intents"),
        headers: {
          "Authorization": "Bearer $SecretKey",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: paymentData,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        if (kDebugMode) {
          print("Error creating payment intent: ${response.body}");
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error creating payment intent: $e");
      }
      return null;
    }
  }

  Widget paymentContainer({
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 15,
          horizontal: screenWidth * 0.04,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected ? app_bar_color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey, width: 1.5),
          boxShadow: isSelected
              ? [
            const BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.02),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: Colors.grey,
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                color: isSelected ? app_bar_color : Colors.black54,
                size: screenWidth * 0.07, // Scaled icon size
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.roboto(
                      fontSize: screenWidth * 0.045, // Scaled font size for title
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : app_bar_color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.roboto(
                      fontSize: screenWidth * 0.035, // Scaled font size for description
                      color: isSelected ? Colors.white : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.white,
                size: screenWidth * 0.07, // Scaled check icon size
              ),
          ],
        ),
      ),
    );
  }


  Widget summaryRow(String title, String amount, {bool isBold = false}) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: screenWidth * 0.043, // Responsive font size
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.deepPurple, // Navy blue text color
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.roboto(
              fontSize: screenWidth * 0.043, // Responsive font size
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.deepPurpleAccent, // Navy blue text color
            ),
          ),
        ],
      ),
    );
  }
  void showSuccessAnimation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Lottie.asset(
          'assets/animations/order_success.json',
          repeat: false,
          onLoaded: (composition) {
            Future.delayed(
              composition.duration,
                  () => Navigator.pop(context),
            );
          },
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pop(); // Close the success dialog
      //Navigator.of(context).pop(); // Close the OTP dialog
      // Navigator.of(context).pop();

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/home', // Replace with your home screen route
            (Route<dynamic> route) => false, // Remove all previous routes
      );
    });
  }

  // Dynamic font size adjustment based on screen width
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

bool _isLoading = false;

void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text("OK"),
          ),
        ],
      );
    },
  );
}