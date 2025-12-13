//modelo para ejercicios 

import 'package:cloud_firestore/cloud_firestore.dart';

/// Ejercicio individual
class Exercise {
  final String name;
  final String protocol; // 4X6-7 @8
  final String rest; // AL MENOS 2'
  final String? note;

  Exercise({
    required this.name,
    required this.protocol,
    required this.rest,
    this.note,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      name: map['name'] ?? '',
      protocol: map['protocol'] ?? '',
      rest: map['rest'] ?? '',
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'protocol': protocol,
      'rest': rest,
      if (note != null) 'note': note,
    };
  }
}

/// Bloque de ejercicios (A1, A2, A3)
class WorkoutBlock {
  final String name; // Bloque A1, A2, A3
  final List<Exercise> exercises;
  final bool isExpanded;

  WorkoutBlock({
    required this.name,
    required this.exercises,
    this.isExpanded = false,
  });

  factory WorkoutBlock.fromMap(Map<String, dynamic> map) {
    return WorkoutBlock(
      name: map['name'] ?? '',
      exercises: (map['exercises'] as List?)
          ?.map((e) => Exercise.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
      isExpanded: map['isExpanded'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'isExpanded': isExpanded,
    };
  }

  WorkoutBlock copyWith({
    String? name,
    List<Exercise>? exercises,
    bool? isExpanded,
  }) {
    return WorkoutBlock(
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

/// Día de entrenamiento (Lunes - Pecho y Tríceps)
class WorkoutDay {
  final String id;
  final String title; // Lunes - Pecho y Tríceps
  final List<WorkoutBlock> blocks;

  WorkoutDay({
    required this.id,
    required this.title,
    required this.blocks,
  });

  factory WorkoutDay.fromMap(String id, Map<String, dynamic> map) {
    return WorkoutDay(
      id: id,
      title: map['title'] ?? '',
      blocks: (map['blocks'] as List?)
          ?.map((e) => WorkoutBlock.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'blocks': blocks.map((b) => b.toMap()).toList(),
    };
  }
}

// lib/models/planning_model.dart

/// Planificación semanal
class WeeklyPlanning {
  final String objective; // Pérdida de grasa, Ganancia muscular, etc.
  final String notes; // Notas de la semana
  final DateTime lastUpdate;

  WeeklyPlanning({
    required this.objective,
    required this.notes,
    required this.lastUpdate,
  });

  factory WeeklyPlanning.fromMap(Map<String, dynamic> map) {
    return WeeklyPlanning(
      objective: map['objective'] ?? '',
      notes: map['notes'] ?? '',
      lastUpdate: (map['lastUpdate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'objective': objective,
      'notes': notes,
      'lastUpdate': Timestamp.fromDate(lastUpdate),
    };
  }
}

// lib/models/supplement_model.dart

/// Suplemento recomendado
class Supplement {
  final String id;
  final String name; // Creatina
  final String reason; // Mejora el rendimiento...
  final String usage; // 5g diarios, post-entreno

  Supplement({
    required this.id,
    required this.name,
    required this.reason,
    required this.usage,
  });

  factory Supplement.fromMap(String id, Map<String, dynamic> map) {
    return Supplement(
      id: id,
      name: map['name'] ?? '',
      reason: map['reason'] ?? '',
      usage: map['usage'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'reason': reason,
      'usage': usage,
    };
  }
}

// lib/models/diet_model.dart

/// Macronutrientes diarios
class DailyMacros {
  final int carbs;
  final int proteins;
  final int fats;

  DailyMacros({
    required this.carbs,
    required this.proteins,
    required this.fats,
  });

  int get totalCalories {
    return (carbs * 4) + (proteins * 4) + (fats * 9);
  }

  factory DailyMacros.fromMap(Map<String, dynamic> map) {
    return DailyMacros(
      carbs: map['carbs'] ?? 0,
      proteins: map['proteins'] ?? 0,
      fats: map['fats'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'carbs': carbs,
      'proteins': proteins,
      'fats': fats,
    };
  }
}

/// Alimento individual
class FoodItem {
  final String name; // Arroz blanco (80g)
  final int carbs;
  final int proteins;
  final int fats;

  FoodItem({
    required this.name,
    required this.carbs,
    required this.proteins,
    required this.fats,
  });

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      name: map['name'] ?? '',
      carbs: map['carbs'] ?? 0,
      proteins: map['proteins'] ?? 0,
      fats: map['fats'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'carbs': carbs,
      'proteins': proteins,
      'fats': fats,
    };
  }

  String get macrosText => 'CH: ${carbs}g | P: ${proteins}g | G: ${fats}g';
}

/// Plan de dieta completo
class DietPlan {
  final String generalNotes;
  final DailyMacros macros;
  final List<String> requiredFoods; // Alimentos que deben estar presentes
  final Map<String, List<FoodItem>> foodExchanges; // Hidratos, Proteínas, Grasas

  DietPlan({
    required this.generalNotes,
    required this.macros,
    required this.requiredFoods,
    required this.foodExchanges,
  });

  factory DietPlan.fromMap(Map<String, dynamic> map) {
    final exchanges = <String, List<FoodItem>>{};
    
    (map['foodExchanges'] as Map<String, dynamic>?)?.forEach((key, value) {
      exchanges[key] = (value as List)
          .map((e) => FoodItem.fromMap(e as Map<String, dynamic>))
          .toList();
    });

    return DietPlan(
      generalNotes: map['generalNotes'] ?? '',
      macros: DailyMacros.fromMap(map['macros'] ?? {}),
      requiredFoods: List<String>.from(map['requiredFoods'] ?? []),
      foodExchanges: exchanges,
    );
  }

  Map<String, dynamic> toMap() {
    final exchanges = <String, dynamic>{};
    foodExchanges.forEach((key, value) {
      exchanges[key] = value.map((e) => e.toMap()).toList();
    });

    return {
      'generalNotes': generalNotes,
      'macros': macros.toMap(),
      'requiredFoods': requiredFoods,
      'foodExchanges': exchanges,
    };
  }
}