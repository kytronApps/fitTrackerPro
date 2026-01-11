import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

import '../../../app/theme/colors.dart';
import '../../../models/models.dart';

class DietUsersView extends StatefulWidget {
  final String userId;

  const DietUsersView({super.key, required this.userId});

  @override
  State<DietUsersView> createState() => _DietUsersViewState();
}

class _DietUsersViewState extends State<DietUsersView> {
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Todos';

  // ─────────────────────────────────────
  // SUBIR EXCEL CON LISTA DE ALIMENTOS
  // ─────────────────────────────────────
  Future<void> _uploadFoodListFromExcel() async {
    BuildContext? dialogContext;
    
    try {
      FilePickerResult? result;
      
      try {
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['xlsx', 'xls'],
          withData: true,
          allowMultiple: false,
        );
      } catch (pickerError) {
        debugPrint('Error con FilePicker.platform: $pickerError');
        result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          withData: true,
          allowMultiple: false,
        );
      }

      if (result == null || result.files.isEmpty) return;

      final bytes = result.files.first.bytes;
      if (bytes == null) {
        throw Exception('No se pudo leer el archivo');
      }

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            dialogContext = ctx;
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );
      }

      await Future.delayed(const Duration(milliseconds: 100));

      late Excel excel;
      
      try {
        excel = Excel.decodeBytes(List<int>.from(bytes));
      } catch (e1) {
        debugPrint('Error con List<int>, intentando con bytes directos: $e1');
        try {
          excel = Excel.decodeBytes(bytes);
        } catch (e2) {
          debugPrint('Error con bytes directos: $e2');
          throw Exception('No se pudo leer el formato del archivo Excel');
        }
      }
      
      if (excel.tables.isEmpty) {
        throw Exception('El archivo Excel está vacío o no tiene hojas');
      }
      
      final tableName = excel.tables.keys.first;
      final sheet = excel.tables[tableName];

      if (sheet == null || sheet.rows.isEmpty) {
        throw Exception('La hoja de cálculo está vacía');
      }

      final batch = FirebaseFirestore.instance.batch();
      final foodsRef = FirebaseFirestore.instance.collection('food_list');

      int addedCount = 0;

      for (int i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];
        
        try {
          if (row.length > 0 && row[0] != null && row[0]!.value != null) {
            final value = row[0]!.value.toString().trim();
            if (value.isNotEmpty && 
                !value.toUpperCase().contains('HIDRATOS') &&
                !value.toUpperCase().contains('CARBONO')) {
              final docRef = foodsRef.doc();
              batch.set(docRef, {
                'name': value,
                'category': 'HIDRATOS DE CARBONO',
                'created_at': FieldValue.serverTimestamp(),
              });
              addedCount++;
            }
          }

          if (row.length > 1 && row[1] != null && row[1]!.value != null) {
            final value = row[1]!.value.toString().trim();
            if (value.isNotEmpty && !value.toUpperCase().contains('PROTEINA')) {
              final docRef = foodsRef.doc();
              batch.set(docRef, {
                'name': value,
                'category': 'PROTEINAS',
                'created_at': FieldValue.serverTimestamp(),
              });
              addedCount++;
            }
          }

          if (row.length > 2 && row[2] != null && row[2]!.value != null) {
            final value = row[2]!.value.toString().trim();
            if (value.isNotEmpty && !value.toUpperCase().contains('GRASAS')) {
              final docRef = foodsRef.doc();
              batch.set(docRef, {
                'name': value,
                'category': 'GRASAS',
                'created_at': FieldValue.serverTimestamp(),
              });
              addedCount++;
            }
          }

          if (row.length > 3 && row[3] != null && row[3]!.value != null) {
            final value = row[3]!.value.toString().trim();
            if (value.isNotEmpty && 
                !value.contains('1/2') && 
                !value.toUpperCase().contains('PROTEINA')) {
              final docRef = foodsRef.doc();
              batch.set(docRef, {
                'name': value,
                'category': '1/2 PROTEINA',
                'created_at': FieldValue.serverTimestamp(),
              });
              addedCount++;
            }
          }
        } catch (rowError) {
          debugPrint('Error procesando fila $i: $rowError');
        }
      }

      if (addedCount > 0) {
        await batch.commit();
      }

      if (dialogContext != null && mounted) {
        Navigator.of(dialogContext!).pop();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              addedCount > 0 
                ? '✅ $addedCount alimentos importados correctamente'
                : 'ℹ️ No se encontraron alimentos para importar'
            ),
            backgroundColor: addedCount > 0 ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error detallado al importar Excel: $e');
      debugPrint('Stack trace: $stackTrace');
      
      if (dialogContext != null && mounted) {
        try {
          Navigator.of(dialogContext!).pop();
        } catch (_) {}
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al importar: ${e.toString().split(':').last}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────
  // MOSTRAR CONSIDERACIONES
  // ─────────────────────────────────────
  void _showDietConsiderations() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: const [
              Icon(Icons.info_outline, color: AppColors.bluePrimary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Consideraciones Generales',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildConsiderationItem('📏', 'Todo se pesa en crudo y en seco'),
                _buildConsiderationItem('🥬', 'Los intercambios en lila son veganos'),
                _buildConsiderationItem('🫒', 'Prioriza aceite de oliva virgen extra'),
                _buildConsiderationItem('🥗', 'Añade verduras sin contabilizarlas'),
                _buildConsiderationItem('🧂', 'Usa especias, evita la sal'),
                _buildConsiderationItem('💧', 'Prioriza el agua'),
                const SizedBox(height: 16),
                const Text(
                  'ALIMENTOS SEMANALES RECOMENDADOS:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.bluePrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Legumbres: lentejas, garbanzos\n'
                  '• Frutos secos: almendras, nueces\n'
                  '• Cereales integrales: arroz, pasta\n'
                  '• Fruta variada\n'
                  '• Aguacate\n'
                  '• Semillas: lino, chía',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConsiderationItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────
  // VER LISTA DE ALIMENTOS
  // ─────────────────────────────────────
  void _showFoodList() {
    showDialog(
      context: context,
      builder: (context) => _FoodListDialog(
        userId: widget.userId,
        onFoodSelected: (food) {
          // Aquí podrías hacer algo cuando seleccionen un alimento
          Navigator.pop(context);
        },
      ),
    );
  }

  // ─────────────────────────────────────
  // UI
  // ─────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con botones
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: _showDietConsiderations,
                icon: const Icon(Icons.info_outline),
                color: AppColors.bluePrimary,
                tooltip: 'Consideraciones',
              ),
              IconButton(
                onPressed: _showFoodList,
                icon: const Icon(Icons.restaurant_menu),
                color: AppColors.bluePrimary,
                tooltip: 'Ver lista de alimentos',
              ),
              IconButton(
                onPressed: _uploadFoodListFromExcel,
                icon: const Icon(Icons.upload_file),
                color: AppColors.bluePrimary,
                tooltip: 'Subir Excel',
              ),
            ],
          ),

          // Lista de comidas
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('dieta')
                  .where('id_user', isEqualTo: widget.userId)
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text('Error al cargar datos'),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const _EmptyDietState();
                }

                final allEntries = snapshot.data!.docs
                    .map((doc) => DietEntry.fromFirestore(doc))
                    .toList();

                final startOfDay = DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                );
                final endOfDay = startOfDay.add(const Duration(days: 1));

                final entriesForSelectedDate = allEntries.where((entry) {
                  return entry.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
                         entry.date.isBefore(endOfDay);
                }).toList();

                if (entriesForSelectedDate.isEmpty) {
                  return const _EmptyDietState();
                }

                return ListView.builder(
                  itemCount: entriesForSelectedDate.length,
                  itemBuilder: (context, index) {
                    return _DietEntryCard(entry: entriesForSelectedDate[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// =================================================
/// DIÁLOGO DE LISTA DE ALIMENTOS
/// =================================================
class _FoodListDialog extends StatefulWidget {
  final String userId;
  final Function(FoodItem) onFoodSelected;

  const _FoodListDialog({
    required this.userId,
    required this.onFoodSelected,
  });

  @override
  State<_FoodListDialog> createState() => _FoodListDialogState();
}

class _FoodListDialogState extends State<_FoodListDialog> {
  String _selectedCategory = 'Todos';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _categories = [
    'Todos',
    'HIDRATOS DE CARBONO',
    'PROTEINAS',
    'GRASAS',
    '1/2 PROTEINA',
  ];

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'HIDRATOS DE CARBONO':
        return Colors.orange;
      case 'PROTEINAS':
        return Colors.red;
      case 'GRASAS':
        return Colors.blue;
      case '1/2 PROTEINA':
        return Colors.purple;
      default:
        return AppColors.bluePrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.restaurant_menu, color: AppColors.bluePrimary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Lista de Alimentos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Búsqueda
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar alimento...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 16),

            // Filtros por categoría
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category : 'Todos';
                        });
                      },
                      backgroundColor: AppColors.background,
                      selectedColor: _getCategoryColor(category).withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? _getCategoryColor(category) : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Lista de alimentos
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('food_list')
                    .orderBy('category')
                    .orderBy('name')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant,
                            size: 60,
                            color: AppColors.textSecondary.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          const Text('No hay alimentos en la lista'),
                          const SizedBox(height: 8),
                          const Text(
                            'Sube un archivo Excel para importar',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  var foods = snapshot.data!.docs
                      .map((doc) => FoodItem.fromFirestore(doc))
                      .toList();

                  // Filtrar por categoría
                  if (_selectedCategory != 'Todos') {
                    foods = foods
                        .where((f) => f.category == _selectedCategory)
                        .toList();
                  }

                  // Filtrar por búsqueda
                  if (_searchQuery.isNotEmpty) {
                    foods = foods
                        .where((f) => f.name.toLowerCase().contains(_searchQuery))
                        .toList();
                  }

                  if (foods.isEmpty) {
                    return const Center(
                      child: Text('No se encontraron alimentos'),
                    );
                  }

                  // Agrupar por categoría
                  final groupedFoods = <String, List<FoodItem>>{};
                  for (var food in foods) {
                    groupedFoods.putIfAbsent(food.category, () => []).add(food);
                  }

                  return ListView.builder(
                    itemCount: groupedFoods.length,
                    itemBuilder: (context, index) {
                      final category = groupedFoods.keys.elementAt(index);
                      final categoryFoods = groupedFoods[category]!;
                      final color = _getCategoryColor(category);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header de categoría
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${categoryFoods.length}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: color,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Lista de alimentos de esta categoría
                          ...categoryFoods.map((food) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                
                              ),
                              child: ListTile(
                                dense: true,
                                leading: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                title: Text(
                                  food.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                onTap: () => widget.onFoodSelected(food),
                              ),
                            );
                          }),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =================================================
/// ESTADO VACÍO
/// =================================================
class _EmptyDietState extends StatelessWidget {
  const _EmptyDietState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sin registro de dieta',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No hay comidas registradas',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// =================================================
/// TARJETA DE ENTRADA DE DIETA
/// =================================================
class _DietEntryCard extends StatelessWidget {
  final DietEntry entry;

  const _DietEntryCard({required this.entry});

  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'desayuno':
        return Icons.free_breakfast;
      case 'comida':
        return Icons.lunch_dining;
      case 'cena':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }

  Color _getMealColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'desayuno':
        return Colors.orange;
      case 'comida':
        return Colors.green;
      case 'cena':
        return Colors.purple;
      case 'snack':
        return Colors.blue;
      default:
        return AppColors.bluePrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getMealColor(entry.mealType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getMealIcon(entry.mealType), color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entry.mealType,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                DateFormat('HH:mm').format(entry.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          ...entry.foods.map((food) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          food.foodName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (food.quantity != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            food.quantity!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      food.category,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          if (entry.notes != null && entry.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.note, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.notes!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}