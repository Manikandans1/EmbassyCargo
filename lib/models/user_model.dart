class UserModel {
  final String username;
  final String number;
  final String password;

  UserModel({
    required this.username,
    required this.number,
    required this.password,
  });

  // Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'user_name': username,
      'user_number': number,
      'user_password': password,
    };
  }

  // Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['user_name'],
      number: json['user_number'],
      password: json['user_password'],
    );
  }
}

class RegisterRequest {
  final String username;
  final String number;
  final String password;

  RegisterRequest({
    required this.username,
    required this.number,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_name': username,
      'user_number': number,
      'user_password': password,
    };
  }
}

class UserResponse {
  final String? message;
  final String? token;

  UserResponse({
    this.message,
    this.token,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      message: json['message'],
      token: json['token'],
    );
  }
}

