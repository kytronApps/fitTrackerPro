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

      return null; // null = sin errores
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Error inesperado: $e";
    }
  }
}
