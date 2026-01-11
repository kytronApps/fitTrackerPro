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
  final List<TrainingDay> _trainingDays = [];

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
    _trainingDays.clear();

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
                      onPressed: () => _addTrainingDay(setDialogState),
                      icon: const Icon(Icons.add),
                      label: const Text('Añadir día de entrenamiento'),
                    ),

                    const SizedBox(height: 12),

                    if (_trainingDays.isEmpty)
                      const Text(
                        'No hay días añadidos',
                        style: TextStyle(color: AppColors.textSecondary),
                      )
                    else
                      SizedBox(
                        height: 250,
                        child: ListView.builder(
                          itemCount: _trainingDays.length,
                          itemBuilder: (_, index) {
                            final day = _trainingDays[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ExpansionTile(
                                title: Text(day.displayName),
                                subtitle: Text('${day.totalExercises} ejercicios'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setDialogState(() {
                                      _trainingDays.removeAt(index);
                                    });
                                  },
                                ),
                                children: day.exercises.map((e) {
                                  return ListTile(
                                    dense: true,
                                    title: Text(e.name, style: const TextStyle(fontSize: 13)),
                                    subtitle: Text(e.displayFormat, style: const TextStyle(fontSize: 12)),
                                  );
                                }).toList(),
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
                    _trainingDays.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: _trainingDays.isEmpty ? null : _saveProgram,
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
  // AÑADIR DÍA DE ENTRENAMIENTO
  // ─────────────────────────────────────
  void _addTrainingDay(StateSetter setDialogState) {
    final dayNameCtrl = TextEditingController();
    final exercises = <ProgramExercise>[];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (ctx, setDayDialogState) {
            return AlertDialog(
              title: Text('Día ${_trainingDays.length + 1}'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: dayNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del día (opcional)',
                        hintText: 'Ej: Push, Pull, Legs',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ElevatedButton.icon(
                      onPressed: () => _addExerciseToDay(exercises, setDayDialogState),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Añadir ejercicio'),
                    ),
                    
                    const SizedBox(height: 12),

                    if (exercises.isEmpty)
                      const Text('No hay ejercicios', style: TextStyle(color: AppColors.textSecondary))
                    else
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: exercises.length,
                          itemBuilder: (_, idx) {
                            final e = exercises[idx];
                            return ListTile(
                              dense: true,
                              title: Text(e.name),
                              subtitle: Text(e.displayFormat),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () {
                                  setDayDialogState(() {
                                    exercises.removeAt(idx);
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: exercises.isEmpty ? null : () {
                    final day = TrainingDay(
                      dayNumber: _trainingDays.length + 1,
                      name: dayNameCtrl.text.trim().isEmpty ? null : dayNameCtrl.text.trim(),
                      exercises: exercises,
                    );
                    
                    setDialogState(() {
                      _trainingDays.add(day);
                    });
                    
                    Navigator.pop(context);
                  },
                  child: const Text('Guardar día'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────
  // AÑADIR EJERCICIO AL DÍA
  // ─────────────────────────────────────
  void _addExerciseToDay(List<ProgramExercise> exercises, StateSetter setDayDialogState) {
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
                    hintText: 'Ej: 8-12',
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
                    const SnackBar(content: Text('Completa los campos obligatorios')),
                  );
                  return;
                }

                final exercise = ProgramExercise(
                  order: exercises.length + 1,
                  name: name,
                  sets: sets,
                  reps: reps,
                  rpe: rpe,
                );

                setDayDialogState(() {
                  exercises.add(exercise);
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
  // GUARDAR PROGRAMA
  // ─────────────────────────────────────
  Future<void> _saveProgram() async {
    try {
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
        trainingDays: _trainingDays,
      );

      await programsRef.add(newProgram.toFirestore());

      _programNameCtrl.clear();
      _trainingDays.clear();

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
      debugPrint('❌ Error: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────
  // AÑADIR DÍA A PROGRAMA EXISTENTE
  // ─────────────────────────────────────
  Future<void> _addDayToProgram(String programId, List<TrainingDay> currentDays) async {
    final dayNameCtrl = TextEditingController();
    final exercises = <ProgramExercise>[];

    final newDay = await showDialog<TrainingDay>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: Text('Día ${currentDays.length + 1}'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: dayNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del día (opcional)',
                        hintText: 'Ej: Push',
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ElevatedButton.icon(
                      onPressed: () => _addExerciseToDay(exercises, setState),
                      icon: const Icon(Icons.add),
                      label: const Text('Añadir ejercicio'),
                    ),
                    
                    const SizedBox(height: 12),

                    if (exercises.isEmpty)
                      const Text('No hay ejercicios')
                    else
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: exercises.length,
                          itemBuilder: (_, idx) {
                            final e = exercises[idx];
                            return ListTile(
                              dense: true,
                              title: Text(e.name),
                              subtitle: Text(e.displayFormat),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    exercises.removeAt(idx);
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: exercises.isEmpty ? null : () {
                    Navigator.pop(
                      context,
                      TrainingDay(
                        dayNumber: currentDays.length + 1,
                        name: dayNameCtrl.text.trim().isEmpty ? null : dayNameCtrl.text.trim(),
                        exercises: exercises,
                      ),
                    );
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (newDay != null) {
      try {
        final updated = [...currentDays, newDay];
        
        await FirebaseFirestore.instance.collection('program').doc(programId).update({
          'training_days': updated.map((d) => d.toMap()).toList(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Día añadido correctamente'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  // ─────────────────────────────────────
  // ELIMINAR DÍA
  // ─────────────────────────────────────
  Future<void> _deleteDay(String programId, int dayIndex, List<TrainingDay> allDays) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar día'),
        content: Text('¿Eliminar ${allDays[dayIndex].displayName}?'),
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
      ),
    );

    if (confirmed == true) {
      try {
        final updated = [...allDays];
        updated.removeAt(dayIndex);

        // Reordenar números de día
        for (int i = 0; i < updated.length; i++) {
          updated[i] = updated[i].copyWith(dayNumber: i + 1);
        }

        await FirebaseFirestore.instance.collection('program').doc(programId).update({
          'training_days': updated.map((d) => d.toMap()).toList(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Día eliminado'), backgroundColor: Colors.orange),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
                  return Center(child: Text('Error: ${snapshot.error}'));
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
                  onAddDay: () => _addDayToProgram(doc.id, program.trainingDays),
                  onDeleteDay: (idx) => _deleteDay(doc.id, idx, program.trainingDays),
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
/// ESTADO: SIN PROGRAMA
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
            'No hay programa activo',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
/// PROGRAMA ACTIVO
/// =================================================
class _ActiveProgramCard extends StatelessWidget {
  final ProgramModel program;
  final String programId;
  final VoidCallback onCreateNew;
  final VoidCallback onAddDay;
  final Function(int) onDeleteDay;

  const _ActiveProgramCard({
    required this.program,
    required this.programId,
    required this.onCreateNew,
    required this.onAddDay,
    required this.onDeleteDay,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onAddDay,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Añadir día'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
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
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  'Bloque ${program.blockNumber} • ${program.totalDays} días • ${program.totalExercises} ejercicios',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: ListView.builder(
                    itemCount: program.trainingDays.length,
                    itemBuilder: (context, dayIndex) {
                      final day = program.trainingDays[dayIndex];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.bluePrimary,
                            foregroundColor: Colors.white,
                            child: Text('${day.dayNumber}'),
                          ),
                          title: Text(
                            day.displayName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('${day.totalExercises} ejercicios'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => onDeleteDay(dayIndex),
                          ),
                          children: day.exercises.map((e) {
                            return ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                radius: 12,
                                backgroundColor: AppColors.bluePrimary.withOpacity(0.1),
                                child: Text(
                                  '${e.order}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.bluePrimary,
                                  ),
                                ),
                              ),
                              title: Text(e.name, style: const TextStyle(fontSize: 13)),
                              subtitle: Text(e.displayFormat, style: const TextStyle(fontSize: 12)),
                            );
                          }).toList(),
                        ),
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