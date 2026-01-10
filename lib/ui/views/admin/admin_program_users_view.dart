import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../app/theme/colors.dart';
import '../../../models/models.dart';

class AdminProgramUsersView extends StatelessWidget {
  final String userId;

  const AdminProgramUsersView({
    super.key,
    required this.userId,
  });

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
                  .where('id_user', isEqualTo: userId)
                  .where('active', isEqualTo: true)
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _EmptyProgramState(userId: userId);
                }

                final program =
                    ProgramModel.fromFirestore(snapshot.data!.docs.first);

                return _ActiveProgramCard(program: program);
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
  final String userId;

  const _EmptyProgramState({required this.userId});

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
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Aquí luego abriremos el formulario
            },
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

  const _ActiveProgramCard({required this.program});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
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
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          const SizedBox(height: 12),

          Expanded(
            child: ListView.separated(
              itemCount: program.exercises.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 24),
              itemBuilder: (context, index) {
                final e = program.exercises[index];
                return Row(
                  children: [
                    Text(
                      '${e.order}.',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
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
    );
  }
}