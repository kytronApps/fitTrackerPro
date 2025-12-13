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
  final bool archived; // NUEVO: Para archivar cuestionarios
  
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
  final int tiredness; // ¿Cómo de cansado te sientes? (1-10)
  final int motivation; // ¿Cuánta motivación tienes al entrenar? (1-10)
  final int dietCompliance; // ¿Qué cumplimiento haces de la dieta? (1-10)
  final int recovery; // ¿Cómo de recuperado te sientes entre sesiones? (1-10)
  final String recoveryNotes; // Si no recuperado, ¿a qué crees que se debe?
  final String sleepHours; // ¿Cuántas horas has dormido de media?
  final String importantNotes; // Notas importantes
  
  // Medidas antropométricas (proporcionadas por el usuario)
  final double? bodyWeight; // peso_corporal en kg
  final double? waist; // cintura en cm
  final double? hips; // cadera en cm
  final double? chest; // pecho en cm
  final double? thigh; // muslo en cm
  final String? adminNotes; // Notas del administrador sobre las medidas

  WeeklyQuestionnaire({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.weekDate,
    required this.createdAt,
    required this.reviewed,
    this.archived = false, // Por defecto no archivado
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
      archived: data['archived'] ?? false, // NUEVO
      pectoral: data['pectoral'] ?? 0,
      dorsal: data['dorsal'] ?? 0,
      deltoidAnterior: data['deltoidAnterior'] ?? 0,
      deltoidLateral: data['deltoidLateral'] ?? 0,
      deltoidPosterior: data['deltoidPosterior'] ?? 0,
      quadriceps: data['quadriceps'] ?? 0,
      adductors: data['adductors'] ?? 0,
      hamstrings: data['hamstrings'] ?? 0,
      glutes: data['glutes'] ?? 0,
      biceps: data['biceps'] ?? 0,
      triceps: data['triceps'] ?? 0,
      lumbar: data['lumbar'] ?? 0,
      tiredness: data['tiredness'] ?? 0,
      motivation: data['motivation'] ?? 0,
      dietCompliance: data['dietCompliance'] ?? 0,
      recovery: data['recovery'] ?? 0,
      recoveryNotes: data['recoveryNotes'] ?? '',
      sleepHours: data['sleepHours'] ?? '',
      importantNotes: data['importantNotes'] ?? '',
      bodyWeight: data['peso_corporal']?.toDouble(),
      waist: data['cintura']?.toDouble(),
      hips: data['cadera']?.toDouble(),
      chest: data['pecho']?.toDouble(),
      thigh: data['muslo']?.toDouble(),
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
      'archived': archived, // NUEVO
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
      if (bodyWeight != null) 'peso_corporal': bodyWeight,
      if (waist != null) 'cintura': waist,
      if (hips != null) 'cadera': hips,
      if (chest != null) 'pecho': chest,
      if (thigh != null) 'muslo': thigh,
      if (adminNotes != null) 'adminNotes': adminNotes,
    };
  }

  // Promedio de agujetas
  double get averageSoreness {
    final total = pectoral + dorsal + deltoidAnterior + deltoidLateral +
        deltoidPosterior + quadriceps + adductors + hamstrings +
        glutes + biceps + triceps + lumbar;
    return total / 12;
  }

  // Obtener inicial del nombre
  String get initial => userName.isNotEmpty ? userName[0].toUpperCase() : '?';

  // Formatear fecha
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

  // Tiempo desde creación
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
    bool? archived, // NUEVO
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
      archived: archived ?? this.archived, // NUEVO
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