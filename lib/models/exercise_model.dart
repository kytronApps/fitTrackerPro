import 'package:cloud_firestore/cloud_firestore.dart';

// ==========================================
// MODELO DE EJERCICIO (Collection: exercies)
// ==========================================
class ExerciseModel {
  final String id;
  final String name;
  final String userId;
  final String programId;
  final DateTime? createdAt;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.userId,
    required this.programId,
    this.createdAt,
  });

  factory ExerciseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ExerciseModel(
      id: doc.id,
      name: data['name']?.toString() ?? 'Ejercicio',
      userId: data['userId']?.toString() ?? '',
      programId: data['programId']?.toString() ?? '',
      createdAt: _parseDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'userId': userId,
      'programId': programId,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    return null;
  }
}

// ==========================================
// MODELO DE PROTOCOLO (Collection: protocol)
// ==========================================
class ProtocolModel {
  final String id;
  final String description; // Ej: "4x10 @8"
  final String exerciseId;  // OJO: En tu DB se llama 'exercieId'

  ProtocolModel({
    required this.id,
    required this.description,
    required this.exerciseId,
  });

  factory ProtocolModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ProtocolModel(
      id: doc.id,
      description: data['description']?.toString() ?? '',
      // Aquí mapeamos tu campo 'exercieId' al nombre correcto en Dart
      exerciseId: data['exercieId']?.toString() ?? '', 
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'exercieId': exerciseId, // Guardamos con el nombre que tienes en DB
    };
  }
}