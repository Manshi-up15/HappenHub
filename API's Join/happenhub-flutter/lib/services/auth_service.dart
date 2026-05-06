import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

/// Handles authentication: register, login, logout, and token persistence.
class AuthService {
  // ─── Register ──────────────────────────────────────────
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String role = 'USER',
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.authUrl}/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password, 'role': role}),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 201 && body['success'] == true) {
      final user = UserModel.fromJson(body['data']);
      await _saveUser(user);
      return user;
    }
    throw Exception(body['message'] ?? 'Registration failed');
  }

  // ─── Login ─────────────────────────────────────────────
  Future<UserModel> login({required String email, required String password}) async {
    final response = await http.post(
      Uri.parse('${AppConstants.authUrl}/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['success'] == true) {
      final user = UserModel.fromJson(body['data']);
      await _saveUser(user);
      return user;
    }
    throw Exception(body['message'] ?? 'Login failed');
  }

  // ─── Persist user data locally ─────────────────────────
  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey,     user.token);
    await prefs.setInt(AppConstants.userIdKey,        user.id);
    await prefs.setString(AppConstants.userNameKey,   user.name);
    await prefs.setString(AppConstants.userEmailKey,  user.email);
    await prefs.setString(AppConstants.userRoleKey,   user.role);
  }

  // ─── Load saved user (auto-login) ──────────────────────
  Future<UserModel?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    if (token == null) return null;

    return UserModel(
      id:    prefs.getInt(AppConstants.userIdKey) ?? 0,
      name:  prefs.getString(AppConstants.userNameKey) ?? '',
      email: prefs.getString(AppConstants.userEmailKey) ?? '',
      role:  prefs.getString(AppConstants.userRoleKey) ?? 'USER',
      token: token,
    );
  }

  // ─── Logout ────────────────────────────────────────────
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ─── Get stored token ──────────────────────────────────
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }
}
