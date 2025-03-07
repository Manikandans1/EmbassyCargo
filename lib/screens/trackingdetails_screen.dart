// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../utils/colors.dart'; // Assuming your colors file is correctly imported
//
// class TrackingDetailsScreen extends StatefulWidget {
//   final Map<String, dynamic> trackingData;
//
//   const TrackingDetailsScreen({Key? key, required this.trackingData}) : super(key: key);
//
//   @override
//   _TrackingDetailsScreenState createState() => _TrackingDetailsScreenState();
// }
//
// class _TrackingDetailsScreenState extends State<TrackingDetailsScreen> with TickerProviderStateMixin {
//   List<AnimationController> _controllers = [];
//   int _currentStep = 0; // Track the current step being animated
//   bool _failed = false; // Track if any step has failed
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize animation controllers for each step
//     for (int i = 0; i < 6; i++) {
//       _controllers.add(AnimationController(
//         vsync: this,
//         duration: const Duration(seconds: 2),
//       ));
//     }
//     _startStepAnimation();
//   }
//
//   @override
//   void dispose() {
//     for (var controller in _controllers) {
//       controller.dispose(); // Dispose all controllers
//     }
//     super.dispose();
//   }
//   // Method to start the animation for each step
//   void _startStepAnimation() {
//     // Only animate if no step has failed
//     if (_currentStep < _controllers.length && !_failed) {
//       _controllers[_currentStep].forward().then((_) {
//         // Check the current step's status
//         var currentStatus = widget.trackingData[_getStepKey(_currentStep)];
//         if (currentStatus == false) {
//           setState(() {
//             _failed = true; // Mark as failed
//           });
//         } else {
//           setState(() {
//             _currentStep++; // Move to the next step
//           });
//           _startStepAnimation(); // Continue animating the next step if not failed
//         }
//       });
//     }
//   }
//
//   // Get step key based on the step index
//   String _getStepKey(int index) {
//     switch (index) {
//       case 0:
//         return 'order_confirmed';
//       case 1:
//         return 'package_pickup';
//       case 2:
//         return 'move_to';
//       case 3:
//         return 'clear_custom';
//       case 4:
//         return 'ready_to_delivery';
//       case 5:
//         return 'package_delivered';
//       default:
//         return '';
//     }
//   }
//
//   // Determines the color for the step indicator based on the status
//   Color getStepColor(int index, dynamic status) {
//     if (index == _currentStep && status == false) return Colors.red; // Red when the current step fails
//     if (index < _currentStep) return Colors.green; // Green for completed steps
//     if (index == _currentStep && status != null) return secondary; // Blue for the current step
//     return Colors.grey; // Grey for pending steps
//   }
//
//   // Determines the text for the status
//   String getStatusText(dynamic status) {
//     if (status == true) return 'Completed'; // Completed for true
//     if (status == false) return 'Failed'; // Failed for false
//     return 'Pending'; // Pending for null or unknown
//   }
//
//   // Widget for a step in the tracking flow with dynamic vertical line
//   Widget buildStep(String title, dynamic status, int stepIndex, bool isLastStep) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Column(
//           children: [
//             // Circle for the step
//             Container(
//               width: 20,
//               height: 20,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: getStepColor(stepIndex, status), // Step color based on status
//               ),
//               child: Icon(
//                 stepIndex < _currentStep
//                     ? Icons.check  // Checkmark for completed (green)
//                     : (status == false && stepIndex == _currentStep ? Icons.close : null), // Cross for failed (red)
//                 color: Colors.white,
//                 size: 14,
//               ),
//             ),
//             if (!isLastStep) // Only show the vertical line if it's not the last step
//               AnimatedBuilder(
//                 animation: _controllers[stepIndex],
//                 builder: (context, child) {
//                   return Container(
//                     width: 2,
//                     height: 60 * _controllers[stepIndex].value, // Animated progress line
//                     color: getStepColor(stepIndex, status), // Dynamic line color based on step status
//                   );
//                 },
//               ),
//           ],
//         ),
//         const SizedBox(width: 12),
//         // Step text
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: GoogleFonts.roboto(
//                 fontSize: screenWidth * 0.045, // Responsive font size
//                 fontWeight: FontWeight.bold,
//                 color: getStepColor(stepIndex, status), // Navy blue text color
//               ),
//             ),
//             const SizedBox(height: 5),
//             // Status text color also changes dynamically based on status
//             Text(
//               getStatusText(status),
//               style: GoogleFonts.roboto(
//                 fontSize: screenWidth * 0.035, // Responsive font size
//                 fontWeight: FontWeight.bold,
//                 color: getStepColor(stepIndex, status), // Navy blue text color
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Future<bool> _onWillPop() async {
//     if (Navigator.canPop(context)) {
//       Navigator.pop(context);
//       return false;
//     }
//     return true;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final tracking = Map<String, dynamic>.from(widget.trackingData['tracking'] ?? {});
//     final sender = Map<String, dynamic>.from(widget.trackingData['sender'] ?? {});
//     final receiver = Map<String, dynamic>.from(widget.trackingData['receiver'] ?? {});
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         backgroundColor: background_color,
//         appBar: AppBar(
//           backgroundColor: Color(0xFF132F40), // Assuming your secondary color is imported
//           iconTheme: IconThemeData(
//             color: Colors.white, // Set the back arrow color
//           ),
//           title: Text(
//             'Tracking Details',
//             style: GoogleFonts.roboto(
//               fontSize: screenWidth * 0.05, // Responsive font size
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//               letterSpacing: 1.2,
//               shadows: [
//                 Shadow(
//                   offset: Offset(1, 1),
//                   color: Colors.black26,
//                   blurRadius: 3, // Adds a subtle shadow to the title
//                 ),
//               ],
//             ),
//           ),
//           centerTitle: true,
//         ),
//         body: SingleChildScrollView(
//           padding: EdgeInsets.all(screenWidth * 0.04), // Dynamic padding based on screen width
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Tracking ID: #${widget.trackingData['tracking_id']}',
//                 style: GoogleFonts.roboto(
//                   fontSize: screenWidth * 0.055,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               SizedBox(height: screenHeight * 0.02),
//               Text(
//                 'Tracking Steps',
//                 style: GoogleFonts.roboto(
//                   fontSize: screenWidth * 0.048,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.purple, // Assuming `primaryColor` is imported
//                 ),
//               ),
//               SizedBox(height: screenHeight * 0.02),
//               buildStep('Order Confirmed', widget.trackingData['order_confirmed'], 0, false),
//               buildStep('Package Pickup', widget.trackingData['package_pickup'], 1, false),
//               buildStep('Move To Destination', widget.trackingData['move_to'] != null && widget.trackingData['move_to'] != 'NO', 2, false),
//               buildStep('Cleared Customs', widget.trackingData['clear_custom'], 3, false),
//               buildStep('Ready for Delivery', widget.trackingData['ready_to_delivery'], 4, false),
//               buildStep('Package Delivered', widget.trackingData['package_delivered'], 5, true), // Last step
//               SizedBox(height: screenHeight * 0.02),
//               Text(
//                 'Service Charges',
//                 style: GoogleFonts.roboto(
//                   fontSize: screenWidth * 0.055,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.purple, // Assuming `primaryColor` is imported
//                 ),
//               ),
//               _buildDetailRow('Cargo Service Charge', '\AED${sender['service_charge'] ?? 'N/A'}'),
//               SizedBox(height: screenHeight * 0.02),
//               Text(
//                 'Order Details',
//                 style: GoogleFonts.roboto(
//                   fontSize: screenWidth * 0.055,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.purple, // Assuming `primaryColor` is imported
//                 ),
//               ),
//               _buildDetailRow('Shipping Type', sender['shipping_type'] ?? 'N/A'),
//               _buildDetailRow('CBM', sender['weight_cbm'] ?? 'N/A'),
//               _buildDetailRow('Quantity', sender['quantity'] ?? 'N/A'),
//               _buildDetailRow('Order Value', '\AED${sender['order_value'] ?? 'N/A'}'),
//               SizedBox(height: screenHeight * 0.02),
//               Text(
//                 'Receiver Details',
//                 style: GoogleFonts.roboto(
//                   fontSize: screenWidth * 0.055,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.purple, // Assuming `primaryColor` is imported
//                 ),
//               ),
//               _buildDetailRow('Name', receiver['name'] ?? 'N/A'),
//               _buildDetailRow('Country', receiver['country'] ?? 'N/A'),
//               _buildDetailRow('District', receiver['district'] ?? 'N/A'),
//               _buildDetailRow('City', receiver['city'] ?? 'N/A'),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDetailRow(String title, String value) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           title,
//           style: GoogleFonts.roboto(
//             fontSize: screenWidth * 0.045,
//             fontWeight: FontWeight.bold,
//             color: Colors.deepPurple,
//           ),
//         ),
//         Text(
//           value,
//           style: GoogleFonts.roboto(
//             fontSize: screenWidth * 0.045,
//             fontWeight: FontWeight.normal,
//             color: Colors.deepPurpleAccent,
//           ),
//         ),
//       ],
//     );
//   }
// }






import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart'; // Import your colors

class TrackingDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> trackingData;

  const TrackingDetailsScreen({Key? key, required this.trackingData}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Extract tracking details
    List<String> trackingHistory = List<String>.from(trackingData['tracking_history'] ?? []);
    String currentStatus = trackingData['current_status'] ?? '';
    final sender = Map<String, dynamic>.from(trackingData['sender'] ?? {});
    final receiver = Map<String, dynamic>.from(trackingData['receiver'] ?? {});

    return Scaffold(
      backgroundColor: background_color,
      appBar: AppBar(
        // backgroundColor: const Color(0xFF132F40),
        backgroundColor: app_bar_color,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Tracking Details',
          style: GoogleFonts.roboto(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
            shadows: const [
              Shadow(offset: Offset(1, 1), color: Colors.black26, blurRadius: 3),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tracking ID
            Text(
              'Tracking ID: #${trackingData['tracking_id']}',
              style: GoogleFonts.roboto(
                fontSize: screenWidth * 0.055,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Service Type
            Text(
              'Service Type: ${trackingData['service_type'].toString().toUpperCase()}',
              style: GoogleFonts.roboto(
                fontSize: screenWidth * 0.048,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Tracking Steps Title
            Text(
              'Tracking Steps',
              style: GoogleFonts.roboto(
                fontSize: screenWidth * 0.048,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Dynamically build tracking steps
            ...List.generate(trackingHistory.length, (index) {
              return buildStep(
                trackingHistory[index],
                trackingHistory[index] == currentStatus,
                index == trackingHistory.length - 1, // Check if last step
              );
            }),

            SizedBox(height: screenHeight * 0.02),




            SizedBox(height: screenHeight * 0.02),
            Text(
              'Service Charges',
              style: GoogleFonts.roboto(
                fontSize: screenWidth * 0.055,
                fontWeight: FontWeight.bold,
                color: Colors.purple, // Assuming `primaryColor` is imported
              ),
            ),
            _buildDetailRow(context,'Cargo Service Charge', '\AED${sender['service_charge'] ?? 'N/A'}'),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'Order Details',
              style: GoogleFonts.roboto(
                fontSize: screenWidth * 0.055,
                fontWeight: FontWeight.bold,
                color: Colors.purple, // Assuming `primaryColor` is imported
              ),
            ),
            _buildDetailRow(context,'Shipping Type', sender['shipping_type'] ?? 'N/A'),
            _buildDetailRow(context,'CBM', sender['weight_cbm'] ?? 'N/A'),
            _buildDetailRow(context,'Quantity', sender['quantity'] ?? 'N/A'),
            _buildDetailRow(context,'Order Value', '\AED${sender['order_value'] ?? 'N/A'}'),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'Receiver Details',
              style: GoogleFonts.roboto(
                fontSize: screenWidth * 0.055,
                fontWeight: FontWeight.bold,
                color: Colors.purple, // Assuming `primaryColor` is imported
              ),
            ),
            _buildDetailRow(context,'Name', receiver['name'] ?? 'N/A'),
            _buildDetailRow(context,'Country', receiver['country'] ?? 'N/A'),
            _buildDetailRow(context,'District', receiver['district'] ?? 'N/A'),
            _buildDetailRow(context,'City', receiver['city'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  // Determines the color for the step indicator
  Color getStepColor(bool isCurrentStep) {
    return isCurrentStep ? secondary : Colors.green;
  }

  // Build tracking step dynamically
  Widget buildStep(String title, bool isCurrentStep, bool isLastStep) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: getStepColor(isCurrentStep),
              ),
              child: Icon(
                isCurrentStep ? Icons.radio_button_checked : Icons.check,
                color: Colors.white,
                size: 14,
              ),
            ),
            if (!isLastStep)
              Container(
                width: 2,
                height: 50,
                color: Colors.green,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: getStepColor(isCurrentStep),
          ),
        ),
      ],
    );
  }
  Widget _buildDetailRow(BuildContext context, String title, String value) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.roboto(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.normal,
            color: Colors.deepPurpleAccent,
          ),
        ),
      ],
    );
  }
}
