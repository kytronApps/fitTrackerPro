import 'package:cloud_firestore/cloud_firestore.dart';

/// ======================================
/// 🏋️ EJERCICIO DEL PROGRAMA
/// ======================================
class ProgramExercise {
  final int order;
  final String name;
  final int sets;
  final String reps;
  final int? rpe;

  ProgramExercise({
    required this.order,
    required this.name,
    required this.sets,
    required this.reps,
    this.rpe,
  });

  factory ProgramExercise.fromMap(Map<String, dynamic> map) {
    return ProgramExercise(
      order: map['order'] ?? 0,
      name: map['name'] ?? '',
      sets: map['sets'] ?? 0,
      reps: map['reps'] ?? '',
      rpe: map['rpe'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'order': order,
      'name': name,
      'sets': sets,
      'reps': reps,
      if (rpe != null) 'rpe': rpe,
    };
  }

  String get displayFormat {
    if (rpe != null) {
      return '$sets x $reps @$rpe';
    }
    return '$sets x $reps';
  }

  ProgramExercise copyWith({
    int? order,
    String? name,
    int? sets,
    String? reps,
    int? rpe,
  }) {
    return ProgramExercise(
      order: order ?? this.order,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      rpe: rpe ?? this.rpe,
    );
  }
}

/// ======================================
/// 📅 DÍA DE ENTRENAMIENTO
/// ======================================
class TrainingDay {
  final int dayNumber;
  final String? name;
  final List<ProgramExercise> exercises;

  TrainingDay({
    required this.dayNumber,
    this.name,
    required this.exercises,
  });

  factory TrainingDay.fromMap(Map<String, dynamic> map) {
    return TrainingDay(
      dayNumber: map['day_number'] ?? 1,
      name: map['name'],
      exercises: (map['exercises'] as List<dynamic>? ?? [])
          .map((e) => ProgramExercise.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day_number': dayNumber,
      if (name != null) 'name': name,
      'exercises': exercises.map((e) => e.toMap()).toList(),
    };
  }

  String get displayName => name ?? 'Día $dayNumber';
  
  int get totalExercises => exercises.length;

  TrainingDay copyWith({
    int? dayNumber,
    String? name,
    List<ProgramExercise>? exercises,
  }) {
    return TrainingDay(
      dayNumber: dayNumber ?? this.dayNumber,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
    );
  }
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
  final List<TrainingDay> trainingDays;

  ProgramModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.blockNumber,
    required this.active,
    required this.createdAt,
    this.finishedAt,
    required this.trainingDays,
  });

  factory ProgramModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ProgramModel(
      id: doc.id,
      userId: data['id_user'] ?? '',
      name: data['name'] ?? 'Bloque',
      blockNumber: data['block_number'] ?? 1,
      active: data['active'] == true,
      createdAt: _parseDate(data['created_at']) ?? DateTime.now(),
      finishedAt: _parseDate(data['finished_at']),
      trainingDays: (data['training_days'] as List<dynamic>? ?? [])
          .map((e) => TrainingDay.fromMap(e as Map<String, dynamic>))
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
      if (finishedAt != null) 'finished_at': Timestamp.fromDate(finishedAt!),
      'training_days': trainingDays.map((d) => d.toMap()).toList(),
    };
  }

  bool get isFinished => !active && finishedAt != null;

  int get totalDays => trainingDays.length;
  
  int get totalExercises => trainingDays.fold(
    0, 
    (sum, day) => sum + day.totalExercises,
  );

  ProgramModel copyWith({
    String? id,
    String? userId,
    String? name,
    int? blockNumber,
    bool? active,
    DateTime? createdAt,
    DateTime? finishedAt,
    List<TrainingDay>? trainingDays,
  }) {
    return ProgramModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      blockNumber: blockNumber ?? this.blockNumber,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      finishedAt: finishedAt ?? this.finishedAt,
      trainingDays: trainingDays ?? this.trainingDays,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    return null;
  }
}