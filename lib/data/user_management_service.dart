import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserManagementService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Crear un usuario desde el panel admin
  Future<String?> createUser({
    required String name,
    required String email,
    required String password,
    required String plan,
  }) async {
    try {
      // 🔑 Guardar credenciales del admin actual
      final adminEmail = _auth.currentUser?.email;
      final adminPassword = await _getAdminPassword(); // Ver método abajo

      // 1. Crear usuario en Firebase Auth
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCred.user!.uid;

      // 2. Crear documento Firestore
      await _db.collection("users").doc(uid).set({
        "name": name,
        "email": email,
        "role": "user",
        "active": true,
        "plan": plan,
        "createdAt": FieldValue.serverTimestamp(),
      });

      print("✅ Usuario creado: $email (UID: $uid)");

      // 3. ⚠️ Volver a iniciar sesión como admin
      if (adminEmail != null && adminPassword != null) {
        await _auth.signOut(); // Cerrar sesión del nuevo usuario
        await _auth.signInWithEmailAndPassword(
          email: adminEmail,
          password: adminPassword,
        );
        print("✅ Sesión de admin restaurada");
      }

      return null; // null = sin errores
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Error inesperado: $e";
    }
  }

  /// 🔐 Obtener contraseña del admin (necesitas implementar esto)
  /// OPCIÓN 1: Pedir al admin que reingrese su contraseña antes de crear usuarios
  /// OPCIÓN 2: Usar SharedPreferences (NO RECOMENDADO por seguridad)
  /// OPCIÓN 3: Usar Cloud Functions (RECOMENDADO)
  Future<String?> _getAdminPassword() async {
    // Por ahora retorna null
    // Implementa según tu necesidad
    return null;
  }
}