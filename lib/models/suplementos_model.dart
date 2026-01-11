import 'package:cloud_firestore/cloud_firestore.dart';

/// ======================================
/// 💊 MODELO DE SUPLEMENTO
/// ======================================
class SupplementModel {
  final String id;
  final String userId;
  final String name;
  final String? dosage;
  final String? timing;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SupplementModel({
    required this.id,
    required this.userId,
    required this.name,
    this.dosage,
    this.timing,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory SupplementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return SupplementModel(
      id: doc.id,
      userId: data['id_user'] ?? '',
      name: data['name'] ?? '',
      dosage: data['dosage'],
      timing: data['timing'],
      notes: data['notes'],
      createdAt: _parseDate(data['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(data['updated_at']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id_user': userId,
      'name': name,
      if (dosage != null) 'dosage': dosage,
      if (timing != null) 'timing': timing,
      if (notes != null) 'notes': notes,
      'created_at': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updated_at': Timestamp.fromDate(updatedAt!),
    };
  }

  SupplementModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? dosage,
    String? timing,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupplementModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      timing: timing ?? this.timing,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayInfo {
    final parts = <String>[];
    if (dosage != null && dosage!.isNotEmpty) parts.add(dosage!);
    if (timing != null && timing!.isNotEmpty) parts.add(timing!);
    return parts.isEmpty ? 'Sin detalles' : parts.join(' • ');
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    return null;
  }
}