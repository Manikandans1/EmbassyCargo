class LoginRequest {
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password
  });

  // Converts the object to JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

class LoginResponse {
  final String accessToken;
  final String tokenType;

  LoginResponse({required this.accessToken, required this.tokenType});

  // Converts JSON response to a LoginResponse object
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
    );
  }
}

class UserProfile {
  final String name;
  final String usernumber;
  final String membershipDate;
  final String membershipYear;

  UserProfile({
    required this.name,
    required this.usernumber,
    required this.membershipDate,
    required this.membershipYear
  });
}
