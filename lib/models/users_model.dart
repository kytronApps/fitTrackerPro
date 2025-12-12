import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String plan;
  final bool active;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.plan,
    required this.active,
    this.createdAt,
  });

  // Crear desde Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      name: data['name'] ?? 'Sin nombre',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      plan: data['plan'] ?? 'Sin plan',
      active: data['active'] ?? true,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'plan': plan,
      'active': active,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
    };
  }

  // Copiar con modificaciones
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? plan,
    bool? active,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      plan: plan ?? this.plan,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Obtener inicial del nombre
  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  // Formatear fecha de creación
  String get formattedDate {
    if (createdAt == null) return 'Fecha desconocida';
    
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

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role, plan: $plan, active: $active)';
  }
}