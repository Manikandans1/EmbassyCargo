import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';  // Importing GoogleFonts package
import '../utils/colors.dart';

class CargoClearingCenterScreen extends StatefulWidget {
  const CargoClearingCenterScreen({super.key});

  @override
  _CargoClearingCenterScreenState createState() => _CargoClearingCenterScreenState();
}

class _CargoClearingCenterScreenState extends State<CargoClearingCenterScreen> {

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

  Future<bool> _onWillPop() async {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    TextStyle defaultTextStyle = GoogleFonts.roboto(
      fontSize: dynamicFontSize(context, 16), // Responsive font size
      color: Colors.black,
    );

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: background_color,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),  // You can adjust the height if needed
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),  // Adjust to your desired roundness
            ),
            child: AppBar(
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  color: app_bar_color,
                ),
              ),
              elevation: 4, // Add slight elevation for shadow effect
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: Text(
                'Cargo Clearing Center',
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
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Cargo Clearing Centers - Sri Lanka',
                style: GoogleFonts.roboto(
                  fontSize: dynamicFontSize(context, 20), // Responsive font size
                  fontWeight: FontWeight.bold,
                  color: Colors.purple, // Navy blue text color
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: background_color, // Yellow background color
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  border: Border.all(
                    color: app_bar_color, // Navy blue stroke (border)
                    width: 1.0, // Thickness of the stroke
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black, offset: Offset(0, 6), blurRadius: 9),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ceylon Shipping Lines (Pvt) Ltd',
                      style: GoogleFonts.roboto(
                        fontSize: dynamicFontSize(context, 18), // Responsive font size
                        fontWeight: FontWeight.bold,
                        color: Colors.purple, // Navy blue text color
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Colombo +94 117 204 999, \n+94 77 744 9440\nKandy +94 77 744 9441\nAddalachchenal +94 77 744 9440, \n+94 67 227 7302',
                      style: defaultTextStyle, // Using GoogleFonts.roboto for text styling
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'MIDCO: Peliyagoda, Colombo',
                      style: GoogleFonts.roboto(
                        fontSize: dynamicFontSize(context, 18), // Responsive font size
                        fontWeight: FontWeight.bold,
                        color: Colors.purple, // Navy blue text color
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tel: +94 777 449 442',
                      style: defaultTextStyle, // Using GoogleFonts.roboto for text styling
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Transco International Cargo Services PVT Ltd',
                      style: GoogleFonts.roboto(
                        fontSize: dynamicFontSize(context, 18), // Responsive font size
                        fontWeight: FontWeight.bold,
                        color: Colors.purple, // Navy blue text color
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Colombo +94 77744 9441\nDambulla +94 72244 4435',
                      style: defaultTextStyle, // Using GoogleFonts.roboto for text styling
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
