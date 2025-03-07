import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../services/connectivity_service.dart';
import '../utils/colors.dart';
import 'no_internet_screen.dart';
import 'otp_screen.dart';
import 'package:flutter/src/widgets/will_pop_scope.dart';
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});
  @override
  _BookingScreenState createState() => _BookingScreenState();
}
class _BookingScreenState extends State<BookingScreen> {

  final ConnectivityService _connectivityService = ConnectivityService();
  late StreamSubscription<bool> _subscription;
  bool _hasInternet = true;
  bool _isNoInternetScreenShown = false;

  // Define controllers to capture user input
  final FocusNode _nameFocusNode = FocusNode();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pickupDateController = TextEditingController();
  final TextEditingController _senderPhoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();



  String? _selectedSenderCountry;
  String? _selectedReceiverCountry;
  String? _selectedCargoType;

  final List<String> _countries = ['UAE', 'Sri Lanka'];
  final List<String> _countriess = ['Sri Lanka', 'UAE'];
  final List<String> _cargoTypes = ['Select Cargo Type','Air Cargo Door To Door', 'Sea Cargo Door To Door', 'Air Cargo Warehouse Collection', 'Sea Cargo Warehouse Collection'];


  @override
  void initState() {
    super.initState();
    _selectedSenderCountry = _countries.isNotEmpty ? _countries[0] : null;
    _selectedReceiverCountry = _countriess.isNotEmpty ? _countriess[0] : null;
    _selectedCargoType = _cargoTypes.isNotEmpty ? _cargoTypes[0] : null;

    _connectivityService.checkConnectivity().then((hasConnection) {
      setState(() {
        _hasInternet = hasConnection;
      });
      if (!_hasInternet && !_isNoInternetScreenShown) {
        _showNoInternetScreen();
      }
    });

    _subscription = _connectivityService.connectionStatusStream.listen((hasConnection) {
      setState(() {
        _hasInternet = hasConnection;
      });

      if (!_hasInternet && !_isNoInternetScreenShown) {
        _showNoInternetScreen();
      } else if (_hasInternet && _isNoInternetScreenShown) {
        Navigator.pop(context);
        _isNoInternetScreenShown = false;
      }
    });
  }

  void _showNoInternetScreen() {
    setState(() {
      _isNoInternetScreenShown = true;
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoInternetScreen()),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pickupDateController.dispose();
    _senderPhoneController.dispose();
    _locationController.dispose();
    _remarksController.dispose();
    _subscription.cancel();
    _connectivityService.dispose();
    super.dispose();
  }
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

  bool isLoading = false;
  Future<void> sendOtp(String senderNumber) async {
    print('Sending OTP for phone number: $senderNumber'); // Debugging line

    setState(() {
      isLoading = true;  // Set loading to true before making the API request
    });

    final url = Uri.parse('http://64.23.143.44:8000/send_otp?sender_number=$senderNumber');  // Modify to send sender_number as query param

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        // You no longer need to send the sender_number in the body
        // body: json.encode({'sender_number': senderNumber}),
      );

      print('Response Status: ${response.statusCode}');  // Debugging line
      print('Response Body: ${response.body}');  // Debugging line

      if (response.statusCode == 200) {
        // Successfully sent OTP, navigate to OTP screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(orderDetails: {
              'customer_name': _nameController.text,
              'pickup_date': _pickupDateController.text,
              'sender_country': _selectedSenderCountry,
              'receiver_country': _selectedReceiverCountry,
              'sender_number': _senderPhoneController.text,
              'cargo_type': _selectedCargoType,
              'pickup_location': _locationController.text,
              'remarks': _remarksController.text,
            }),
          ),
        );
      } else {
        // Handle failure
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Failed to send OTP",
          style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),),backgroundColor: Colors.blue,));
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Error: $e",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),backgroundColor: Colors.blue,));
    } finally {
      setState(() {
        isLoading = false;  // Set loading to false after API request completes
      });
    }
  }



  void submitBooking() async {
    if (_nameController.text.isEmpty ||
        _pickupDateController.text.isEmpty ||
        _senderPhoneController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _selectedSenderCountry == null ||
        _selectedReceiverCountry == null ||
        _selectedCargoType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields before submitting!',
          style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),),backgroundColor: Colors.blue,),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Send OTP after form submission
    await sendOtp(_senderPhoneController.text);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;


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
              title: Text(
                'Booking',
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
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.02),
              Container(
                width: screenWidth * 0.4,
                height: screenHeight * 0.2,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/booking.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.05),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Name',
                      keyboardType: TextInputType.name,
                      screenWidth: screenWidth,
                      floatingLabelColor: lightWhite,
                      focusNode: _nameFocusNode,
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    _buildTextFieldd(
                      controller: _pickupDateController,
                      label: 'PickUp Date',
                      keyboardType: TextInputType.datetime,
                      screenWidth: screenWidth,
                      floatingLabelColor: lightWhite,
                      context: context,
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    _buildTextField(
                      controller: _senderPhoneController,
                      keyboardType: TextInputType.phone,
                      label: 'Sender Phone Number',
                      screenWidth: screenWidth,
                      floatingLabelColor: lightWhite,
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    _buildTextField(
                      controller: _locationController,
                      label: 'Location',
                      keyboardType: TextInputType.name,
                      screenWidth: screenWidth,
                      floatingLabelColor: lightWhite,
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    _buildDropdownField(
                      label: 'Sender Country',
                      value: _selectedSenderCountry,
                      items: _countries,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedSenderCountry = newValue;
                        });
                      },
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    _buildDropdownField(
                      label: 'Receiver Country',
                      value: _selectedReceiverCountry,
                      items: _countriess,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedReceiverCountry = newValue;
                        });
                      },
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    _buildDropdownField(
                      label: 'Cargo Type',
                      value: _selectedCargoType,
                      items: _cargoTypes,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCargoType = newValue;
                        });
                      },
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    _buildTextField(
                      controller: _remarksController,
                      label: 'Remarks',
                      keyboardType: TextInputType.name,
                      screenWidth: screenWidth,
                      floatingLabelColor: lightWhite,
                      isOptional: true,
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    ElevatedButton(
                      onPressed: isLoading ? null : submitBooking, // Disable button when loading
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: button_color,
                        minimumSize: const Size(double.infinity, 0), // Ensures full width
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Same border radius
                        ),
                      ),
                      child: isLoading
                          ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(button_color),
                      )
                          : Text(
                        'Done',
                        style: GoogleFonts.roboto(
                          fontSize: dynamicFontSize(context, 20), // Responsive font size
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Navy blue text color
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.1),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildTextField({
    required String label,
    required double screenWidth,
    required Color floatingLabelColor,
    required TextInputType keyboardType,
    required TextEditingController controller,
    FocusNode? focusNode,
    bool isOptional = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.0),
      child: Focus(
        child: Builder(
          builder: (context) {
            final bool isFocused = Focus.of(context).hasFocus;
            return Container(
              decoration: BoxDecoration(
                color: app_bar_color,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25), // Shadow color
                    offset: const Offset(0, 4), // Shadow position
                    blurRadius: 4, // Blur effect
                  ),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                style: GoogleFonts.roboto(
                  fontSize: dynamicFontSize(context, 18), // Responsive font size
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Navy blue text color
                ),
                decoration: InputDecoration(
                  //labelText: label,
                  labelText: isOptional ? '$label (Optional)' : label,
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  filled: true, // Enable background fill
                  fillColor: Colors.grey.withOpacity(0.3), // Set the background color to red
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.black, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  ),
                  // Set label color to black for both normal and focused states
                  labelStyle: GoogleFonts.roboto(
                    fontSize: dynamicFontSize(context, 18), // Responsive font size
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Navy blue text color
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: app_bar_color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25), // Shadow color
            offset: const Offset(0, 4), // Shadow position
            blurRadius: 4, // Blur effect
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          filled: true,
          fillColor: Colors.grey.withOpacity(0.3), // Set the background color to red
          border:  OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
          ),
          labelStyle: GoogleFonts.roboto(
            fontSize: dynamicFontSize(context, 18), // Responsive font size
            fontWeight: FontWeight.bold,
            color: Colors.white, // Navy blue text color
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.black, // Set the border color to black when focused
              width: 2.0,
            ),
          ),
        ),
        icon: Icon(Icons.arrow_drop_down, color: Colors.white),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Container(
              color: app_bar_color.withOpacity(0.1), // Set dropdown menu background color to white
              child: Text(
                value,
                style: GoogleFonts.roboto(
                  fontSize: dynamicFontSize(context, 18), // Responsive font size
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Navy blue text color
                ),
              ),
            ),
          );
        }).toList(),
        dropdownColor: app_bar_color, // Set the dropdown menu background to white
      ),
    );
  }

  ///---------date------------------

  Future<void> _showDatePickerDialog(
      BuildContext context, TextEditingController controller) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            dialogBackgroundColor: app_bar_color, // Change background color here
            colorScheme: ColorScheme.light(
              primary: Colors.purple, // Header background color
              onPrimary: Colors.white, // Header text color
              surface: background_color, // Dialog background color
              onSurface: Colors.black, // Text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.purple, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      controller.text = "${selectedDate.toLocal()}".split(' ')[0];
    }
  }
  Widget _buildTextFieldd({
    required TextEditingController controller,
    required String label,
    required TextInputType keyboardType,
    required double screenWidth,
    required Color floatingLabelColor,
    required BuildContext context,
  }) {

    return Container(
      decoration: BoxDecoration(
        color: app_bar_color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25), // Shadow color
            offset: const Offset(0, 4), // Shadow position
            blurRadius: 4, // Blur effect
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: true,
        style: GoogleFonts.roboto(
          fontSize: dynamicFontSize(context, 18), // Responsive font size
          fontWeight: FontWeight.bold,
          color: Colors.white, // Navy blue text color
        ),
        onTap: () {
          _showDatePickerDialog(context, controller); // Trigger date picker dialog on tap
        },
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          filled: true, // Enable background fill
          fillColor: Colors.grey.withOpacity(0.3),
          suffixIcon: const Icon(Icons.calendar_month_sharp,color: Colors.white,),// Set the background color to red
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.black,
              width: 2.0,
            ),
          ),
          // Set label color to black for both normal and focused states
          labelStyle: GoogleFonts.roboto(
            fontSize: dynamicFontSize(context, 18), // Responsive font size
            fontWeight: FontWeight.bold,
            color: Colors.white, // Navy blue text color
          ),
        ),
      ),
    );
  }
}