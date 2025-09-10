import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _role;
  String? _userEmail;

  String? get token => _token;
  bool get isLoggedIn => _token != null;
  String? get userEmail => _userEmail;
  String? get role => _role;

  final String baseUrl = "http://localhost:8080";

  Future<void> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email,
        "password": password,
        "role": "CUSTOMER",
      }),
    );

    if (response.statusCode == 201) {
      await login(email, password);
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email,
        "password": password,
        "role": "CUSTOMER",
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['token'];
      _role = data['role'];
      _userEmail = email;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('role', _role!);
      await prefs.setString('userEmail', email);

      notifyListeners();
      return true;
    } else {
      _token = null;
      _role = null;
      _userEmail = null;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _role = null;
    _userEmail = null;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    await prefs.remove('userEmail');

    notifyListeners();
  }

  Future<void> loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _role = prefs.getString('role');
    _userEmail = prefs.getString('userEmail');
    notifyListeners();
  }
}
