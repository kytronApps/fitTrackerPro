// lib/ui/views/admin/admin_weekly_view.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../app/theme/colors.dart';
import '../../../models/weekly_questionnaire_model.dart';

class AdminWeeklyView extends StatefulWidget {
  const AdminWeeklyView({super.key});

  @override
  State<AdminWeeklyView> createState() => _AdminWeeklyViewState();
}

class _AdminWeeklyViewState extends State<AdminWeeklyView> {
  bool showOnlyPending = true;
  bool showArchived = false; // NUEVO: Toggle para mostrar archivados

  @override
  Widget build(BuildContext context) {
    // DEBUG: Verificar autenticación
    final currentUser = FirebaseAuth.instance.currentUser;
    print('🔐 Usuario autenticado: ${currentUser?.uid ?? "NO AUTENTICADO"}');
    print('🔐 Email: ${currentUser?.email ?? "SIN EMAIL"}');
    
    return Column(
      children: [
        // HEADER CON FILTROS
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cuestionarios Semanales',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildFilterChip(
                    label: 'Pendientes',
                    isSelected: showOnlyPending && !showArchived,
                    onTap: () => setState(() {
                      showOnlyPending = true;
                      showArchived = false;
                    }),
                  ),
                  const SizedBox(width: 12),
                  _buildFilterChip(
                    label: 'Todos',
                    isSelected: !showOnlyPending && !showArchived,
                    onTap: () => setState(() {
                      showOnlyPending = false;
                      showArchived = false;
                    }),
                  ),
                  const SizedBox(width: 12),
                  _buildFilterChip(
                    label: 'Archivados',
                    isSelected: showArchived,
                    icon: Icons.archive_outlined,
                    onTap: () => setState(() {
                      showArchived = true;
                      showOnlyPending = false;
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),

        // LISTA DE CUESTIONARIOS
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _getQuestionnairesStream(),
            builder: (context, snapshot) {
              print('🔄 Estado: ${snapshot.connectionState}');
              print('🔄 HasData: ${snapshot.hasData}');
              print('🔄 Docs count: ${snapshot.data?.docs.length ?? 0}');
              
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                print('📄 Documentos encontrados:');
                for (var doc in snapshot.data!.docs) {
                  print('   ID: ${doc.id}');
                  print('   Data: ${doc.data()}');
                }
              }
              
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.bluePrimary,
                  ),
                );
              }

              if (snapshot.hasError) {
                print('🔴 ERROR EN STREAM: ${snapshot.error}');
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Error al cargar cuestionarios',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            snapshot.error.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              // Forzar rebuild
                            });
                          },
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Reintentar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.bluePrimary,
                            foregroundColor: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                print('📭 No hay datos. hasData: ${snapshot.hasData}, docs: ${snapshot.data?.docs.length}');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 80,
                        color: AppColors.textSecondary.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        showOnlyPending
                            ? 'No hay cuestionarios pendientes'
                            : 'No hay cuestionarios todavía',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            showOnlyPending = false;
                          });
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Ver todos'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bluePrimary,
                          foregroundColor: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final questionnaires = snapshot.data!.docs
                  .map((doc) => WeeklyQuestionnaire.fromFirestore(doc))
                  .toList();

              print('✅ Cuestionarios cargados: ${questionnaires.length}');

              // Ordenar en memoria: pendientes primero, luego por fecha
              questionnaires.sort((a, b) {
                if (a.reviewed != b.reviewed) {
                  return a.reviewed ? 1 : -1;
                }
                return b.createdAt.compareTo(a.createdAt);
              });

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: questionnaires.length,
                itemBuilder: (context, index) {
                  final q = questionnaires[index];
                  return _buildQuestionnaireCard(q);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Stream<QuerySnapshot> _getQuestionnairesStream() {
    print('📊 Obteniendo cuestionarios... showOnlyPending: $showOnlyPending');
    
    // Ahora podemos usar where + orderBy porque ya existen los índices
    if (showOnlyPending) {
      return FirebaseFirestore.instance
          .collection('weekly_questionnaries')
          .where('reviewed', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .snapshots();
    }

    return FirebaseFirestore.instance
        .collection('weekly_questionnaries')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.bluePrimary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.bluePrimary
                : AppColors.textSecondary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionnaireCard(WeeklyQuestionnaire q) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showQuestionnaireDetail(q),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: q.reviewed
                    ? AppColors.textSecondary.withOpacity(0.2)
                    : AppColors.bluePrimary.withOpacity(0.3),
                width: q.reviewed ? 1 : 2,
              ),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: q.reviewed
                        ? LinearGradient(
                            colors: [
                              AppColors.textSecondary.withOpacity(0.6),
                              AppColors.textSecondary.withOpacity(0.4),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              AppColors.bluePrimary,
                              AppColors.bluePrimary.withOpacity(0.7),
                            ],
                          ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      q.initial,
                      style: const TextStyle(
                        fontSize: 22,
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              q.userName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
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
                              color: q.reviewed
                                  ? AppColors.tagNutrition
                                  : AppColors.tagProgress,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              q.reviewed ? 'Revisado' : 'Pendiente',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: q.reviewed
                                    ? const Color(0xFF2E7D32)
                                    : AppColors.purplePrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        q.formattedWeekDate,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            q.timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Flecha
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showQuestionnaireDetail(WeeklyQuestionnaire questionnaire) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuestionnaireDetailScreen(
          questionnaire: questionnaire,
        ),
      ),
    );
  }
}

// ==========================================
// PANTALLA DE DETALLE DEL CUESTIONARIO
// ==========================================

class QuestionnaireDetailScreen extends StatelessWidget {
  final WeeklyQuestionnaire questionnaire;

  const QuestionnaireDetailScreen({
    super.key,
    required this.questionnaire,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          questionnaire.userName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (!questionnaire.reviewed)
            TextButton.icon(
              onPressed: () => _markAsReviewed(context),
              icon: const Icon(Icons.check_circle, size: 20),
              label: const Text('Marcar Revisado'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.white,
                backgroundColor: AppColors.purplePrimary,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          if (questionnaire.reviewed && !questionnaire.archived)
            IconButton(
              icon: const Icon(Icons.archive_outlined),
              tooltip: 'Archivar',
              onPressed: () => _archiveQuestionnaire(context),
            ),
          if (questionnaire.archived)
            IconButton(
              icon: const Icon(Icons.unarchive_outlined),
              tooltip: 'Desarchivar',
              onPressed: () => _unarchiveQuestionnaire(context),
            ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMoreOptions(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header info
            _buildHeaderCard(),
            const SizedBox(height: 16),

            // Agujetas
            _buildSectionTitle('Agujetas (1-10)'),
            const SizedBox(height: 12),
            _buildSorenessGrid(),
            const SizedBox(height: 24),

            // Preguntas generales
            _buildSectionTitle('Evaluación General'),
            const SizedBox(height: 12),
            _buildGeneralQuestions(),
            
            const SizedBox(height: 24),
            
            // Medidas antropométricas
            _buildSectionTitle('Peso Corporal y Perímetros'),
            const SizedBox(height: 12),
            _buildBodyMeasurements(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.bluePrimary,
                      AppColors.bluePrimary.withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    questionnaire.initial,
                    style: const TextStyle(
                      fontSize: 22,
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
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
                      questionnaire.userName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      questionnaire.userEmail,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    questionnaire.formattedWeekDate,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Enviado ${questionnaire.timeAgo}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: questionnaire.reviewed
                      ? AppColors.tagNutrition
                      : AppColors.tagProgress,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  questionnaire.reviewed ? 'Revisado' : 'Pendiente',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: questionnaire.reviewed
                        ? const Color(0xFF2E7D32)
                        : AppColors.purplePrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSorenessGrid() {
    final muscles = [
      ('Pectoral', questionnaire.pectoral),
      ('Dorsal', questionnaire.dorsal),
      ('Deltoid Anterior', questionnaire.deltoidAnterior),
      ('Deltoid Lateral', questionnaire.deltoidLateral),
      ('Deltoid Posterior', questionnaire.deltoidPosterior),
      ('Quadriceps', questionnaire.quadriceps),
      ('Adductors', questionnaire.adductors),
      ('Hamstrings', questionnaire.hamstrings),
      ('Glutes', questionnaire.glutes),
      ('Biceps', questionnaire.biceps),
      ('Triceps', questionnaire.triceps),
      ('Lumbar', questionnaire.lumbar),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: muscles.map((muscle) {
            return _buildMuscleCard(muscle.$1, muscle.$2, constraints.maxWidth);
          }).toList(),
        );
      },
    );
  }

  Widget _buildMuscleCard(String name, int value, double maxWidth) {
    return Container(
      width: (maxWidth - 40) / 3,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            '$value/10',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.bluePrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralQuestions() {
    return Column(
      children: [
        _buildQuestionCard(
          '¿Cómo de cansado te sientes?',
          '${questionnaire.tiredness}/10',
        ),
        const SizedBox(height: 12),
        _buildQuestionCard(
          '¿Cuánta motivación tienes al entrenar?',
          '${questionnaire.motivation}/10',
        ),
        const SizedBox(height: 12),
        _buildQuestionCard(
          '¿Qué cumplimiento haces de la dieta pautada?',
          '${questionnaire.dietCompliance}/10',
        ),
        const SizedBox(height: 12),
        _buildQuestionCard(
          '¿Cómo de recuperado te sientes entre sesiones?',
          '${questionnaire.recovery}/10',
        ),
        const SizedBox(height: 12),
        _buildQuestionCard(
          'Si no te sientes recuperado, ¿a qué crees que se debe?',
          questionnaire.recoveryNotes.isEmpty
              ? 'Sin respuesta'
              : questionnaire.recoveryNotes,
        ),
        const SizedBox(height: 12),
        _buildQuestionCard(
          '¿Cuántas horas has dormido de media esta semana?',
          questionnaire.sleepHours.isEmpty
              ? 'Sin respuesta'
              : questionnaire.sleepHours,
        ),
        const SizedBox(height: 12),
        _buildQuestionCard(
          'Notas importantes',
          questionnaire.importantNotes.isEmpty
              ? 'Sin notas'
              : questionnaire.importantNotes,
          isLarge: true,
        ),
      ],
    );
  }

  Widget _buildQuestionCard(String question, String answer, {bool isLarge = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: TextStyle(
              fontSize: isLarge ? 14 : 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyMeasurements(BuildContext context) {
    final hasData = questionnaire.bodyWeight != null ||
        questionnaire.waist != null ||
        questionnaire.hips != null ||
        questionnaire.chest != null ||
        questionnaire.thigh != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Medidas Antropométricas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (hasData)
                IconButton(
                  onPressed: () => _showAddAdminNotes(context),
                  icon: const Icon(Icons.note_add, size: 20),
                  color: AppColors.bluePrimary,
                  tooltip: 'Agregar notas',
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Datos proporcionados por el usuario',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          if (!hasData)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.straighten,
                    size: 48,
                    color: AppColors.textSecondary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'El usuario aún no ha registrado medidas',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          if (hasData) ...[
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (questionnaire.bodyWeight != null)
                  _buildMeasurementTile(
                    'Peso Corporal',
                    '${questionnaire.bodyWeight!.toStringAsFixed(1)} kg',
                    Icons.monitor_weight_outlined,
                  ),
                if (questionnaire.waist != null)
                  _buildMeasurementTile(
                    'Cintura',
                    '${questionnaire.waist!.toStringAsFixed(0)} cm',
                    Icons.straighten,
                  ),
                if (questionnaire.hips != null)
                  _buildMeasurementTile(
                    'Cadera',
                    '${questionnaire.hips!.toStringAsFixed(0)} cm',
                    Icons.straighten,
                  ),
                if (questionnaire.chest != null)
                  _buildMeasurementTile(
                    'Pecho',
                    '${questionnaire.chest!.toStringAsFixed(0)} cm',
                    Icons.straighten,
                  ),
                if (questionnaire.thigh != null)
                  _buildMeasurementTile(
                    'Muslo',
                    '${questionnaire.thigh!.toStringAsFixed(0)} cm',
                    Icons.straighten,
                  ),
              ],
            ),
            if (questionnaire.adminNotes != null && questionnaire.adminNotes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     const Text(
              //       'Notas del Administrador',
              //       style: TextStyle(
              //         fontSize: 14,
              //         fontWeight: FontWeight.w600,
              //         color: AppColors.textPrimary,
              //       ),
              //     ),
              //     IconButton(
              //       onPressed: () => _showAddAdminNotes(context),
              //       icon: const Icon(Icons.edit, size: 18),
              //       color: AppColors.textSecondary,
              //     ),
              //   ],
              // ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.tagWorkout.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.bluePrimary.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  questionnaire.adminNotes!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildMeasurementTile(String label, String value, IconData icon) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: AppColors.bluePrimary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.bluePrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAdminNotes(BuildContext context) {
    final notesCtrl = TextEditingController(
      text: questionnaire.adminNotes ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: AppColors.white,
          // title: const Row(
          //   children: [
          //     Icon(Icons.edit_note, color: AppColors.bluePrimary),
          //     SizedBox(width: 12),
          //     Text(
          //       'Notas del Administrador',
          //       style: TextStyle(
          //         fontSize: 18,
          //         color: AppColors.textPrimary,
          //       ),
          //     ),
          //   ],
          // ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Agrega observaciones sobre el progreso de las medidas',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesCtrl,
                maxLines: 5,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Ejemplo: Buena evolución en el peso, mantener el trabajo...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.bluePrimary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('weekly_questionnaries')
                      .doc(questionnaire.id)
                      .update({
                    'adminNotes': notesCtrl.text.trim(),
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Notas guardadas correctamente'),
                        backgroundColor: AppColors.bluePrimary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red.shade600,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bluePrimary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Guardar Notas'),
            ),
          ],
        );
      },
    );
  }

  void _markAsReviewed(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: AppColors.white,
          title: const Text(
            'Marcar como Revisado',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: const Text(
            '¿Has terminado de revisar este cuestionario?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('weekly_questionnaries')  // ← CORRECTO: "naires"
                      .doc(questionnaire.id)
                      .update({'reviewed': true});

                  if (context.mounted) {
                    Navigator.pop(context); // Cerrar diálogo
                    Navigator.pop(context); // Volver a lista

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Cuestionario marcado como revisado'),
                        backgroundColor: AppColors.purplePrimary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red.shade600,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purplePrimary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Marcar Revisado'),
            ),
          ],
        );
      },
    );
  }

  void _archiveQuestionnaire(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: AppColors.white,
          title: const Row(
            children: [
              Icon(Icons.archive, color: AppColors.purplePrimary),
              SizedBox(width: 12),
              Text(
                'Archivar Cuestionario',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ],
          ),
          content: const Text(
            'Este cuestionario se moverá a la sección de archivados. '
            'Podrás verlo en cualquier momento desde el filtro "Archivados".',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('weekly_questionnaries')
                      .doc(questionnaire.id)
                      .update({'archived': true});

                  if (context.mounted) {
                    Navigator.pop(context); // Cerrar diálogo
                    Navigator.pop(context); // Volver a lista

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Cuestionario archivado correctamente'),
                        backgroundColor: AppColors.purplePrimary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red.shade600,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purplePrimary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Archivar'),
            ),
          ],
        );
      },
    );
  }

  void _unarchiveQuestionnaire(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: AppColors.white,
          title: const Row(
            children: [
              Icon(Icons.unarchive, color: AppColors.bluePrimary),
              SizedBox(width: 12),
              Text(
                'Desarchivar Cuestionario',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ],
          ),
          content: const Text(
            '¿Quieres volver a mostrar este cuestionario en la lista principal?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('weekly_questionnaries')
                      .doc(questionnaire.id)
                      .update({'archived': false});

                  if (context.mounted) {
                    Navigator.pop(context); // Cerrar diálogo
                    Navigator.pop(context); // Volver a lista

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Cuestionario desarchivado'),
                        backgroundColor: AppColors.bluePrimary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red.shade600,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bluePrimary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Desarchivar'),
            ),
          ],
        );
      },
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              if (!questionnaire.archived)
                ListTile(
                  leading: const Icon(Icons.archive, color: AppColors.purplePrimary),
                  title: const Text('Archivar cuestionario'),
                  subtitle: const Text('Mover a archivados'),
                  enabled: questionnaire.reviewed,
                  onTap: questionnaire.reviewed
                      ? () {
                          Navigator.pop(context);
                          _archiveQuestionnaire(context);
                        }
                      : null,
                ),
              if (questionnaire.archived)
                ListTile(
                  leading: const Icon(Icons.unarchive, color: AppColors.bluePrimary),
                  title: const Text('Desarchivar cuestionario'),
                  subtitle: const Text('Volver a la lista principal'),
                  onTap: () {
                    Navigator.pop(context);
                    _unarchiveQuestionnaire(context);
                  },
                ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red.shade600),
                title: const Text('Eliminar permanentemente'),
                subtitle: const Text('Esta acción no se puede deshacer'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: AppColors.white,
          title: Text(
            '⚠️ Eliminar Cuestionario',
            style: TextStyle(color: Colors.red.shade700),
          ),
          content: Text(
            'Vas a eliminar permanentemente el cuestionario de ${questionnaire.userName}. '
            'Esta acción NO se puede deshacer.',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('weekly_questionnaries')
                      .doc(questionnaire.id)
                      .delete();

                  if (context.mounted) {
                    Navigator.pop(context); // Cerrar diálogo
                    Navigator.pop(context); // Volver a lista

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Cuestionario eliminado'),
                        backgroundColor: Colors.red.shade600,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red.shade600,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Eliminar',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}