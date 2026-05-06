import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'api_client.dart';

/// Handles registration, login, logout, and local credential persistence.
class AuthService {
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String role = 'USER',
  }) async {
    final data = await ApiClient.post(
      '${AppConstants.authUrl}/register',
      body: {'name': name, 'email': email, 'password': password, 'role': role},
      auth: false,
    );
    final user = UserModel.fromJson(data as Map<String, dynamic>);
    await _persist(user);
    return user;
  }

  Future<UserModel> login({required String email, required String password}) async {
    final data = await ApiClient.post(
      '${AppConstants.authUrl}/login',
      body: {'email': email, 'password': password},
      auth: false,
    );
    final user = UserModel.fromJson(data as Map<String, dynamic>);
    await _persist(user);
    return user;
  }

  Future<void> _persist(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey,     user.token);
    await prefs.setInt   (AppConstants.userIdKey,    user.id);
    await prefs.setString(AppConstants.userNameKey,  user.name);
    await prefs.setString(AppConstants.userEmailKey, user.email);
    await prefs.setString(AppConstants.userRoleKey,  user.role);
  }

  Future<UserModel?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    if (token == null || token.isEmpty) return null;
    return UserModel(
      id:    prefs.getInt   (AppConstants.userIdKey)    ?? 0,
      name:  prefs.getString(AppConstants.userNameKey)  ?? '',
      email: prefs.getString(AppConstants.userEmailKey) ?? '',
      role:  prefs.getString(AppConstants.userRoleKey)  ?? 'USER',
      token: token,
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
