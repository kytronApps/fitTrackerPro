import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔹 Iniciar sesión del administrador o usuario normal
  Future<User?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print("✅ Login correcto: ${cred.user?.email}");

      final uid = cred.user!.uid;
      print("🔑 UID del usuario autenticado: $uid");

      // Obtener documento del usuario
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();

      if (!doc.exists) {
        print("⚠️ El usuario no tiene documento en Firestore");
      } else {
        print("📌 Datos de usuario: ${doc.data()}");
      }

      return cred.user;
    } on FirebaseAuthException catch (e) {
      print("⚠️ Error de login: ${e.message}");
      return null;
    }
  }

  /// 🔹 Cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
    print("👋 Sesión cerrada");
  }

  /// 🔹 Obtener usuario actual de Firebase
  User? get usuarioActual => _auth.currentUser;
}
