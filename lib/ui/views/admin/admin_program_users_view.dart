import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../app/theme/colors.dart';
import '../../../models/models.dart';

class AdminProgramUsersView extends StatefulWidget {
  final String userId;

  const AdminProgramUsersView({super.key, required this.userId});

  @override
  State<AdminProgramUsersView> createState() => _AdminProgramUsersViewState();
}

class _AdminProgramUsersViewState extends State<AdminProgramUsersView> {
  final TextEditingController _programNameCtrl = TextEditingController();
  final List<ProgramExercise> _exercises = [];

  @override
  void dispose() {
    _programNameCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────
  // CREAR PROGRAMA
  // ─────────────────────────────────────
  void _openCreateProgramDialog() {
    // Limpiar estado anterior
    _programNameCtrl.clear();
    _exercises.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('Crear programa'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _programNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del bloque',
                        hintText: 'Ej: Bloque 1 - Hipertrofia',
                      ),
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      onPressed: () => _openAddExerciseDialog(setDialogState),
                      icon: const Icon(Icons.add),
                      label: const Text('Añadir ejercicio'),
                    ),

                    const SizedBox(height: 12),

                    if (_exercises.isEmpty)
                      const Text(
                        'No hay ejercicios añadidos',
                        style: TextStyle(color: AppColors.textSecondary),
                      )
                    else
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: _exercises.length,
                          itemBuilder: (_, index) {
                            final e = _exercises[index];
                            return ListTile(
                              title: Text(e.name),
                              subtitle: Text(e.displayFormat),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setDialogState(() {
                                    _exercises.removeAt(index);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _programNameCtrl.clear();
                    _exercises.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: _exercises.isEmpty ? null : _saveProgram,
                  child: const Text('Guardar programa'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────
  // AÑADIR EJERCICIO
  // ─────────────────────────────────────
  void _openAddExerciseDialog(StateSetter setDialogState) {
    final nameCtrl = TextEditingController();
    final setsCtrl = TextEditingController();
    final repsCtrl = TextEditingController();
    final rpeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Añadir ejercicio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Ejercicio',
                    hintText: 'Ej: Press banca',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: setsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Series',
                    hintText: 'Ej: 4',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: repsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Repeticiones',
                    hintText: 'Ej: 8-12 o 10',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: rpeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'RPE (opcional)',
                    hintText: 'Ej: 8',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final sets = int.tryParse(setsCtrl.text.trim());
                final reps = repsCtrl.text.trim();
                final rpe = int.tryParse(rpeCtrl.text.trim());

                // Validaciones
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('El nombre del ejercicio es obligatorio'),
                    ),
                  );
                  return;
                }

                if (sets == null || sets <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Las series deben ser un número válido mayor a 0'),
                    ),
                  );
                  return;
                }

                if (reps.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Las repeticiones son obligatorias'),
                    ),
                  );
                  return;
                }

                final exercise = ProgramExercise(
                  order: _exercises.length + 1,
                  name: name,
                  sets: sets,
                  reps: reps,
                  rpe: rpe,
                );

                debugPrint(
                  'Ejercicio añadido: ${exercise.name}, Series: ${exercise.sets}, Reps: ${exercise.reps}, RPE: ${exercise.rpe}',
                );

                setDialogState(() {
                  _exercises.add(exercise);
                });

                Navigator.pop(context);
              },
              child: const Text('Añadir'),
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────
  // GUARDAR PROGRAMA EN FIRESTORE
  // ─────────────────────────────────────
  Future<void> _saveProgram() async {
    try {
      debugPrint('🔥 _saveProgram EJECUTADO');

      final programsRef = FirebaseFirestore.instance.collection('program');

      // Buscar programa activo actual
      final activeQuery = await programsRef
          .where('id_user', isEqualTo: widget.userId)
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      int nextBlock = 1;

      // Si existe un programa activo, desactivarlo
      if (activeQuery.docs.isNotEmpty) {
        final activeDoc = activeQuery.docs.first;
        nextBlock = (activeDoc['block_number'] as int) + 1;

        await activeDoc.reference.update({
          'active': false,
          'finished_at': Timestamp.now(),
        });

        debugPrint('✅ Programa anterior desactivado: Bloque ${activeDoc['block_number']}');
      }

      // Nombre del programa
      final programName = _programNameCtrl.text.trim().isNotEmpty
          ? _programNameCtrl.text.trim()
          : 'Bloque $nextBlock';

      debugPrint('💾 Guardando programa: $programName');
      debugPrint('📋 Ejercicios (${_exercises.length}):');
      for (var exercise in _exercises) {
        debugPrint(
          '  ${exercise.order}. ${exercise.name}: ${exercise.sets} series, ${exercise.reps} reps${exercise.rpe != null ? ", RPE: ${exercise.rpe}" : ""}',
        );
      }

      // Crear nuevo programa
      final newProgram = ProgramModel(
        id: '',
        userId: widget.userId,
        name: programName,
        blockNumber: nextBlock,
        active: true,
        createdAt: DateTime.now(),
        exercises: _exercises,
      );

      await programsRef.add(newProgram.toFirestore());

      debugPrint('✅ Programa guardado exitosamente');

      // Limpiar y cerrar
      _programNameCtrl.clear();
      _exercises.clear();

      if (mounted) {
        Navigator.pop(context);
        
        // Mostrar confirmación
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Programa "$programName" creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error al guardar programa: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          const Text(
            'Programas de Entrenamiento',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('program')
                  .where('id_user', isEqualTo: widget.userId)
                  .where('active', isEqualTo: true)
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _EmptyProgramState(onCreate: _openCreateProgramDialog);
                }

                final program = ProgramModel.fromFirestore(
                  snapshot.data!.docs.first,
                );

                return _ActiveProgramCard(
                  program: program,
                  onCreateNew: _openCreateProgramDialog,
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
/// ESTADO: SIN PROGRAMA ACTIVO
/// =================================================
class _EmptyProgramState extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyProgramState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Este usuario no tiene un programa activo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Crea un nuevo bloque de entrenamiento',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Crear programa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bluePrimary,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// =================================================
/// TARJETA: PROGRAMA ACTIVO
/// =================================================
class _ActiveProgramCard extends StatelessWidget {
  final ProgramModel program;
  final VoidCallback onCreateNew;

  const _ActiveProgramCard({
    required this.program,
    required this.onCreateNew,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Botón para crear nuevo programa
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: onCreateNew,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Nuevo programa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bluePrimary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Tarjeta del programa activo
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
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
                    Expanded(
                      child: Text(
                        program.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.tagWorkout,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'ACTIVO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.bluePrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Bloque ${program.blockNumber} • ${program.totalExercises} ejercicios',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: ListView.separated(
                    itemCount: program.exercises.length,
                    separatorBuilder: (_, __) => const Divider(height: 24),
                    itemBuilder: (context, index) {
                      final e = program.exercises[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.bluePrimary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${e.order}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppColors.bluePrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  e.displayFormat,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}