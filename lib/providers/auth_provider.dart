import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _errorMessage;

  /// Getters públicos
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _userData != null;

  bool get isAdmin => _userData?["role"] == "admin";
  bool get isUser => _userData?["role"] == "user";

  /// 🔹 LOGIN ADMINISTRADOR (con email y contraseña)
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final user = await _authService.login(email, password);

    if (user == null) {
      _errorMessage = "Credenciales incorrectas";
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final uid = user.uid;

    // Buscar documento Firestore con UID
    final doc =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (!doc.exists) {
      _errorMessage = "El usuario no tiene información en Firestore";
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Guardamos datos del usuario
    _userData = doc.data();

    print("📌 Datos Firestore cargados: $_userData");

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// 🔹 LOGIN USUARIO (solo con email, sin contraseña)
  Future<bool> loginUser(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Buscar usuario por email en Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: email)
          .where("role", isEqualTo: "user")
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        _errorMessage = "No se encontró un usuario con ese correo";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Guardamos datos del usuario
      _userData = querySnapshot.docs.first.data();

      print("📌 Usuario encontrado: $_userData");

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Error al buscar el usuario: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 🔹 LOGOUT
  Future<void> logout() async {
    await _authService.logout();
    _userData = null;
    notifyListeners();
  }
}