import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  Future<bool> _onWillPop() async {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return false;
    }
    return true;
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    // Dynamic font size based on screen width
    double dynamicFontSize(double size) {
      return size * (screenWidth / 375); // 375 is the base screen width for scaling
  }

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
                  color: app_bar_color,
                ),
              ),
              elevation: 4,
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: Text(
                'About Us',
                style: GoogleFonts.roboto(
                  fontSize: dynamicFontSize(22),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                  shadows: const [
                    Shadow(
                      offset: Offset(1, 1),
                      color: Colors.black26,
                      blurRadius: 3,
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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: background_color,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: app_bar_color,
                      width: 2.0,
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black, offset: Offset(0, 6), blurRadius: 9),
                    ],
                  ),
                  child: Card(
                    color: background_color,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      // side: const BorderSide(
                      //   color: Colors.white,
                      //   width: 1,
                      // ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About Us',
                            style: GoogleFonts.roboto(
                              fontSize: dynamicFontSize(18),
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'EMBASSY CARGO: Your Trusted Logistics Partner Since 2003. Delivering Excellence Worldwide.',
                            style: GoogleFonts.roboto(
                              fontSize: dynamicFontSize(16),
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "What We're All About",
                            style: GoogleFonts.roboto(
                              fontSize: dynamicFontSize(18),
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'At EMBASSY CARGO, we are driven by a singular mission: to provide pioneering logistics solutions that propel your success. With a legacy dating back to 2003, we have perfected our expertise to become a trusted industry leader.'
                                ' \nOur global network of offices, hubs, and partners ensures we are where you need us, while our commitment to transparency and innovation sets us apart. We’re not just a logistics provider; we’re your dedicated partner in achieving seamless, efficient, and tailored supply chain solutions.'
                                ' \nDiscover the EMBASSY CARGO difference and experience logistics excellence like never before.',
                            style: GoogleFonts.roboto(
                              fontSize: dynamicFontSize(16),
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Who We Are',
                            style: GoogleFonts.roboto(
                              fontSize: dynamicFontSize(18),
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            "The best cargo is not just a shipment; it's a promise delivered.",
                            style: GoogleFonts.roboto(
                              fontSize: dynamicFontSize(16),
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "EMBASSY CARGO is a company established in 2003 on the scope of Freight Forwarding and Training & Development.",
                            style: GoogleFonts.roboto(
                              fontSize: dynamicFontSize(16),
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Our Vision',
                            style: GoogleFonts.roboto(
                              fontSize: dynamicFontSize(18),
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Best Service. Everytime.',
                            style: GoogleFonts.roboto(
                              fontSize: dynamicFontSize(16),
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Our Mission',
                            style: GoogleFonts.roboto(
                              fontSize: dynamicFontSize(18),
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'We deliver on our promises with precision and guarantee.',
                            style: GoogleFonts.roboto(
                              fontSize: dynamicFontSize(16),
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
