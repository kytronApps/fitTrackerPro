import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String plan;
  final bool active;
  final DateTime? createdAt;
  
  // CAMPOS OPCIONALES
  final String? fullName;
  final String? lastName;
  final int? age;
  final double? weight; // kg
  final double? height; // cm
  final String? objective; 
  final String? gender; 
  final String? phone;
  final String? notes;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.plan,
    required this.active,
    this.createdAt,
    this.fullName,
    this.lastName,
    this.age,
    this.weight,
    this.height,
    this.objective,
    this.gender,
    this.phone,
    this.notes,
  });

  // =========================================================
  // AQUÍ ESTÁ LA MAGIA: Lectura segura de datos
  // =========================================================
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return UserModel(
      id: doc.id,
      name: data['name']?.toString() ?? 'Sin nombre',
      email: data['email']?.toString() ?? '',
      role: data['role']?.toString() ?? 'user',
      plan: data['plan']?.toString() ?? 'Sin plan',
      active: data['active'] == true, // Si es null, será false
      createdAt: _parseDate(data['createdAt']),
      
      // Lectura segura de campos opcionales
      fullName: data['fullName']?.toString(),
      lastName: data['lastName']?.toString(),
      
      // TRUCO: Convertimos a String y luego a int/double para evitar errores
      age: _parseInt(data['age']),
      weight: _parseDouble(data['weight']),
      height: _parseDouble(data['height']),
      
      objective: data['objective']?.toString(),
      gender: data['gender']?.toString(),
      phone: data['phone']?.toString(),
      notes: data['notes']?.toString(),
    );
  }

  // Ayudante para convertir cualquier cosa a int (Texto o Número)
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString().trim());
  }

  // Ayudante para convertir cualquier cosa a double
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString().trim().replaceAll(',', '.'));
  }

  // Ayudante para fechas
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    return null;
  }

  // Convertir a Map para guardar en Firebase
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'plan': plan,
      'active': active,
      if (fullName != null) 'fullName': fullName,
      if (lastName != null) 'lastName': lastName,
      if (age != null) 'age': age,
      if (weight != null) 'weight': weight,
      if (height != null) 'height': height,
      if (objective != null) 'objective': objective,
      if (gender != null) 'gender': gender,
      if (phone != null) 'phone': phone,
      if (notes != null) 'notes': notes,
    };
  }

  // Getters útiles para la UI
  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  String get fullDisplayName {
    if (fullName != null && fullName!.isNotEmpty) return '$fullName ${lastName ?? ''}'.trim();
    return name;
  }

  // ===============================================
  // ESTO FALTABA: Getters para Fecha e IMC
  // ===============================================

  String get formattedDate {
    if (createdAt == null) return 'Sin fecha';
    
    final now = DateTime.now();
    final difference = now.difference(createdAt!);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
    }
  }

  double? get bmi {
    if (weight != null && height != null && height! > 0) {
      final heightInMeters = height! / 100;
      return weight! / (heightInMeters * heightInMeters);
    }
    return null;
  }
  
  String? get bmiCategory {
    final val = bmi;
    if (val == null) return null;
    if (val < 18.5) return 'Bajo peso';
    if (val < 25) return 'Normal';
    if (val < 30) return 'Sobrepeso';
    return 'Obesidad';
  }

}