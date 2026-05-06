/// Matches the AuthResponse DTO from the backend.
class UserModel {
  final int id;
  final String name;
  final String email;
  final String role; // USER or BUSINESS
  final String token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:    json['userId'] as int,
      name:  json['name'] as String,
      email: json['email'] as String,
      role:  json['role'] as String,
      token: json['token'] as String,
    );
  }

  bool get isBusiness => role == 'BUSINESS';
}
