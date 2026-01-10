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
  // AÑADIR EJERCICIO (para crear programa)
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

      final activeQuery = await programsRef
          .where('id_user', isEqualTo: widget.userId)
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      int nextBlock = 1;

      if (activeQuery.docs.isNotEmpty) {
        final activeDoc = activeQuery.docs.first;
        nextBlock = (activeDoc['block_number'] as int) + 1;

        await activeDoc.reference.update({
          'active': false,
          'finished_at': Timestamp.now(),
        });
      }

      final programName = _programNameCtrl.text.trim().isNotEmpty
          ? _programNameCtrl.text.trim()
          : 'Bloque $nextBlock';

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

      _programNameCtrl.clear();
      _exercises.clear();

      if (mounted) {
        Navigator.pop(context);
        
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
  // AÑADIR EJERCICIO A PROGRAMA EXISTENTE
  // ─────────────────────────────────────
  Future<void> _addExerciseToProgram(String programId, List<ProgramExercise> currentExercises) async {
    final nameCtrl = TextEditingController();
    final setsCtrl = TextEditingController();
    final repsCtrl = TextEditingController();
    final rpeCtrl = TextEditingController();

    final result = await showDialog<ProgramExercise>(
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

                if (name.isEmpty || sets == null || sets <= 0 || reps.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor completa todos los campos'),
                    ),
                  );
                  return;
                }

                final exercise = ProgramExercise(
                  order: currentExercises.length + 1,
                  name: name,
                  sets: sets,
                  reps: reps,
                  rpe: rpe,
                );

                Navigator.pop(context, exercise);
              },
              child: const Text('Añadir'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      try {
        final updatedExercises = [...currentExercises, result];
        
        await FirebaseFirestore.instance
            .collection('program')
            .doc(programId)
            .update({
          'exercises': updatedExercises.map((e) => e.toMap()).toList(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ejercicio añadido correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al añadir ejercicio: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // ─────────────────────────────────────
  // EDITAR EJERCICIO
  // ─────────────────────────────────────
  Future<void> _editExercise(String programId, int index, ProgramExercise exercise, List<ProgramExercise> allExercises) async {
    final nameCtrl = TextEditingController(text: exercise.name);
    final setsCtrl = TextEditingController(text: exercise.sets.toString());
    final repsCtrl = TextEditingController(text: exercise.reps);
    final rpeCtrl = TextEditingController(text: exercise.rpe?.toString() ?? '');

    final result = await showDialog<ProgramExercise>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar ejercicio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Ejercicio'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: setsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Series'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: repsCtrl,
                  decoration: const InputDecoration(labelText: 'Repeticiones'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: rpeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'RPE (opcional)'),
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

                if (name.isEmpty || sets == null || sets <= 0 || reps.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor completa todos los campos'),
                    ),
                  );
                  return;
                }

                final updatedExercise = ProgramExercise(
                  order: exercise.order,
                  name: name,
                  sets: sets,
                  reps: reps,
                  rpe: rpe,
                );

                Navigator.pop(context, updatedExercise);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      try {
        final updatedExercises = [...allExercises];
        updatedExercises[index] = result;

        await FirebaseFirestore.instance
            .collection('program')
            .doc(programId)
            .update({
          'exercises': updatedExercises.map((e) => e.toMap()).toList(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ejercicio actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar ejercicio: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // ─────────────────────────────────────
  // ELIMINAR EJERCICIO
  // ─────────────────────────────────────
  Future<void> _deleteExercise(String programId, int index, List<ProgramExercise> allExercises) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar ejercicio'),
          content: Text('¿Estás seguro de eliminar "${allExercises[index].name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        final updatedExercises = [...allExercises];
        updatedExercises.removeAt(index);

        // Reordenar los ejercicios
        for (int i = 0; i < updatedExercises.length; i++) {
          updatedExercises[i] = ProgramExercise(
            order: i + 1,
            name: updatedExercises[i].name,
            sets: updatedExercises[i].sets,
            reps: updatedExercises[i].reps,
            rpe: updatedExercises[i].rpe,
          );
        }

        await FirebaseFirestore.instance
            .collection('program')
            .doc(programId)
            .update({
          'exercises': updatedExercises.map((e) => e.toMap()).toList(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ejercicio eliminado correctamente'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar ejercicio: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
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

                final doc = snapshot.data!.docs.first;
                final program = ProgramModel.fromFirestore(doc);

                return _ActiveProgramCard(
                  program: program,
                  programId: doc.id,
                  onCreateNew: _openCreateProgramDialog,
                  onAddExercise: () => _addExerciseToProgram(doc.id, program.exercises),
                  onEditExercise: (index, exercise) => _editExercise(doc.id, index, exercise, program.exercises),
                  onDeleteExercise: (index) => _deleteExercise(doc.id, index, program.exercises),
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
  final String programId;
  final VoidCallback onCreateNew;
  final VoidCallback onAddExercise;
  final Function(int index, ProgramExercise exercise) onEditExercise;
  final Function(int index) onDeleteExercise;

  const _ActiveProgramCard({
    required this.program,
    required this.programId,
    required this.onCreateNew,
    required this.onAddExercise,
    required this.onEditExercise,
    required this.onDeleteExercise,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Botones superiores
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onAddExercise,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Añadir ejercicio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: onCreateNew,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nuevo programa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bluePrimary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Tarjeta del programa
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
                  child: program.exercises.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay ejercicios en este programa',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.separated(
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
                                // Botones de acción
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  color: AppColors.bluePrimary,
                                  onPressed: () => onEditExercise(index, e),
                                  tooltip: 'Editar',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  color: Colors.red,
                                  onPressed: () => onDeleteExercise(index),
                                  tooltip: 'Eliminar',
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