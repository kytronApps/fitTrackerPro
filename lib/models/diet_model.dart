import 'package:cloud_firestore/cloud_firestore.dart';

/// ======================================
/// 🍎 ALIMENTO (de la lista maestra)
/// ======================================
class FoodItem {
  final String id;
  final String name;
  final String category; // "HIDRATOS DE CARBONO", "PROTEINAS", "GRASAS", "1/2 PROTEINA"
  final String? details;
  final DateTime createdAt;

  FoodItem({
    required this.id,
    required this.name,
    required this.category,
    this.details,
    required this.createdAt,
  });

  factory FoodItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return FoodItem(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      details: data['details'],
      createdAt: _parseDate(data['created_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      if (details != null) 'details': details,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    return null;
  }
}

/// ======================================
/// 🍽️ ENTRADA DE DIETA DEL USUARIO
/// ======================================
class DietEntry {
  final String id;
  final String userId;
  final DateTime date;
  final String mealType; // "Desayuno", "Comida", "Cena", "Snack"
  final List<DietFood> foods;
  final String? notes;
  final DateTime createdAt;

  DietEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.mealType,
    required this.foods,
    this.notes,
    required this.createdAt,
  });

  factory DietEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return DietEntry(
      id: doc.id,
      userId: data['id_user'] ?? '',
      date: _parseDate(data['date']) ?? DateTime.now(),
      mealType: data['meal_type'] ?? '',
      foods: (data['foods'] as List<dynamic>? ?? [])
          .map((e) => DietFood.fromMap(e as Map<String, dynamic>))
          .toList(),
      notes: data['notes'],
      createdAt: _parseDate(data['created_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id_user': userId,
      'date': Timestamp.fromDate(date),
      'meal_type': mealType,
      'foods': foods.map((f) => f.toMap()).toList(),
      if (notes != null) 'notes': notes,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    return null;
  }
}

/// ======================================
/// 🥗 ALIMENTO EN LA DIETA
/// ======================================
class DietFood {
  final String foodName;
  final String category;
  final String? quantity;

  DietFood({
    required this.foodName,
    required this.category,
    this.quantity,
  });

  factory DietFood.fromMap(Map<String, dynamic> map) {
    return DietFood(
      foodName: map['food_name'] ?? '',
      category: map['category'] ?? '',
      quantity: map['quantity'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'food_name': foodName,
      'category': category,
      if (quantity != null) 'quantity': quantity,
    };
  }
}