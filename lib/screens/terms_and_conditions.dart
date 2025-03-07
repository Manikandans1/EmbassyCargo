import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';  // Importing GoogleFonts package
import '../utils/colors.dart';

class TermsAndConditions extends StatefulWidget {
  const TermsAndConditions({super.key});

  @override
  _TermsAndConditionsState createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> {
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
                'Terms & Conditions',
                style: GoogleFonts.roboto(
                  fontSize: dynamicFontSize(context, 22), // Responsive font size
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                  shadows: [
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
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: background_color,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: app_bar_color,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black, offset: Offset(0, 6), blurRadius: 9),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TERMS AND CONDITIONS',
                      style: GoogleFonts.roboto(
                        fontSize: dynamicFontSize(context, 22), // Responsive font size
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '''
1. Consignees please kindly clear out all your doubts, formalities, and queries about your cargo before leaving the Sri Lanka Warehouse (Quantity of the items and Damaged items). We are not responsible for any further complaints or misunderstandings after leaving the Warehouse premises.

2. Consignees please be informed if your cargo goods have any Custom duty or demurrage at the clearing point, please ensure to collect the receipt of payment.

2A. Custom duties have to be paid to the government by the consignee.
    
2B. Demurrage has to be paid to the clearing agent officials.
      (We are not responsible for any payments that are made unofficially)

3. Please note that we will not be responsible for the following items i.e.: Alcoholic, tobacco items, and unauthorized items detained by Sri Lanka customs. Such as (Tires, Vehicle spare parts, deep freezer, and dangerous goods).

4. Consignees should provide us with the exact details of the address and the contact number, so our team can contact once your cargo has arrived at the clearing point. If the contact details are incorrect and we are not able to reach you, we are not responsible for the demurrages at the clearing point.

5. Consignees please be informed if RTF occurs and Custom Officers need to inspect the cargo for (Kandy/ Addalachchenal/ Dambulla). Please note we will be issuing a voucher against it.
                    ''',
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
