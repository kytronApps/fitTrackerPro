import 'package:cloud_firestore/cloud_firestore.dart';

/// ======================================
/// 🏋️ EJERCICIO DEL PROGRAMA
/// ======================================
class ProgramExercise {
  final int order;
  final String name;
  final int sets;
  final String reps;
  final int rpe;

  ProgramExercise({
    required this.order,
    required this.name,
    required this.sets,
    required this.reps,
    required this.rpe,
  });

  factory ProgramExercise.fromMap(Map<String, dynamic> map) {
    return ProgramExercise(
      order: map['order'] ?? 0,
      name: map['name'] ?? '',
      sets: map['sets'] ?? 0,
      reps: map['reps'] ?? '',
      rpe: map['rpe'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'order': order,
      'name': name,
      'sets': sets,
      'reps': reps,
      'rpe': rpe,
    };
  }

  String get displayFormat => '$sets x $reps  @RPE $rpe';
}

/// ======================================
/// 📦 PROGRAMA / BLOQUE
/// ======================================
class ProgramModel {
  final String id;
  final String userId;
  final String name;
  final int blockNumber;
  final bool active;
  final DateTime createdAt;
  final DateTime? finishedAt;
  final List<ProgramExercise> exercises;

  ProgramModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.blockNumber,
    required this.active,
    required this.createdAt,
    this.finishedAt,
    required this.exercises,
  });

  factory ProgramModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ProgramModel(
      id: doc.id,
      userId: data['id_user'],
      name: data['name'] ?? 'Bloque',
      blockNumber: data['block_number'] ?? 1,
      active: data['active'] == true,
      createdAt: _parseDate(data['created_at']) ?? DateTime.now(),
      finishedAt: _parseDate(data['finished_at']),
      exercises: (data['exercises'] as List<dynamic>? ?? [])
          .map((e) => ProgramExercise.fromMap(e))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id_user': userId,
      'name': name,
      'block_number': blockNumber,
      'active': active,
      'created_at': Timestamp.fromDate(createdAt),
      'finished_at':
          finishedAt != null ? Timestamp.fromDate(finishedAt!) : null,
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }

  bool get isFinished => !active && finishedAt != null;

  int get totalExercises => exercises.length;

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    return null;
  }
}
