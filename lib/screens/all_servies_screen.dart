import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';  // Import google_fonts package for dynamic font usage
import '../utils/colors.dart'; // Ensure this imports your color definitions

class AllServiesScreen extends StatefulWidget {
  const AllServiesScreen({super.key});

  @override
  _AllServiesScreenState createState() => _AllServiesScreenState();
}

class _AllServiesScreenState extends State<AllServiesScreen> {

  Future<bool> _onWillPop() async {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Fetch screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;

    // Check for landscape orientation
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

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
              elevation: 4,
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: Text(
                'All Services',
                style: GoogleFonts.roboto(
                  fontSize: 22,
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
                    color: background_color, // Yellow background color
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    border: Border.all(
                      color: app_bar_color, // Navy blue stroke (border)
                      width: 2.0, // Thickness of the stroke
                    ),
                    // boxShadow: [
                    //   BoxShadow(color: Colors.black, offset: Offset(0, 6), blurRadius: 9),
                    // ],
                  ),
                  child: Card(
                    color: background_color,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Services',
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Service is the lifeblood of any organization. Everything flows from it and is nourished by it. Customer service is not a department; it’s an attitude',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Air freight :',
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Image.asset('assets/images/Air-Freight.png'),
                          const SizedBox(height: 15),
                          Text(
                            'We are the most highly & experienced professional team in logistics managements. Collaborating with comprehensive agent world wide network enables us to offer very comprehensive freight rates and best services.',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'World Wide Express :',
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Image.asset('assets/images/WorldWideExpress.png'),
                          const SizedBox(height: 15),
                          Text(
                            'All our courier packages are treated as our personal luggage & we can deliver all packages with more security, reliability, cost effectively with on time proof of delivery.',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Express Courier :',
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Image.asset('assets/images/ExpressCourior.png'),
                          const SizedBox(height: 15),
                          Text(
                            'When you send a document, parcel or pallet, the delivery time matters. With our Express service we make sure your shipment is delivered worldwide the next possible working day.',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Ocean Freight :',
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Image.asset('assets/images/shipbg.png'),
                          const SizedBox(height: 15),
                          Text(
                            'We offer both Full Container Loads (FCL) and Less than Container Loads (LCL). On an export front we offer sea freight solutions customized to your needs with reliability managing all logistics procedure.',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Local Courier Service :',
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Image.asset('assets/images/LocalCourior.png'),
                          const SizedBox(height: 15),
                          Text(
                            'Local Express service on reliable door to door solutions for time-critical packages to be delivered within the island wide. Overnight Delivery Service: (Next Day Delivery), Time definite deliver (Same Day Delivery).',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Customs Clearing :',
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Image.asset('assets/images/CustomCleared.png'),
                          const SizedBox(height: 15),
                          Text(
                            'We have a specialist team who are professionals in the customs clearing and freight forwarding industry. Our customs clearing department is a strong team of highly qualified and committed employees.',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
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

