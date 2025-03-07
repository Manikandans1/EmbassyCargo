import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:embassycargo/screens/about_screen.dart';
import 'package:embassycargo/screens/all_servies_screen.dart';
import 'package:embassycargo/screens/sea_cargo_screen.dart';
import 'package:embassycargo/screens/terms_and_conditions.dart';
import 'package:flutter/material.dart';
import 'package:embassycargo/screens/contact_us_screen.dart';
import 'package:embassycargo/screens/tracking_screen.dart';
import 'package:embassycargo/screens/bill_screen.dart';
import 'package:embassycargo/screens/booking_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/connectivity_service.dart';
import '../utils/colors.dart';
import 'air_cargo_screen.dart';
import 'air_cargo_warehouse.dart';
import 'cargo_clearing_center_screen.dart';
import 'home-cargo_screen.dart';
import 'login_screen.dart';
import 'no_internet_screen.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ConnectivityService _connectivityService = ConnectivityService();
  late StreamSubscription<bool> _subscription;
  bool _hasInternet = true;
  int _selectedIndex = 0;
  DateTime timeBackPressed = DateTime.now();

  @override
  void initState() {
    super.initState();

    // Check initial connectivity status
    _connectivityService.checkConnectivity().then((hasConnection) {
      setState(() {
        _hasInternet = hasConnection;
      });
      if (!_hasInternet) {
        _showNoInternetScreen();
      }
    });

    // Listen to connection status changes
    _subscription = _connectivityService.connectionStatusStream.listen((hasConnection) {
      setState(() {
        _hasInternet = hasConnection;
      });

      if (!_hasInternet) {
        _showNoInternetScreen();
      } else {
        _returnToHomeScreen();
      }
    });
  }

  void _showNoInternetScreen() {
    if (!_hasInternet) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const NoInternetScreen()),
            (route) => false,
      );
    }
  }

  void _returnToHomeScreen() {
    if (Navigator.canPop(context)) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _connectivityService.dispose();
    super.dispose();
  }

  final List<String> _titles = [
    'EMBASSY CARGO',
    'Tracking',
    'Online Payment',
  ];

  // List of screens for navigation
  final List<Widget> _screens = [
    const HomeScreenContent(),
    const TrackingScreen(),
    //const NotificationScreen(),
    OnlinePaymentScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
//  title: Text(_titles[_selectedIndex]),
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final difference = DateTime.now().difference(timeBackPressed);
        final isExitWarning = difference >= Duration(seconds: 2);
        timeBackPressed = DateTime.now();
        if(isExitWarning){
          final message = 'Press back again to exit';
          Fluttertoast.showToast(msg: message,fontSize: 18);
          return false;
        }else{
          Fluttertoast.cancel();
          return true;
        }
      },
      child:  Scaffold(
      backgroundColor: background_color,
      //backgroundColor: Colors.yellow,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),  // You can adjust the height if needed
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20),  // Adjust to your desired roundness
          ),
          child: AppBar(
            // Add a gradient background to the AppBar
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                color: app_bar_color,
               // color: Colors.blue,
              ),
            ),
            elevation: 4, // Add slight elevation for shadow effect
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: Text(_titles[_selectedIndex],
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
            leading: Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  iconSize: 28, // Set the desired icon size here
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),

          ),
        ),
      ),
      drawer: Drawer(

       // backgroundColor: lightWhite,
        backgroundColor: background_color,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: app_bar_color,
                //color: Colors.blue,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: SizedBox(
                      width: 300,
                      height: 300,
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                   Text(
                    'Welcome!',
                    style: GoogleFonts.roboto(
                      fontSize: dynamicFontSize(context, 24), // Responsive font size
                      fontWeight: FontWeight.bold,
                      color: button_color,
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
                ],
              ),
            ),
            _buildDrawerItem(
              context, icon: Icons.book_online, label: 'Booking', labelColor: Colors.black, spaceBetweenIconAndLabel: 30.0,
              screen:  BookingScreen(),
            ),
            _buildDrawerItem(
                context, icon: Icons.star_rate_outlined, label: 'Rate Us', labelColor: Colors.black, spaceBetweenIconAndLabel: 30.0, screen: null,
                onTap: () => _launchGoogleReview('https://www.google.com/search?sca_esv=492959cb0fa9f70d&rlz=1C1ONGR_enIN1112IN1114&sxsrf=ADLYWILBFWiUUCU4jwzJh8D7cmZGLnDHsw:1730215045131&q=embassy+cargo+reviews&uds=ADvngMh0adhtivCWGeUhys0e_ZoihmAMR8OjUP5BIe15AcP_0DbTPJdBhC7w6a_9_GGmLQ3RynkfrhtROR4NEGEz5H2BllHMMBo6BogXy0ozCycpdUP9NIKGmhZC8xm1O-jisQpqV5NTj8_KwkPAHyIAe2QIE6L2B5SRoBM6eYLUzO8QDyCRDcm2X2vxudlLmx3bQEzFu2EJLSI1KX6x9-y0cqIpfyHZMSIUWDkpm_efUzxvFCDjWwpTZ156z3DLiLgUWiCzXr0bPr0znsCehfT0dh2sL-AU-T4gX6IXdO4MHHMgLsEI_Fng1rAd1OIj6zWwnnD8HzChM2ZHb-Qr38088yJdgqlf7kTawfzl4F2bP0teJ80Wn2EWO9m4S7cegm7kHPjcNcAvM32ycLTUkLUiOYlEWY6Ejk9HffDdCRnVuk8DskJVrfGKk1ZlZMG-OBVWMP0t4wfPEV1eoLuTeMDDty7b1IzDAQ&si=ACC90nwjPmqJHrCEt6ewASzksVFQDX8zco_7MgBaIawvaF4-7gnLo7ArKYAt37zb2vdj1kekZ-PVfIi3jagNC968hkEhbuFDJajGQoQdOxVl1T7b9muqFimm72g0spjEN0LQEXdgVqaN&sa=X&ved=2ahUKEwiroZmp8bOJAxXGS2cHHQdvJikQk8gLegQIJBAB&ictx=1#ebo=1')
            ),
            _buildDrawerItem(
              context, icon: Icons.info, label: 'About Us', labelColor: Colors.black, spaceBetweenIconAndLabel: 30.0,
              screen: const AboutScreen(),
            ),
            _buildDrawerItem(
              context, icon: Icons.contact_page, label: 'Contact Us', labelColor: Colors.black, spaceBetweenIconAndLabel: 30.0,
              screen: const ContactUsScreen(),
            ),
            _buildDrawerItem(
              context, icon: Icons.miscellaneous_services, label: 'All Services', labelColor: Colors.black, spaceBetweenIconAndLabel: 30.0,
              screen: const AllServiesScreen(),
            ),
            _buildDrawerItem(
              context, icon: Icons.contact_support, label: 'Customer Support', labelColor: Colors.black, spaceBetweenIconAndLabel: 30.0,
              onTap: _launchWhatsApp, // Launch WhatsApp when tapped
            ),
            _buildDrawerItem(
              context, icon: Icons.article, label: 'Terms & Conditions', labelColor: Colors.black, spaceBetweenIconAndLabel: 30.0,
              screen: const TermsAndConditions(),
            ),
            _buildDrawerItem(
              context, icon: Icons.business, label: 'Cargo Clearing Center', labelColor: Colors.black, spaceBetweenIconAndLabel: 30.0,
              screen: const CargoClearingCenterScreen(),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: dynamicPadding(context, 31.0),  // Responsive horizontal padding
                vertical: dynamicPadding(context, 8.0),    // Responsive vertical padding
              ),
              child: Text(
                'Embassy on social platforms',
                style: GoogleFonts.roboto(
                  fontSize: dynamicFontSize(context, 18),  // Responsive font size
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,  // Purple text color
                ),
              ),
            ),

            const SizedBox(width: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialMediaItem(
                  context, icon: FontAwesomeIcons.facebook,
                  url: 'https://www.facebook.com/Embassycargouae',
                  color: Colors.blue, size: 30.0,
                ),
                const SizedBox(width: 30),
                _buildSocialMediaItem(
                  context, icon: FontAwesomeIcons.instagram,
                  url: 'https://www.instagram.com/embassycargo?igsh=bzFqcXVqMTkxbGcy',
                  color: Colors.pink, size: 30.0,
                ),
                const SizedBox(width: 30),
                _buildSocialMediaItem(
                  context, icon: FontAwesomeIcons.tiktok,
                  url: 'https://www.tiktok.com/@embassycargo?_t=8qc6218Du30&_r=1',
                  color: Colors.black, size: 30.0,
                ),
              ],
            ),
          ],
        ),
      ),
      body: _hasInternet
          ? AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
      )
          : const NoInternetScreen(),


      bottomNavigationBar: Container(
        color: app_bar_color,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
      child: GNav(
          backgroundColor: app_bar_color,
          color: button_color,
          activeColor: Colors.white,
          tabBackgroundColor: Colors.grey.shade800.withOpacity(0.5),
          gap: 15,
          onTabChange: _onItemTapped,
          padding: EdgeInsets.all(12),
          tabs: const [
            GButton(
              icon: Icons.home,
              text: 'Home',
            ),
            GButton(
              icon: Icons.search,
              text: 'Track',
            ),
            GButton(
              icon: Icons.payment,
              text: 'Payment',
            )
          ]
      ),
      ),
      )
      ),
    );
  }
// Your modified _buildDrawerItem function
  Widget _buildDrawerItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        Widget? screen,
        Color labelColor = Colors.black,
        double spaceBetweenIconAndLabel = 20.0,
        VoidCallback? onTap,
      }) {
    return ListTile(
      onTap: () {
        // Close the drawer first
        Navigator.of(context).pop();
        // If onTap is provided, invoke it, otherwise navigate to the screen
        if (onTap != null) {
          onTap();
        } else if (screen != null) {
          _navigateWithAnimation(context, screen);
        }
      },
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.black),
              SizedBox(width: spaceBetweenIconAndLabel),
              Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: dynamicFontSize(context, 17), // Responsive font size
                  fontWeight: FontWeight.bold,
                  color: labelColor, // Navy blue text color
                ),
              ),
            ],
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 17),
        ],
      ),
    );
  }

// Implement your logout function
  Future<void> _logoutUser(BuildContext context) async {
    // Clear user session data
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userToken'); // Adjust the key based on your implementation

    // Redirect to login screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()), // Replace with your actual login screen
    );
  }


  Widget _buildSocialMediaItem(BuildContext context, {
    required IconData icon,
    required String url, Color? color,
    double? size,
  }) {
    return IconButton(
      icon: Icon(
        icon,
        color: color ?? Colors.white, // Default color if not provided
        size: size ?? 24.0,
      ),
      onPressed: () {
        _launchURL(url); // Function to launch the URL
      },
    );
  }
  void _launchGoogleReview(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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

// Method to dynamically adjust padding based on screen width
  double dynamicPadding(BuildContext context, double basePadding) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return basePadding * 0.8; // Smaller screens get slightly smaller padding
    } else if (screenWidth > 600) {
      return basePadding * 1.2; // Larger screens get slightly larger padding
    }
    return basePadding; // Default padding for medium screens
  }

}
void _launchWhatsApp() async {
  final phoneNumber = '+971505589785'; // Replace with your phone number
  final message = Uri.encodeComponent('Hello! I need assistance.');
  final url = 'https://wa.me/$phoneNumber?text=$message';

  // Check if the URL can be launched
  try {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  } catch (e) {
    print('Error launching WhatsApp: $e');
  }
}
  void _navigateWithAnimation(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    bool isLandscape = screenWidth > screenHeight;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Space before Special Offers section
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.024,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
            // child: Text(
            //   'Special Offers',
            //   style: GoogleFonts.roboto(
            //     fontSize: dynamicFontSize(context, 26),
            //     fontWeight: FontWeight.bold,
            //     color: primaryColor,
            //   ),
            // ),
            child: Text(
              'Special Offers',
              style: GoogleFonts.poppins( // Modern and clean font
                fontSize: dynamicFontSize(context, 26),
                fontWeight: FontWeight.w600, // Semi-bold for a sleek look
                color: primaryColor,
                letterSpacing: 1.2, // Adds slight spacing for a premium feel
              ),
            ),

          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),

          // OfferImagesScreen section
          Container(
            color: Colors.red,
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width,
            child: OfferImagesScreen(),
          ),

          SizedBox(height: MediaQuery.of(context).size.height * 0.02),

          //Dashboard section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
            child: Text(
              'Dashboard',
              style: GoogleFonts.poppins( // Modern and clean font
                fontSize: dynamicFontSize(context, 26),
                fontWeight: FontWeight.w600, // Semi-bold for a sleek look
                color: primaryColor,
                letterSpacing: 1.2, // Adds slight spacing for a premium feel
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.0),

          Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height * 0.75,
            width: MediaQuery.of(context).size.width,
            child: CargoBookingScreen(),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.0),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(
              color: Color(0xFF4A00E0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                // Header Text
                Text(
                  "Instant Cargo, Effortless Booking\nJust a Tap Away!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // Booking Button
                SizedBox(
                  width: screenWidth * 0.8,
                  height: screenHeight * 0.06,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      "Schedule My Cargo",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        ],
      ),
    );
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

  // --------new offers to upload----

class OfferImagesScreen extends StatefulWidget {
  @override
  _OfferImagesScreenState createState() => _OfferImagesScreenState();
}

class _OfferImagesScreenState extends State<OfferImagesScreen> {
  List<Image> offerImages = [];
  int currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    fetchOfferImages();
    startAutoScroll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Fetch and cache images
  Future<void> fetchOfferImages() async {
    try {
      final response = await http.get(Uri.parse("http://64.23.143.44:8000/offers/"));

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> offers = List<Map<String, dynamic>>.from(jsonDecode(response.body));

        // Fetch all images in parallel
        List<Future<Image>> imageFutures = offers.map((offer) async {
          final imgResponse = await http.get(Uri.parse("http://64.23.143.44:8000/offers/${offer['id']}"));
          if (imgResponse.statusCode == 200) {
            return Image.memory(imgResponse.bodyBytes, fit: BoxFit.cover);
          } else {
            return Image.asset("assets/placeholder.jpg", fit: BoxFit.cover); // Fallback image
          }
        }).toList();

        // Wait for all images to be fetched and store them
        List<Image> loadedImages = await Future.wait(imageFutures);

        setState(() {
          offerImages = loadedImages;
        });
      } else {
        print("Failed to load offers: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching offers: $e");
    }
  }

  // Auto-scroll logic
  void startAutoScroll() {
    Timer.periodic(Duration(seconds: 7), (timer) {
      if (_pageController.hasClients && offerImages.isNotEmpty) {
        currentIndex = (currentIndex + 1) % offerImages.length;
        _pageController.animateToPage(
          currentIndex,
          duration: Duration(milliseconds: 420),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: offerImages.isEmpty
          ? Center(
        child: CircularProgressIndicator(
          color: primaryColor, // Custom indicator color
        ),
      )
          : Column(
        children: [
          // Carousel with indicators
          Expanded(
            flex: 8,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
                vertical: MediaQuery.of(context).size.height * 0.02,
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: offerImages.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: offerImages[index],
                      );
                    },
                  ),
                  // Indicator for carousel
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.03,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        offerImages.length,
                            (index) => Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          width: currentIndex == index ? 12 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: currentIndex == index
                                ? primaryColor
                                : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



  // -----------image --offers--Working Fine------
//
//   class OfferImagesScreen extends StatefulWidget {
//   @override
//   _OfferImagesScreenState createState() => _OfferImagesScreenState();
// }
//
// class _OfferImagesScreenState extends State<OfferImagesScreen> {
//   List<Map<String, dynamic>> offers = [];
//   int currentIndex = 0;
//   final PageController _pageController = PageController();
//
//   @override
//   void initState() {
//     super.initState();
//     fetchOfferImages();
//     startAutoScroll();
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   // Fetch list of offers
//   Future<void> fetchOfferImages() async {
//     try {
//       //final response = await http.get(Uri.parse("http://192.168.137.1:8000/offers/"));
//       final response = await http.get(Uri.parse("http://64.23.143.44:8000/offers/"));
//       if (response.statusCode == 200) {
//         setState(() {
//           offers = List<Map<String, dynamic>>.from(jsonDecode(response.body));
//         });
//       } else {
//         print("Failed to load offers: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error fetching offers: $e");
//     }
//   }
//
//   // Fetch specific offer image
//   Future<Image> fetchOfferImage(String imageId) async {
//     //final url = Uri.parse("http://192.168.137.1:8000/offers/$imageId");
//     final url = Uri.parse("http://64.23.143.44:8000/offers/$imageId");
//     final response = await http.get(url);
//
//     if (response.statusCode == 200) {
//       return Image.memory(
//         response.bodyBytes,
//         fit: BoxFit.cover,
//       );
//     } else {
//       throw Exception("Failed to load image");
//     }
//   }
//
//   // Auto-scroll logic
//   void startAutoScroll() {
//     Timer.periodic(Duration(seconds: 7), (timer) {
//       if (_pageController.hasClients && offers.isNotEmpty) {
//         currentIndex = (currentIndex + 1) % offers.length;
//         _pageController.animateToPage(
//           currentIndex,
//           duration: Duration(milliseconds: 420),
//           curve: Curves.easeInOut,
//         );
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Scaffold(
//       backgroundColor: background_color,
//       body: offers.isEmpty
//           ? Center(
//         child: CircularProgressIndicator(
//           color: app_bar_color, // Custom indicator color
//         ),
//       )
//           : Column(
//         children: [
//           // Carousel with indicators
//           Expanded(
//             flex: 8,
//             child: Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: MediaQuery.of(context).size.width * 0.03, // 5% of screen width
//                 vertical: MediaQuery.of(context).size.height * 0.02, // 2% of screen height
//               ),
//               child: Stack(
//                 alignment: Alignment.bottomCenter,
//                 children: [
//                   PageView.builder(
//                     controller: _pageController,
//                     itemCount: offers.length,
//                     onPageChanged: (index) {
//                       setState(() {
//                         currentIndex = index;
//                       });
//                     },
//                     itemBuilder: (context, index) {
//                       final offer = offers[index];
//                       return FutureBuilder<Image>(
//                         future: fetchOfferImage(offer['id'].toString()),
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState == ConnectionState.waiting) {
//                             return Center(
//                               child: CircularProgressIndicator(
//                                 color: app_bar_color,
//                               ),
//                             );
//                           } else if (snapshot.hasError) {
//                             return Center(child: Icon(Icons.error));
//                           } else {
//                             return ClipRRect(
//                               borderRadius: BorderRadius.circular(10),
//                               child: snapshot.data!,
//                             );
//                           }
//                         },
//                       );
//                     },
//                   ),
//                   // Indicator for carousel
//                   Positioned(
//                     bottom: MediaQuery.of(context).size.height * 0.03, // 3% of screen height
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: List.generate(
//                         offers.length,
//                             (index) => Container(
//                           margin: EdgeInsets.symmetric(horizontal: 4),
//                           width: currentIndex == index ? 12 : 8,
//                           height: 8,
//                           decoration: BoxDecoration(
//                             color: currentIndex == index
//                                 ? Colors.red
//                                 : Colors.grey,
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       ),
//     );
//   }
// }



//
// class CargoBookingScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           // Purple Header Section
//           Container(
//             margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
//             decoration: BoxDecoration(
//               color: Color(0xFF4A00E0),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Column(
//               children: [
//                 // Header Text
//                 Text(
//                   "Instant Cargo, Effortless Booking\nJust a Tap Away!",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: MediaQuery.of(context).size.width * 0.05,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: 15),
//
//                 // Booking Button
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.8,
//                   height: 50,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // Navigate to general booking page
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => BookingScreen(),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: Colors.black,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 5,
//                     ),
//                     child: Text("Instant Cargo Booking",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: MediaQuery.of(context).size.width * 0.05,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: MediaQuery.of(context).size.height * 0.01),
//           // Cargo Service Grid (Non-scrollable)
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               child: GridView.builder(
//                 physics: NeverScrollableScrollPhysics(), // Prevent scrolling
//                 shrinkWrap: true, // Ensures the grid takes necessary space
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 15,
//                   mainAxisSpacing: 15,
//                   childAspectRatio: 0.9, // Adjusted aspect ratio for height
//                 ),
//                 itemCount: cargoOptions.length,
//                 itemBuilder: (context, index) {
//                   return CargoCard(option: cargoOptions[index]);
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Cargo Option Model
// class CargoOption {
//   final String title;
//   final String image;
//   // final VoidCallback onTap;
//   final Function(BuildContext) onTap;
//
//   CargoOption({required this.title, required this.image, required this.onTap});
// }
//
//
// List<CargoOption> cargoOptions = [
//   CargoOption(
//     title: "Air Cargo \nDoor To Door",
//     image: "assets/images/aircargo11.png",
//     onTap: (BuildContext context) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => AirCargoScreen()),
//       );
//     },
//   ),
//   CargoOption(
//     title: "Sea Cargo \nDoor To Door",
//     image: "assets/images/seacargo11.png",
//     onTap: (BuildContext context) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => SeaCargoScreen()),
//       );
//     },
//   ),
//   CargoOption(
//     title: "Air Cargo \nWarehouse",
//     image: "assets/images/aircargowarehouse.png",
//     onTap: (BuildContext context) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => AirCargoWarehouse()),
//       );
//     },
//   ),
//   CargoOption(
//     title: "Sea Cargo \nWarehouse",
//     image: "assets/images/seawarehouse1.png",
//     onTap: (BuildContext context) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => HomeCargoScreen()),
//       );
//     },
//   ),
// ];
//
//
// // Cargo Card Widget
// class CargoCard extends StatelessWidget {
//   final CargoOption option;
//
//   const CargoCard({Key? key, required this.option}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => option.onTap(context), // Fix: Pass context correctly
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         elevation: 5,
//         child: Container(
//           height: 320,
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               // Background Image
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.asset(
//                   option.image,
//                   fit: BoxFit.cover,
//                   width: double.infinity,
//                   height: double.infinity,
//                 ),
//               ),
//               // Dark Gradient Overlay
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   gradient: LinearGradient(
//                     colors: [Colors.black.withOpacity(0.6), Colors.transparent],
//                     begin: Alignment.bottomCenter,
//                     end: Alignment.topCenter,
//                   ),
//                 ),
//               ),
//               // Title & Button
//               Positioned(
//                 bottom: 10,
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 8),
//                       child: Text(
//                         option.title,
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 5),
//                     // Book Now Button with Separate Action
//                     SizedBox(
//                       width: 120,
//                       height: 35, // Increased button size
//                       child: ElevatedButton(
//                         onPressed: () => option.onTap(context), // Fix: Pass context correctly
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.white,
//                           foregroundColor: Colors.black,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                               side: BorderSide(color: Colors.black, width: 1),
//                           ),
//                         ),
//                         child: Text("Book Now",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 15,
//                           ),),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class CargoBookingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView( // Added scroll to support content overflow
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              // Header Section (Purple)
              Container(
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  color: Color(0xFF4A00E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      "Instant Cargo, Effortless Booking\nJust a Tap Away!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    SizedBox(
                      width: screenWidth * 0.8,
                      height: screenHeight * 0.06,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => BookingScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          "Instant Cargo Booking",
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.01),

              // Cargo Service Grid (Non-scrollable)
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.9,
                ),
                itemCount: cargoOptions.length,
                itemBuilder: (context, index) {
                  return CargoCard(option: cargoOptions[index]);
                },
              ),

              // SizedBox(height: screenHeight * 0.01),
              // Container(
              //   padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              //   decoration: BoxDecoration(
              //     color: Color(0xFF4A00E0),
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   child: Column(
              //     children: [
              //       Text(
              //         "Instant Cargo, Effortless Booking\nJust a Tap Away!",
              //         textAlign: TextAlign.center,
              //         style: TextStyle(
              //           fontSize: screenWidth * 0.05,
              //           fontWeight: FontWeight.bold,
              //           color: Colors.white,
              //         ),
              //       ),
              //       SizedBox(height: screenHeight * 0.02),
              //       SizedBox(
              //         width: screenWidth * 0.8,
              //         height: screenHeight * 0.06,
              //         child: ElevatedButton(
              //           onPressed: () {
              //             Navigator.push(
              //               context,
              //               MaterialPageRoute(builder: (context) => BookingScreen()),
              //             );
              //           },
              //           style: ElevatedButton.styleFrom(
              //             backgroundColor: Colors.white,
              //             foregroundColor: Colors.black,
              //             shape: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.circular(12),
              //             ),
              //             elevation: 5,
              //           ),
              //           child: Text(
              //             "Schedule My Cargo",
              //             style: TextStyle(
              //               fontSize: screenWidth * 0.045,
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              SizedBox(height: screenHeight * 0.01),
            ],
          ),
        ),
      ),
    );
  }
}

class CargoOption {
  final String title;
  final String image;
  final Function(BuildContext) onTap;

  CargoOption({required this.title, required this.image, required this.onTap});
}

List<CargoOption> cargoOptions = [
  CargoOption(
    title: "Air Cargo \nDoor To Door",
    image: "assets/images/aircargo11.png",
    onTap: (BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AirCargoScreen()),
      );
    },
  ),
  CargoOption(
    title: "Sea Cargo \nDoor To Door",
    image: "assets/images/seacargo11.png",
    onTap: (BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SeaCargoScreen()),
      );
    },
  ),
  CargoOption(
    title: "Air Cargo \nWarehouse",
    image: "assets/images/aircargowarehouse.png",
    onTap: (BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AirCargoScreen()),
      );
    },
  ),
  CargoOption(
    title: "Sea Cargo \nWarehouse",
    image: "assets/images/seawarehouse1.png",
    onTap: (BuildContext context) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SeaCargoScreen()),
      );
    },
  ),
];

class CargoCard extends StatelessWidget {
  final CargoOption option;

  const CargoCard({Key? key, required this.option}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => option.onTap(context),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
        child: Container(
          height: screenWidth * 0.45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  option.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        option.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    SizedBox(
                      width: screenWidth * 0.3,
                      height: 35,
                      child: ElevatedButton(
                        onPressed: () => option.onTap(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                        child: Text(
                          "Book Now",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.035,
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
    );
  }
}






///WORKING CODE


// import 'dart:async';
// import 'dart:convert';
// import 'package:embassycargo/screens/about_screen.dart';
// import 'package:embassycargo/screens/all_servies_screen.dart';
// import 'package:embassycargo/screens/sea_cargo_screen.dart';
// import 'package:embassycargo/screens/terms_and_conditions.dart';
// import 'package:flutter/material.dart';
// import 'package:embassycargo/screens/contact_us_screen.dart';
// import 'package:embassycargo/screens/tracking_screen.dart';
// import 'package:embassycargo/screens/bill_screen.dart';
// import 'package:embassycargo/screens/booking_screen.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:google_nav_bar/google_nav_bar.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../services/connectivity_service.dart';
// import '../utils/colors.dart';
// import 'air_cargo_screen.dart';
// import 'air_cargo_warehouse.dart';
// import 'cargo_clearing_center_screen.dart';
// import 'home-cargo_screen.dart';
// import 'login_screen.dart';
// import 'no_internet_screen.dart';
// import 'package:http/http.dart' as http;
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//   static const String routeName = '/home';
//
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   final ConnectivityService _connectivityService = ConnectivityService();
//   late StreamSubscription<bool> _subscription;
//   bool _hasInternet = true;
//   int _selectedIndex = 0;
//   DateTime timeBackPressed = DateTime.now();
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Check initial connectivity status
//     _connectivityService.checkConnectivity().then((hasConnection) {
//       setState(() {
//         _hasInternet = hasConnection;
//       });
//       if (!_hasInternet) {
//         _showNoInternetScreen();
//       }
//     });
//
//     // Listen to connection status changes
//     _subscription = _connectivityService.connectionStatusStream.listen((hasConnection) {
//       setState(() {
//         _hasInternet = hasConnection;
//       });
//
//       if (!_hasInternet) {
//         _showNoInternetScreen();
//       } else {
//         _returnToHomeScreen();
//       }
//     });
//   }
//
//   void _showNoInternetScreen() {
//     if (!_hasInternet) {
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (context) => const NoInternetScreen()),
//             (route) => false,
//       );
//     }
//   }
//
//   void _returnToHomeScreen() {
//     if (Navigator.canPop(context)) {
//       Navigator.popUntil(context, (route) => route.isFirst);
//     }
//   }
//
//   @override
//   void dispose() {
//     _subscription.cancel();
//     _connectivityService.dispose();
//     super.dispose();
//   }
//
//   final List<String> _titles = [
//     'EMBASSY CARGO',
//     'Tracking',
//     'Online Payment',
//   ];
//
//   // List of screens for navigation
//   final List<Widget> _screens = [
//     const HomeScreenContent(),
//     const TrackingScreen(),
//     //const NotificationScreen(),
//     OnlinePaymentScreen(),
//   ];
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
// //  title: Text(_titles[_selectedIndex]),
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         final difference = DateTime.now().difference(timeBackPressed);
//         final isExitWarning = difference >= Duration(seconds: 2);
//         timeBackPressed = DateTime.now();
//         if(isExitWarning){
//           final message = 'Press back again to exit';
//           Fluttertoast.showToast(msg: message,fontSize: 18);
//           return false;
//         }else{
//           Fluttertoast.cancel();
//           return true;
//         }
//       },
//       child:  Scaffold(
//       backgroundColor: background_color,
//       //backgroundColor: Colors.yellow,
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(60.0),  // You can adjust the height if needed
//         child: ClipRRect(
//           borderRadius: const BorderRadius.vertical(
//             bottom: Radius.circular(20),  // Adjust to your desired roundness
//           ),
//           child: AppBar(
//             // Add a gradient background to the AppBar
//             flexibleSpace: Container(
//               decoration: const BoxDecoration(
//                 color: app_bar_color,
//                // color: Colors.blue,
//               ),
//             ),
//             elevation: 4, // Add slight elevation for shadow effect
//             centerTitle: true,
//             automaticallyImplyLeading: false,
//             title: Text(_titles[_selectedIndex],
//               style: GoogleFonts.roboto(
//                 fontSize: dynamicFontSize(context, 22), // Responsive font size
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//                 letterSpacing: 1.2,  // Slight spacing for better readability
//                 shadows: [
//                   Shadow(
//                     offset: Offset(1, 1),
//                     color: Colors.black26,
//                     blurRadius: 3,  // Adds a subtle shadow to the title
//                   ),
//                 ],
//               ),
//             ),
//             leading: Builder(
//               builder: (context) {
//                 return IconButton(
//                   icon: const Icon(Icons.menu, color: Colors.white),
//                   iconSize: 28, // Set the desired icon size here
//                   onPressed: () {
//                     Scaffold.of(context).openDrawer();
//                   },
//                 );
//               },
//             ),
//
//           ),
//         ),
//       ),
//       drawer: Drawer(
//
//        // backgroundColor: lightWhite,
//         backgroundColor: background_color,
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: const BoxDecoration(
//                 color: app_bar_color,
//                 //color: Colors.blue,
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Flexible(
//                     child: SizedBox(
//                       width: 300,
//                       height: 300,
//                       child: Image.asset(
//                         'assets/images/logo.png',
//                         fit: BoxFit.contain,
//                       ),
//                     ),
//                   ),
//                    Text(
//                     'Welcome!',
//                     style: GoogleFonts.roboto(
//                       fontSize: dynamicFontSize(context, 24), // Responsive font size
//                       fontWeight: FontWeight.bold,
//                       color: button_color,
//                       letterSpacing: 1.2,  // Slight spacing for better readability
//                       shadows: [
//                         Shadow(
//                           offset: Offset(1, 1),
//                           color: Colors.black26,
//                           blurRadius: 3,  // Adds a subtle shadow to the title
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             _buildDrawerItem(
//               context, icon: Icons.book_online, label: 'Booking', labelColor: Colors.black, spaceBetweenIconAndLabel: 30.0,
//               screen:  BookingScreen(),
//             ),
//             _buildDrawerItem(
//                 context, icon: Icons.star_rate_outlined, label: 'Rate Us', labelColor: Colors.black, spaceBetweenIconAndLabel: 30.0, screen: null,
//                 onTap: () => _launchGoogleReview('https://www.google.com/search?sca_esv=492959cb0fa9f70d&rlz=1C1ONGR_enIN1112IN1114&sxsrf=ADLYWILBFWiUUCU4jwzJh8D7cmZGLnDHsw:1730215045131&q=embassy+cargo+reviews&uds=ADvngMh0adhtivCWGeUhys0e_ZoihmAMR8OjUP5BIe15AcP_0DbTPJdBhC7w6a_9_GGmLQ3RynkfrhtROR4NEGEz5H2BllHMMBo6BogXy0ozCycpdUP9NIKGmhZC8xm1O-jisQpqV5NTj8_KwkPAHyIAe2QIE6L2B5SRoBM6eYLUzO8QDyCRDcm2X2vxudlLmx3bQEzFu2EJLSI1KX6x9-y0cqIpfyHZMSIUWDkpm_efUzxvFCDjWwpTZ156z3DLiLgUWiCzXr0bPr0znsCehfT0dh2sL-AU-T4gX6IXdO4MHHMgLsEI_Fng1rAd1OIj6zWwnnD8HzChM2ZHb-Qr38088yJdgqlf7kTawfzl4F2bP0teJ80Wn2EWO9m4S7cegm7kHPjcNcAvM32ycLTUkLUiOYlEWY6Ejk9HffDdCRnVuk8DskJVrfGKk1ZlZMG-OBVWMP0t4wfPEV1eoLuTeMDDty7b1IzDAQ&si=ACC90nwjPmqJHrCEt6ewASzksVFQDX8zco_7MgBaIawvaF4-7gnLo7ArKYAt37zb2vdj1kekZ-PVfIi3jagNC968hkEhbuFDJajGQoQdOxVl1T7b9muqFimm72g0spjEN0LQEXdgVqaN&sa=X&ved=2ahUKEwiroZmp8bOJAxXGS2cHHQdvJikQk8gLegQIJBAB&ictx=1#ebo=1')
//             ),
//             _buildDrawerItem(
//               context, icon: Icons.info, label: 'About Us', labelColor: Colors.black, spaceBetweenIconAndLabel: 30.0,
//               screen: const AboutScreen(),
//             ),
//             _buildDrawerItem(
//               context, icon: Icons.contact_page, label: 'Contact Us', labelColor: Colors.black, spaceBetweenIconAndLabel: 30.0,
//               screen: const ContactUsScreen(),
//             ),
//             _buildDrawerItem(
//               context, icon: Icons.miscellaneous_services, label: 'All Services', labelColor: Colors.black, spaceBetweenIconAndLabel: 30.0,
//               screen: const AllServiesScreen(),
//             ),
//             _buildDrawerItem(
//               context, icon: Icons.contact_support, label: 'Customer Support', labelColor: Colors.black, spaceBetweenIconAndLabel: 30.0,
//               onTap: _launchWhatsApp, // Launch WhatsApp when tapped
//             ),
//             _buildDrawerItem(
//               context, icon: Icons.article, label: 'Terms & Conditions', labelColor: Colors.black, spaceBetweenIconAndLabel: 30.0,
//               screen: const TermsAndConditions(),
//             ),
//             _buildDrawerItem(
//               context, icon: Icons.business, label: 'Cargo Clearing Center', labelColor: Colors.black, spaceBetweenIconAndLabel: 30.0,
//               screen: const CargoClearingCenterScreen(),
//             ),
//             const SizedBox(height: 15),
//             Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: dynamicPadding(context, 31.0),  // Responsive horizontal padding
//                 vertical: dynamicPadding(context, 8.0),    // Responsive vertical padding
//               ),
//               child: Text(
//                 'Embassy on social platforms',
//                 style: GoogleFonts.roboto(
//                   fontSize: dynamicFontSize(context, 18),  // Responsive font size
//                   fontWeight: FontWeight.bold,
//                   color: Colors.purple,  // Purple text color
//                 ),
//               ),
//             ),
//
//             const SizedBox(width: 30),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 _buildSocialMediaItem(
//                   context, icon: FontAwesomeIcons.facebook,
//                   url: 'https://www.facebook.com/Embassycargouae',
//                   color: Colors.blue, size: 30.0,
//                 ),
//                 const SizedBox(width: 30),
//                 _buildSocialMediaItem(
//                   context, icon: FontAwesomeIcons.instagram,
//                   url: 'https://www.instagram.com/embassycargo?igsh=bzFqcXVqMTkxbGcy',
//                   color: Colors.pink, size: 30.0,
//                 ),
//                 const SizedBox(width: 30),
//                 _buildSocialMediaItem(
//                   context, icon: FontAwesomeIcons.tiktok,
//                   url: 'https://www.tiktok.com/@embassycargo?_t=8qc6218Du30&_r=1',
//                   color: Colors.black, size: 30.0,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       body: _hasInternet
//           ? AnimatedSwitcher(
//         duration: const Duration(milliseconds: 500),
//         child: IndexedStack(
//           index: _selectedIndex,
//           children: _screens,
//         ),
//       )
//           : const NoInternetScreen(),
//
//
//       bottomNavigationBar: Container(
//         color: app_bar_color,
//       child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
//       child: GNav(
//           backgroundColor: app_bar_color,
//           color: button_color,
//           activeColor: Colors.white,
//           tabBackgroundColor: Colors.grey.shade800.withOpacity(0.5),
//           gap: 15,
//           onTabChange: _onItemTapped,
//           padding: EdgeInsets.all(12),
//           tabs: const [
//             GButton(
//               icon: Icons.home,
//               text: 'Home',
//             ),
//             GButton(
//               icon: Icons.search,
//               text: 'Track',
//             ),
//             GButton(
//               icon: Icons.payment,
//               text: 'Payment',
//             )
//           ]
//       ),
//       ),
//       )
//       ),
//     );
//   }
// // Your modified _buildDrawerItem function
//   Widget _buildDrawerItem(
//       BuildContext context, {
//         required IconData icon,
//         required String label,
//         Widget? screen,
//         Color labelColor = Colors.black,
//         double spaceBetweenIconAndLabel = 20.0,
//         VoidCallback? onTap,
//       }) {
//     return ListTile(
//       onTap: () {
//         // Close the drawer first
//         Navigator.of(context).pop();
//         // If onTap is provided, invoke it, otherwise navigate to the screen
//         if (onTap != null) {
//           onTap();
//         } else if (screen != null) {
//           _navigateWithAnimation(context, screen);
//         }
//       },
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Icon(icon, color: Colors.black),
//               SizedBox(width: spaceBetweenIconAndLabel),
//               Text(
//                 label,
//                 style: GoogleFonts.roboto(
//                   fontSize: dynamicFontSize(context, 17), // Responsive font size
//                   fontWeight: FontWeight.bold,
//                   color: labelColor, // Navy blue text color
//                 ),
//               ),
//             ],
//           ),
//           const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 17),
//         ],
//       ),
//     );
//   }
//
// // Implement your logout function
//   Future<void> _logoutUser(BuildContext context) async {
//     // Clear user session data
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('userToken'); // Adjust the key based on your implementation
//
//     // Redirect to login screen
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(builder: (context) => LoginScreen()), // Replace with your actual login screen
//     );
//   }
//
//
//   Widget _buildSocialMediaItem(BuildContext context, {
//     required IconData icon,
//     required String url, Color? color,
//     double? size,
//   }) {
//     return IconButton(
//       icon: Icon(
//         icon,
//         color: color ?? Colors.white, // Default color if not provided
//         size: size ?? 24.0,
//       ),
//       onPressed: () {
//         _launchURL(url); // Function to launch the URL
//       },
//     );
//   }
//   void _launchGoogleReview(String url) async {
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }
//
//   void _launchURL(String url) async {
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }
//
//   // Dynamic font size adjustment based on screen width
//   double dynamicFontSize(BuildContext context, double baseSize) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     if (screenWidth < 360) {
//       return baseSize * 0.85; // Smaller screens get slightly smaller font sizes
//     } else if (screenWidth > 600) {
//       return baseSize * 1.2; // Larger screens get slightly larger font sizes
//     }
//     return baseSize; // Default size for medium screens
//   }
//
// // Method to dynamically adjust padding based on screen width
//   double dynamicPadding(BuildContext context, double basePadding) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     if (screenWidth < 360) {
//       return basePadding * 0.8; // Smaller screens get slightly smaller padding
//     } else if (screenWidth > 600) {
//       return basePadding * 1.2; // Larger screens get slightly larger padding
//     }
//     return basePadding; // Default padding for medium screens
//   }
//
// }
// void _launchWhatsApp() async {
//   final phoneNumber = '+971505589785'; // Replace with your phone number
//   final message = Uri.encodeComponent('Hello! I need assistance.');
//   final url = 'https://wa.me/$phoneNumber?text=$message';
//
//   // Check if the URL can be launched
//   try {
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       throw 'Could not launch $url';
//     }
//   } catch (e) {
//     print('Error launching WhatsApp: $e');
//   }
// }
//   void _navigateWithAnimation(BuildContext context, Widget screen) {
//     Navigator.push(
//       context,
//       PageRouteBuilder(
//         pageBuilder: (context, animation, secondaryAnimation) => screen,
//         transitionsBuilder: (context, animation, secondaryAnimation, child) {
//           const begin = Offset(1.0, 0.0);
//           const end = Offset.zero;
//           const curve = Curves.easeInOut;
//
//           var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//
//           return SlideTransition(
//             position: animation.drive(tween),
//             child: child,
//           );
//         },
//       ),
//     );
//   }
//
// class HomeScreenContent extends StatelessWidget {
//   const HomeScreenContent({super.key});
//
//
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery
//         .of(context)
//         .size
//         .width;
//     double screenHeight = MediaQuery
//         .of(context)
//         .size
//         .height;
//     bool isLandscape = screenWidth > screenHeight;
//
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Space before Special Offers section
//           SizedBox(
//             height: MediaQuery.of(context).size.height * 0.024,
//           ),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
//             child: Text(
//               'Special Offers',
//               style: GoogleFonts.roboto(
//                 fontSize: dynamicFontSize(context, 26),
//                 fontWeight: FontWeight.bold,
//                 color: primaryColor,
//               ),
//             ),
//           ),
//           SizedBox(height: MediaQuery.of(context).size.height * 0.02),
//
//           // OfferImagesScreen section
//           Container(
//             color: Colors.red,
//             height: MediaQuery.of(context).size.height * 0.6,
//             width: MediaQuery.of(context).size.width,
//             child: OfferImagesScreen(),
//           ),
//
//           SizedBox(height: MediaQuery.of(context).size.height * 0.02),
//
//           // Dashboard section
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
//             child: Text(
//               'Dashboard',
//               style: GoogleFonts.roboto(
//                 fontSize: dynamicFontSize(context, 26),
//                 fontWeight: FontWeight.bold,
//                 // color: Colors.purple,
//                 color: primaryColor,
//               ),
//             ),
//           ),
//           SizedBox(height: MediaQuery.of(context).size.height * 0.0),
//
//           // GridView for Dashboard
//           GridView.count(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             crossAxisCount: 3,
//             crossAxisSpacing: 4,
//             mainAxisSpacing: 4,
//             children: [
//               _buildDashboardItem(context, icon: Icons.book_online, label: 'Booking', screen:  BookingScreen()),
//               // _buildDashboardItem(context, icon: Icons.miscellaneous_services, label: 'All Services', screen: const AllServiesScreen()),
//               _buildDashboardItem(context, icon: Icons.airplanemode_active, label: 'Aircargo', screen: const AirCargoScreen()),
//               _buildDashboardItem(context, icon: Icons.directions_boat, label: 'Seacargo', screen: const SeaCargoScreen()),
//             ],
//           ),
//
//           SizedBox(height: MediaQuery.of(context).size.height * 0.0),
//
//           // // Label row section with three different labels
//           // Row(
//           //   mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Evenly space the labels
//           //   children: [
//           //     // First Label: Booking
//           //     Flexible(
//           //       child: Container(
//           //         padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
//           //         decoration: BoxDecoration(
//           //           color: button_color,
//           //           borderRadius: BorderRadius.circular(30),
//           //           boxShadow: [
//           //             BoxShadow(
//           //               color: Colors.black.withOpacity(0.3),
//           //               blurRadius: 8,
//           //               offset: const Offset(2, 4),
//           //             ),
//           //           ],
//           //         ),
//           //         child: Text(
//           //           ' Booking ', // First label name
//           //           textAlign: TextAlign.center,
//           //           style: GoogleFonts.roboto(
//           //             fontSize: 12,
//           //             fontWeight: FontWeight.w600,
//           //             color: Colors.black,
//           //           ),
//           //         ),
//           //       ),
//           //     ),
//           //
//           //     // Spacer for Flexible Spacing
//           //     SizedBox(width: MediaQuery.of(context).size.width * 0.03), // 3% screen width gap
//           //
//           //     // Second Label: All Services
//           //     Flexible(
//           //       child: Container(
//           //         padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
//           //         decoration: BoxDecoration(
//           //           color: button_color,
//           //           borderRadius: BorderRadius.circular(30),
//           //           boxShadow: [
//           //             BoxShadow(
//           //               color: Colors.black.withOpacity(0.3),
//           //               blurRadius: 8,
//           //               offset: const Offset(2, 4),
//           //             ),
//           //           ],
//           //         ),
//           //         child: Text(
//           //           ' Air Cargo ', // Second label name
//           //           textAlign: TextAlign.center,
//           //           style: GoogleFonts.roboto(
//           //             fontSize: 12,
//           //             fontWeight: FontWeight.w600,
//           //             color: Colors.black,
//           //           ),
//           //         ),
//           //       ),
//           //     ),
//           //
//           //     // Spacer for Flexible Spacing
//           //     SizedBox(width: MediaQuery.of(context).size.width * 0.03), // 3% screen width gap
//           //
//           //     // Third Label: About Us
//           //     Flexible(
//           //       child: Container(
//           //         padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
//           //         decoration: BoxDecoration(
//           //           color: button_color,
//           //           borderRadius: BorderRadius.circular(30),
//           //           boxShadow: [
//           //             BoxShadow(
//           //               color: Colors.black.withOpacity(0.3),
//           //               blurRadius: 8,
//           //               offset: const Offset(2, 4),
//           //             ),
//           //           ],
//           //         ),
//           //         child: Text(
//           //           'Sea Cargo', // Third label name
//           //           textAlign: TextAlign.center,
//           //           style: GoogleFonts.roboto(
//           //             fontSize: 12,
//           //             fontWeight: FontWeight.w600,
//           //             color: Colors.black,
//           //           ),
//           //         ),
//           //       ),
//           //     ),
//           //   ],
//           // ),
//
//
//           SizedBox(height: MediaQuery.of(context).size.height * 0.02),
//           // Service section
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04),
//             child: Text(
//               'Service',
//               style: GoogleFonts.roboto(
//                 fontSize: dynamicFontSize(context, 26),
//                 fontWeight: FontWeight.bold,
//                 color: primaryColor,
//               ),
//             ),
//           ),
//           SizedBox(height: MediaQuery.of(context).size.height * 0.0),
//           // GridView for Service
//           GridView.count(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             crossAxisCount: 3,
//             crossAxisSpacing: 4,
//             mainAxisSpacing: 4,
//             children: [
//               _buildDashboardItem(context, icon: Icons.flight_takeoff, label: 'Air Warehouse', screen:  CargoBookingScreen()),
//               _buildDashboardItem(context, icon: Icons.sailing, label: 'Sea Warehouse', screen: const HomeCargoScreen()),
//               _buildDashboardItem(context, icon: Icons.miscellaneous_services, label: 'All Services', screen: const AllServiesScreen()),
//               // _buildDashboardItem(context, icon: Icons.door_sliding_sharp, label: 'DoorToDoor', screen: const HomeCargoScreen()),
//
//             ],
//           ),
//
//
//
//           Container(
//             color: Colors.red,
//             height: MediaQuery.of(context).size.height * 0.6,
//             width: MediaQuery.of(context).size.width,
//             child: CargoBookingScreen(),
//           ),
//
//
//
//
//           // Container(
//           //   width: double.infinity,
//           //   padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
//           //   decoration: BoxDecoration(
//           //     color: Color(0xFF4A00E0), // Purple background
//           //     borderRadius: BorderRadius.only(
//           //       topLeft: Radius.circular(25),
//           //       topRight: Radius.circular(25),
//           //       bottomLeft: Radius.circular(25),
//           //       bottomRight: Radius.circular(25),
//           //     ),
//           //   ),
//           //   child: Column(
//           //     children: [
//           //       // Header Text
//           //       Text(
//           //         "Instant Cargo, Effortless Booking\nJust a Tap Away!",
//           //         textAlign: TextAlign.center,
//           //         style: TextStyle(
//           //           fontSize: screenWidth * 0.05,
//           //           fontWeight: FontWeight.bold,
//           //           color: Colors.white,
//           //         ),
//           //       ),
//           //       SizedBox(height: 15),
//           //       // Booking Button
//           //       SizedBox(
//           //         width: screenWidth * 0.8,
//           //         height: 50,
//           //         child: ElevatedButton(
//           //           onPressed: () {},
//           //           style: ElevatedButton.styleFrom(
//           //             backgroundColor: Colors.white,
//           //             foregroundColor: Colors.black,
//           //             shape: RoundedRectangleBorder(
//           //               borderRadius: BorderRadius.circular(12),
//           //             ),
//           //           ),
//           //           child: Text("Instant Cargo Booking"),
//           //         ),
//           //       ),
//           //     ],
//           //   ),
//           // ),
//           // SizedBox(height: 20),
//           //
//           //
//           // Expanded(
//           //   child: Padding(
//           //     padding: EdgeInsets.symmetric(horizontal: 16),
//           //     child: GridView.builder(
//           //       physics: BouncingScrollPhysics(),
//           //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           //         crossAxisCount: 2, // Always 2 per row
//           //         crossAxisSpacing: 15,
//           //         mainAxisSpacing: 15,
//           //         childAspectRatio: 1.2, // Ensures proper card size
//           //       ),
//           //       itemCount: cargoOptions.length,
//           //       itemBuilder: (context, index) {
//           //         return CargoCard(option: cargoOptions[index]);
//           //       },
//           //     ),
//           //   ),
//           // ),
//           SizedBox(height: 20),
//
//           // SizedBox(height: MediaQuery.of(context).size.height * 0.1),
//
//           // Label row section with three different labels
//           // Row(
//           //   mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Evenly space the labels
//           //   children: [
//           //     // First Label: Booking
//           //     Flexible(
//           //       child: Container(
//           //         padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
//           //         decoration: BoxDecoration(
//           //           color: button_color,
//           //           borderRadius: BorderRadius.circular(30),
//           //           boxShadow: [
//           //             BoxShadow(
//           //               color: Colors.black.withOpacity(0.3),
//           //               blurRadius: 8,
//           //               offset: const Offset(2, 4),
//           //             ),
//           //           ],
//           //         ),
//           //         child: Text(
//           //           'Air Warehouse', // First label name
//           //           textAlign: TextAlign.center,
//           //           style: GoogleFonts.roboto(
//           //             fontSize: 12,
//           //             fontWeight: FontWeight.w600,
//           //             color: Colors.black,
//           //           ),
//           //         ),
//           //       ),
//           //     ),
//           //
//           //     // Spacer for Flexible Spacing
//           //     SizedBox(width: MediaQuery.of(context).size.width * 0.0), // 3% screen width gap
//           //
//           //     // Second Label: All Services
//           //     Flexible(
//           //       child: Container(
//           //         padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
//           //         decoration: BoxDecoration(
//           //           color:button_color,
//           //           borderRadius: BorderRadius.circular(30),
//           //           boxShadow: [
//           //             BoxShadow(
//           //               color: Colors.black.withOpacity(0.3),
//           //               blurRadius: 8,
//           //               offset: const Offset(2, 4),
//           //             ),
//           //           ],
//           //         ),
//           //         child: Text(
//           //           'Sea Warehouse', // Second label name
//           //           textAlign: TextAlign.center,
//           //           style: GoogleFonts.roboto(
//           //             fontSize: 12,
//           //             fontWeight: FontWeight.w600,
//           //             color: Colors.black,
//           //           ),
//           //         ),
//           //       ),
//           //     ),
//           //
//           //     // Spacer for Flexible Spacing
//           //     SizedBox(width: MediaQuery.of(context).size.width * 0.0), // 3% screen width gap
//           //     Flexible(
//           //       child: Container(
//           //         padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
//           //         decoration: BoxDecoration(
//           //           color: button_color,
//           //           borderRadius: BorderRadius.circular(30),
//           //           boxShadow: [
//           //             BoxShadow(
//           //               color: Colors.black.withOpacity(0.3),
//           //               blurRadius: 8,
//           //               offset: const Offset(2, 4),
//           //             ),
//           //           ],
//           //         ),
//           //         child: Text(
//           //           ' All Services ', // Third label name
//           //           textAlign: TextAlign.center,
//           //           style: GoogleFonts.roboto(
//           //             fontSize: 12,
//           //             fontWeight: FontWeight.w600,
//           //             color: Colors.black,
//           //           ),
//           //         ),
//           //       ),
//           //     ),
//           //   ],
//           // ),
//           SizedBox(height: MediaQuery.of(context).size.height * 0.02),
//         ],
//       ),
//     );
//   }
//
//
//
//
//
//
//
//
//
//
//
// //---------------its look ui--------
//
//   Widget _buildDashboardItem(BuildContext context, {
//     required IconData icon,
//     required String label,
//     required Widget screen,
//   }) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => screen),
//         );
//       },
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // The icon container (separate from label)
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeInOut,
//             margin: const EdgeInsets.all(10),
//             padding: const EdgeInsets.all(15),
//             decoration: BoxDecoration(
//               color: Colors.blue,
//               // gradient: const LinearGradient(
//               //   // colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
//               //   colors: Colors.blue,
//               //   begin: Alignment.topLeft,
//               //   end: Alignment.bottomRight,
//               // ),
//               borderRadius: BorderRadius.circular(25),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.3),
//                   blurRadius: 15,
//                   offset: const Offset(5, 5),
//                 ),
//               ],
//             ),
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 // Icon with border and animation
//                 AnimatedContainer(
//                   duration: const Duration(milliseconds: 500),
//                   curve: Curves.easeInOut,
//                   width: 75,
//                   height: 75,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       width: 3,
//                       color: Colors.white.withOpacity(0.8),
//                     ),
//                     color: Colors.blue,
//                     // gradient: const LinearGradient(
//                     //   colors: [Colors.purpleAccent, Colors.deepPurple],
//                     //   begin: Alignment.topLeft,
//                     //   end: Alignment.bottomRight,
//                     // ),
//                   ),
//                   child: Center(
//                     child: Icon(
//                       icon,
//                       size: 40,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Label placed below the design, completely separate
//         ],
//       ),
//     );
//   }
//
//   // Dynamic font size adjustment based on screen width
//   double dynamicFontSize(BuildContext context, double baseSize) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     if (screenWidth < 360) {
//       return baseSize * 0.85; // Smaller screens get slightly smaller font sizes
//     } else if (screenWidth > 600) {
//       return baseSize * 1.2; // Larger screens get slightly larger font sizes
//     }
//     return baseSize; // Default size for medium screens
//   }
// }
//
//   // -----------image --offers--------
//
//   class OfferImagesScreen extends StatefulWidget {
//   @override
//   _OfferImagesScreenState createState() => _OfferImagesScreenState();
// }
//
// class _OfferImagesScreenState extends State<OfferImagesScreen> {
//   List<Map<String, dynamic>> offers = [];
//   int currentIndex = 0;
//   final PageController _pageController = PageController();
//
//   @override
//   void initState() {
//     super.initState();
//     fetchOfferImages();
//     startAutoScroll();
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   // Fetch list of offers
//   Future<void> fetchOfferImages() async {
//     try {
//       //final response = await http.get(Uri.parse("http://192.168.137.1:8000/offers/"));
//       final response = await http.get(Uri.parse("http://64.23.143.44:8000/offers/"));
//       if (response.statusCode == 200) {
//         setState(() {
//           offers = List<Map<String, dynamic>>.from(jsonDecode(response.body));
//         });
//       } else {
//         print("Failed to load offers: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error fetching offers: $e");
//     }
//   }
//
//   // Fetch specific offer image
//   Future<Image> fetchOfferImage(String imageId) async {
//     //final url = Uri.parse("http://192.168.137.1:8000/offers/$imageId");
//     final url = Uri.parse("http://64.23.143.44:8000/offers/$imageId");
//     final response = await http.get(url);
//
//     if (response.statusCode == 200) {
//       return Image.memory(
//         response.bodyBytes,
//         fit: BoxFit.cover,
//       );
//     } else {
//       throw Exception("Failed to load image");
//     }
//   }
//
//   // Auto-scroll logic
//   void startAutoScroll() {
//     Timer.periodic(Duration(seconds: 7), (timer) {
//       if (_pageController.hasClients && offers.isNotEmpty) {
//         currentIndex = (currentIndex + 1) % offers.length;
//         _pageController.animateToPage(
//           currentIndex,
//           duration: Duration(milliseconds: 420),
//           curve: Curves.easeInOut,
//         );
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Scaffold(
//       backgroundColor: background_color,
//       body: offers.isEmpty
//           ? Center(
//         child: CircularProgressIndicator(
//           color: app_bar_color, // Custom indicator color
//         ),
//       )
//           : Column(
//         children: [
//           // Carousel with indicators
//           Expanded(
//             flex: 8,
//             child: Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: MediaQuery.of(context).size.width * 0.03, // 5% of screen width
//                 vertical: MediaQuery.of(context).size.height * 0.02, // 2% of screen height
//               ),
//               child: Stack(
//                 alignment: Alignment.bottomCenter,
//                 children: [
//                   PageView.builder(
//                     controller: _pageController,
//                     itemCount: offers.length,
//                     onPageChanged: (index) {
//                       setState(() {
//                         currentIndex = index;
//                       });
//                     },
//                     itemBuilder: (context, index) {
//                       final offer = offers[index];
//                       return FutureBuilder<Image>(
//                         future: fetchOfferImage(offer['id'].toString()),
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState == ConnectionState.waiting) {
//                             return Center(
//                               child: CircularProgressIndicator(
//                                 color: app_bar_color,
//                               ),
//                             );
//                           } else if (snapshot.hasError) {
//                             return Center(child: Icon(Icons.error));
//                           } else {
//                             return ClipRRect(
//                               borderRadius: BorderRadius.circular(10),
//                               child: snapshot.data!,
//                             );
//                           }
//                         },
//                       );
//                     },
//                   ),
//                   // Indicator for carousel
//                   Positioned(
//                     bottom: MediaQuery.of(context).size.height * 0.03, // 3% of screen height
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: List.generate(
//                         offers.length,
//                             (index) => Container(
//                           margin: EdgeInsets.symmetric(horizontal: 4),
//                           width: currentIndex == index ? 12 : 8,
//                           height: 8,
//                           decoration: BoxDecoration(
//                             color: currentIndex == index
//                                 ? Colors.red
//                                 : Colors.grey,
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       ),
//     );
//   }
// }
//
//
//
//
//
//
//
//
//
//
//
// class CargoBookingScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           //Purple Header Section
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
//             decoration: BoxDecoration(
//               color: Color(0xFF4A00E0), // Purple background
//               borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(25),
//                       topRight: Radius.circular(25),
//                       bottomLeft: Radius.circular(25),
//                       bottomRight: Radius.circular(25),
//                     ),
//             ),
//             child: Column(
//               children: [
//                 // Header Text
//                 Text(
//                   "Instant Cargo, Effortless Booking\nJust a Tap Away!",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: screenWidth * 0.05,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: 15),
//                 // Booking Button
//                 SizedBox(
//                   width: screenWidth * 0.8,
//                   height: 50,
//                   child: ElevatedButton(
//                     onPressed: () {},
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: Colors.black,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: Text("Instant Cargo Booking"),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 20),
//
//           // Cargo Service Grid
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               child: GridView.builder(
//                 physics: BouncingScrollPhysics(),
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2, // Always 2 per row
//                   crossAxisSpacing: 15,
//                   mainAxisSpacing: 15,
//                   childAspectRatio: 1.2, // Ensures proper card size
//                 ),
//                 itemCount: cargoOptions.length,
//                 itemBuilder: (context, index) {
//                   return CargoCard(option: cargoOptions[index]);
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Cargo Option Model
// class CargoOption {
//   final String title;
//   final String image;
//
//   CargoOption({required this.title, required this.image});
// }
//
// // Sample Cargo Options
// List<CargoOption> cargoOptions = [
//   CargoOption(title: "Air Cargo Door To Door", image: "assets/images/airbg.png"),
//   CargoOption(title: "Sea Cargo Door To Door", image: "assets/images/airbg.png"),
//   CargoOption(title: "Air Cargo Warehouse", image: "assets/images/doorbg.png"),
//   CargoOption(title: "Sea Cargo Warehouse", image: "assets/images/doorbg.png"),
// ];
//
// // Cargo Card Widget
// class CargoCard extends StatelessWidget {
//   final CargoOption option;
//
//   const CargoCard({Key? key, required this.option}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 5,
//       child: Stack(
//         alignment: Alignment.center, // Ensures text is centered
//         children: [
//           // Background Image
//           ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Image.asset(
//               option.image,
//               fit: BoxFit.cover,
//               width: double.infinity,
//               height: double.infinity,
//             ),
//           ),
//           // Dark Gradient Overlay for Better Text Visibility
//           Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               gradient: LinearGradient(
//                 colors: [Colors.black.withOpacity(0.6), Colors.transparent],
//                 begin: Alignment.bottomCenter,
//                 end: Alignment.topCenter,
//               ),
//             ),
//           ),
//           // Title & Button
//           Positioned(
//             bottom: 10,
//             child: Column(
//               children: [
//                 // Card Title
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 8),
//                   child: Text(
//                     option.title,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 5),
//                 // Book Now Button
//                 SizedBox(
//                   width: 120,
//                   height: 35,
//                   child: ElevatedButton(
//                     onPressed: () {},
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: Colors.black,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: Text("Book Now"),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }







