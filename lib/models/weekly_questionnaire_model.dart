// lib/models/weekly_questionnaire_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklyQuestionnaire {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String weekDate; // "2024-11-25"
  final DateTime createdAt;
  final bool reviewed;
  final bool archived;
  
  // Agujetas (1-10) por grupo muscular
  final int pectoral;
  final int dorsal;
  final int deltoidAnterior;
  final int deltoidLateral;
  final int deltoidPosterior;
  final int quadriceps;
  final int adductors;
  final int hamstrings;
  final int glutes;
  final int biceps;
  final int triceps;
  final int lumbar;
  
  // Preguntas generales
  final int tiredness;
  final int motivation;
  final int dietCompliance;
  final int recovery;
  final String recoveryNotes;
  final String sleepHours;
  final String importantNotes;
  
  // Medidas antropométricas
  final double? bodyWeight;
  final double? waist;
  final double? hips;
  final double? chest;
  final double? thigh;
  final String? adminNotes;

  WeeklyQuestionnaire({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.weekDate,
    required this.createdAt,
    required this.reviewed,
    this.archived = false,
    required this.pectoral,
    required this.dorsal,
    required this.deltoidAnterior,
    required this.deltoidLateral,
    required this.deltoidPosterior,
    required this.quadriceps,
    required this.adductors,
    required this.hamstrings,
    required this.glutes,
    required this.biceps,
    required this.triceps,
    required this.lumbar,
    required this.tiredness,
    required this.motivation,
    required this.dietCompliance,
    required this.recovery,
    required this.recoveryNotes,
    required this.sleepHours,
    required this.importantNotes,
    this.bodyWeight,
    this.waist,
    this.hips,
    this.chest,
    this.thigh,
    this.adminNotes,
  });

  // ========================================
  // MÉTODOS AUXILIARES PARA CONVERSIÓN SEGURA
  // ========================================
  
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    
    // Si ya es double, retornar directamente
    if (value is double) return value;
    
    // Si es int, convertir a double
    if (value is int) return value.toDouble();
    
    // Si es String, intentar parsear
    if (value is String) {
      try {
        return double.parse(value.trim());
      } catch (e) {
        print('⚠️ Error parseando double desde String: "$value" - $e');
        return null;
      }
    }
    
    print('⚠️ Tipo no soportado para conversión a double: ${value.runtimeType}');
    return null;
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    
    // Si ya es int, retornar directamente
    if (value is int) return value;
    
    // Si es double, convertir a int
    if (value is double) return value.toInt();
    
    // Si es String, intentar parsear
    if (value is String) {
      try {
        return int.parse(value.trim());
      } catch (e) {
        // Si no puede parsear como int, intentar como double primero
        try {
          return double.parse(value.trim()).toInt();
        } catch (e2) {
          print('⚠️ Error parseando int desde String: "$value" - $e');
          return defaultValue;
        }
      }
    }
    
    print('⚠️ Tipo no soportado para conversión a int: ${value.runtimeType}');
    return defaultValue;
  }

  // ========================================
  // FACTORY CONSTRUCTOR
  // ========================================

  factory WeeklyQuestionnaire.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return WeeklyQuestionnaire(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Usuario desconocido',
      userEmail: data['userEmail'] ?? '',
      weekDate: data['weekDate'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reviewed: data['reviewed'] ?? false,
      archived: data['archived'] ?? false,
      
      // Agujetas - usar _parseInt para manejar cualquier tipo
      pectoral: _parseInt(data['pectoral']),
      dorsal: _parseInt(data['dorsal']),
      deltoidAnterior: _parseInt(data['deltoidAnterior']),
      deltoidLateral: _parseInt(data['deltoidLateral']),
      deltoidPosterior: _parseInt(data['deltoidPosterior']),
      quadriceps: _parseInt(data['quadriceps']),
      adductors: _parseInt(data['adductors']),
      hamstrings: _parseInt(data['hamstrings']),
      glutes: _parseInt(data['glutes']),
      biceps: _parseInt(data['biceps']),
      triceps: _parseInt(data['triceps']),
      lumbar: _parseInt(data['lumbar']),
      
      // Preguntas generales
      tiredness: _parseInt(data['tiredness']),
      motivation: _parseInt(data['motivation']),
      dietCompliance: _parseInt(data['dietCompliance']),
      recovery: _parseInt(data['recovery']),
      recoveryNotes: data['recoveryNotes'] ?? '',
      sleepHours: data['sleepHours'] ?? '',
      importantNotes: data['importantNotes'] ?? '',
      
      // Medidas antropométricas - USAR _parseDouble
      bodyWeight: _parseDouble(data['peso_corporal']),
      waist: _parseDouble(data['cintura']),
      hips: _parseDouble(data['cadera']),
      chest: _parseDouble(data['pecho']),
      thigh: _parseDouble(data['muslo']),
      
      adminNotes: data['adminNotes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'weekDate': weekDate,
      'createdAt': Timestamp.fromDate(createdAt),
      'reviewed': reviewed,
      'archived': archived,
      'pectoral': pectoral,
      'dorsal': dorsal,
      'deltoidAnterior': deltoidAnterior,
      'deltoidLateral': deltoidLateral,
      'deltoidPosterior': deltoidPosterior,
      'quadriceps': quadriceps,
      'adductors': adductors,
      'hamstrings': hamstrings,
      'glutes': glutes,
      'biceps': biceps,
      'triceps': triceps,
      'lumbar': lumbar,
      'tiredness': tiredness,
      'motivation': motivation,
      'dietCompliance': dietCompliance,
      'recovery': recovery,
      'recoveryNotes': recoveryNotes,
      'sleepHours': sleepHours,
      'importantNotes': importantNotes,
      // Guardar medidas como double (números, no strings)
      if (bodyWeight != null) 'peso_corporal': bodyWeight,
      if (waist != null) 'cintura': waist,
      if (hips != null) 'cadera': hips,
      if (chest != null) 'pecho': chest,
      if (thigh != null) 'muslo': thigh,
      if (adminNotes != null) 'adminNotes': adminNotes,
    };
  }

  // ========================================
  // GETTERS Y UTILIDADES
  // ========================================

  double get averageSoreness {
    final total = pectoral + dorsal + deltoidAnterior + deltoidLateral +
        deltoidPosterior + quadriceps + adductors + hamstrings +
        glutes + biceps + triceps + lumbar;
    return total / 12;
  }

  String get initial => userName.isNotEmpty ? userName[0].toUpperCase() : '?';

  String get formattedWeekDate {
    try {
      final parts = weekDate.split('-');
      if (parts.length == 3) {
        return 'Semana del ${parts[2]}/${parts[1]}/${parts[0]}';
      }
      return weekDate;
    } catch (e) {
      return weekDate;
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  WeeklyQuestionnaire copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? weekDate,
    DateTime? createdAt,
    bool? reviewed,
    bool? archived,
    int? pectoral,
    int? dorsal,
    int? deltoidAnterior,
    int? deltoidLateral,
    int? deltoidPosterior,
    int? quadriceps,
    int? adductors,
    int? hamstrings,
    int? glutes,
    int? biceps,
    int? triceps,
    int? lumbar,
    int? tiredness,
    int? motivation,
    int? dietCompliance,
    int? recovery,
    String? recoveryNotes,
    String? sleepHours,
    String? importantNotes,
    double? bodyWeight,
    double? waist,
    double? hips,
    double? chest,
    double? thigh,
    String? adminNotes,
  }) {
    return WeeklyQuestionnaire(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      weekDate: weekDate ?? this.weekDate,
      createdAt: createdAt ?? this.createdAt,
      reviewed: reviewed ?? this.reviewed,
      archived: archived ?? this.archived,
      pectoral: pectoral ?? this.pectoral,
      dorsal: dorsal ?? this.dorsal,
      deltoidAnterior: deltoidAnterior ?? this.deltoidAnterior,
      deltoidLateral: deltoidLateral ?? this.deltoidLateral,
      deltoidPosterior: deltoidPosterior ?? this.deltoidPosterior,
      quadriceps: quadriceps ?? this.quadriceps,
      adductors: adductors ?? this.adductors,
      hamstrings: hamstrings ?? this.hamstrings,
      glutes: glutes ?? this.glutes,
      biceps: biceps ?? this.biceps,
      triceps: triceps ?? this.triceps,
      lumbar: lumbar ?? this.lumbar,
      tiredness: tiredness ?? this.tiredness,
      motivation: motivation ?? this.motivation,
      dietCompliance: dietCompliance ?? this.dietCompliance,
      recovery: recovery ?? this.recovery,
      recoveryNotes: recoveryNotes ?? this.recoveryNotes,
      sleepHours: sleepHours ?? this.sleepHours,
      importantNotes: importantNotes ?? this.importantNotes,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      waist: waist ?? this.waist,
      hips: hips ?? this.hips,
      chest: chest ?? this.chest,
      thigh: thigh ?? this.thigh,
      adminNotes: adminNotes ?? this.adminNotes,
    );
  }
}