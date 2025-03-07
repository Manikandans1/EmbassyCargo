import 'dart:convert';
import 'package:embassycargo/models/order_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_request.dart';
import '../models/user_model.dart';

class ApiService {
  //final String baseUrl = 'http://10.0.2.2:8000';
  // final String baseUrl = 'http://192.168.137.1:8000'; // Update with your FastAPI base URL
  final String baseUrl = "http://64.23.143.44:8000"; // Update with your FastAPI base URL
//-----------LOGIN-----------------
  Future<LoginResponse> loginUser(LoginRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',  // Set the correct header
      },
      body: {
        'username': request.username,  // Send data as form-data
        'password': request.password,
      },
    );

    if (response.statusCode == 200) {
      // Decode the login response
      final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
      // Save token to SharedPreferences
      await SharedPreferences.getInstance().then((prefs) {
        prefs.setString('accessToken', loginResponse.accessToken);
        prefs.setString('tokenType', loginResponse.tokenType);
      });
      return loginResponse; // Return login response
    } else {
      throw Exception('Failed to login: ${response.statusCode} ${response.reasonPhrase}');
    }
  }


  // Fetch user details using the access token
  Future<Map<String, dynamic>> fetchUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('accessToken');

    final response = await http.get(
      Uri.parse('$baseUrl/profile/1/'), // Assuming you always want to fetch profile for user ID 1
      headers: {
        'Authorization': 'Bearer $token', // Add token to the Authorization header
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Assuming the response is in JSON format
    } else {
      throw Exception('Failed to fetch user details: ${response.statusCode}');
    }
  }

//---------order----
  Future<OrderModel> createOrderModel(OrderModel request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/order/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
            'customer_name': request.customername,
            'pickup_date': request.pickupdate,
            'sender_country': request.sendercountry,
            'receiver_country': request.receivercountry,
            'sender_number': request.sendernumber,
            'cargo_type': request.cargotype,
            'pickup_location': request.pickuplocation,
            'remarks': request.remarks
      }),
    );
    if (response.statusCode == 201) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      return OrderModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create album.');
    }
  }

  // Method to save token using SharedPreferences
  Future<void> _saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  //-----------------Registration Function-------------String userName, String userNumber, String userPassword
  Future<void> registerUser(UserModel request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_name': request.username,
          'user_number': request.number,
          'user_password': request.password,
        }),
      );

      print('Request Body: ${json.encode({
        'user_name': request.username,
        'user_number': request.number,
        'user_password': request.password,
      })}'); // Log the request body

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('User registered successfully: $responseData');
        // Show success message in UI
      } else {
        print('Failed to register user: ${response.statusCode} - ${response.body}');
        // Show error message in UI
      }
    } catch (error) {
      print('Error: $error');
      // Handle error, maybe show a message to the user
    }
  }



  // OFFER IMAGES
  Future<List<String>> fetchImageUrls() async {
    final response = await http.get(Uri.parse("$baseUrl/images/"));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['images'] as List<dynamic>)
          .map((image) => "$baseUrl${image['file_url']}")
          .toList(); // Extract image URLs
    } else {
      throw Exception("Failed to fetch images");
    }
  }
  }





class TrackingService {
  final String _baseUrl = 'http://127.0.0.1:8000'; // FastAPI base URL

  // Fetch live update details based on tracking ID
  Future<Map<String, dynamic>> getLiveUpdate(int trackingId) async {
    final url = '$_baseUrl/orders/liveupdate/$trackingId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch live tracking data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
