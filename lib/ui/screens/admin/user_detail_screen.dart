import 'package:fittrackerpro/ui/views/views.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../app/theme/colors.dart';
import '../../../models/models.dart';

class UserDetailScreen extends StatefulWidget {
  final UserModel user;

  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detalle del Usuario',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.bluePrimary),
            onPressed: () => _showEditUserDialog(),
            tooltip: 'Editar información',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onPressed: () => _showMoreOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildUserHeader(),
          Container(
            color: AppColors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.bluePrimary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.bluePrimary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(icon: Icon(Icons.info_outline, size: 18), text: 'Info'),
                Tab(
                  icon: Icon(Icons.fitness_center, size: 18),
                  text: 'Programa',
                ),
                Tab(icon: Icon(Icons.trending_up, size: 18), text: 'Pivot'),
                Tab(
                  icon: Icon(Icons.calendar_today, size: 18),
                  text: 'Planificación',
                ),
                Tab(
                  icon: Icon(Icons.medication, size: 18),
                  text: 'Suplementos',
                ),
                Tab(icon: Icon(Icons.restaurant, size: 18), text: 'Dieta'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _InfoTab(user: widget.user),

                // ✅ PROGRAMA REAL
                AdminProgramUsersView(userId: widget.user.id),

                _PivotTab(userId: widget.user.id),
                _PlanningTab(userId: widget.user.id),
                SupplementsUsersView(userId: widget.user.id),

                _DietTab(userId: widget.user.id),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.white,
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
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
                widget.user.initial,
                style: const TextStyle(
                  fontSize: 26,
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.fullDisplayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.user.email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog() {
    final fullNameCtrl = TextEditingController(text: widget.user.fullName);
    final lastNameCtrl = TextEditingController(text: widget.user.lastName);
    final ageCtrl = TextEditingController(
      text: widget.user.age?.toString() ?? '',
    );
    final weightCtrl = TextEditingController(
      text: widget.user.weight?.toString() ?? '',
    );
    final heightCtrl = TextEditingController(
      text: widget.user.height?.toString() ?? '',
    );
    final phoneCtrl = TextEditingController(text: widget.user.phone);
    final notesCtrl = TextEditingController(text: widget.user.notes);

    String? selectedGender = widget.user.gender;
    String? selectedObjective = widget.user.objective;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: AppColors.white,
              title: const Text(
                'Editar Información del Usuario',
                style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: fullNameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Nombre completo',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: lastNameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Apellido',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: ageCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Edad',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedGender,
                              decoration: InputDecoration(
                                labelText: 'Género',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Masculino',
                                  child: Text('Masculino'),
                                ),
                                DropdownMenuItem(
                                  value: 'Femenino',
                                  child: Text('Femenino'),
                                ),
                                DropdownMenuItem(
                                  value: 'Otro',
                                  child: Text('Otro'),
                                ),
                              ],
                              onChanged: (value) {
                                setDialogState(() => selectedGender = value);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: weightCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: 'Peso (kg)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: heightCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: 'Altura (cm)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedObjective,
                        decoration: InputDecoration(
                          labelText: 'Objetivo',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Perder grasa',
                            child: Text('Perder grasa'),
                          ),
                          DropdownMenuItem(
                            value: 'Ganar músculo',
                            child: Text('Ganar músculo'),
                          ),
                          DropdownMenuItem(
                            value: 'Mantener',
                            child: Text('Mantener'),
                          ),
                          DropdownMenuItem(
                            value: 'Recomposición',
                            child: Text('Recomposición'),
                          ),
                        ],
                        onChanged: (value) {
                          setDialogState(() => selectedObjective = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: phoneCtrl,
                        decoration: InputDecoration(
                          labelText: 'Teléfono',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // TextField(
                      //   controller: notesCtrl,
                      //   maxLines: 3,
                      //   decoration: InputDecoration(
                      //     labelText: 'Notas del administrador',
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(12),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
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
                      final updateData = <String, dynamic>{};

                      if (fullNameCtrl.text.isNotEmpty) {
                        updateData['fullName'] = fullNameCtrl.text.trim();
                      }
                      if (lastNameCtrl.text.isNotEmpty) {
                        updateData['lastName'] = lastNameCtrl.text.trim();
                      }
                      if (ageCtrl.text.isNotEmpty) {
                        updateData['age'] = int.tryParse(ageCtrl.text) ?? 0;
                      }
                      if (weightCtrl.text.isNotEmpty) {
                        updateData['weight'] =
                            double.tryParse(weightCtrl.text) ?? 0.0;
                      }
                      if (heightCtrl.text.isNotEmpty) {
                        updateData['height'] =
                            double.tryParse(heightCtrl.text) ?? 0.0;
                      }
                      if (selectedGender != null) {
                        updateData['gender'] = selectedGender;
                      }
                      if (selectedObjective != null) {
                        updateData['objective'] = selectedObjective;
                      }
                      if (phoneCtrl.text.isNotEmpty) {
                        updateData['phone'] = phoneCtrl.text.trim();
                      }
                      if (notesCtrl.text.isNotEmpty) {
                        updateData['notes'] = notesCtrl.text.trim();
                      }

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.user.id)
                          .update(updateData);

                      if (context.mounted) {
                        Navigator.pop(context);
                        setState(() {}); // Recargar vista

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Información actualizada correctamente',
                            ),
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
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
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
              ListTile(
                leading: const Icon(
                  Icons.lock_reset,
                  color: AppColors.bluePrimary,
                ),
                title: const Text('Restablecer contraseña'),
                onTap: () {
                  Navigator.pop(context);
                  _showResetPasswordDialog();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.archive,
                  color: AppColors.purplePrimary,
                ),
                title: const Text('Archivar usuario'),
                subtitle: const Text('El usuario ya no aparecerá en la lista'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmArchiveUser();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red.shade600),
                title: const Text('Eliminar permanentemente'),
                subtitle: const Text('Esta acción no se puede deshacer'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteUser();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showResetPasswordDialog() {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppColors.white,
          title: const Text(
            'Restablecer Contraseña',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.tagProgress,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Usuario: ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.purplePrimary,
                      ),
                    ),
                    Text(
                      widget.user.name,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.purplePrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.user.email,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Nueva Contraseña',
                  hintText: 'Ingresa la nueva contraseña',
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
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Contraseña restablecida correctamente',
                    ),
                    backgroundColor: AppColors.purplePrimary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purplePrimary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Restablecer'),
            ),
          ],
        );
      },
    );
  }

  void _confirmArchiveUser() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: AppColors.white,
          title: const Text(
            '¿Archivar usuario?',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            '${widget.user.name} será movido a usuarios archivados. Podrás restaurarlo más tarde.',
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
                      .collection('users')
                      .doc(widget.user.id)
                      .update({'active': false});

                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Usuario archivado correctamente'),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red.shade600,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Archivar',
                style: TextStyle(color: AppColors.purplePrimary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteUser() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: AppColors.white,
          title: Text(
            '⚠️ Eliminar permanentemente',
            style: TextStyle(color: Colors.red.shade700),
          ),
          content: Text(
            'Vas a eliminar permanentemente a ${widget.user.name}. '
            'Se perderán todos sus datos: programas, dietas, progreso. '
            '\n\nEsta acción NO se puede deshacer.',
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
                      .collection('users')
                      .doc(widget.user.id)
                      .delete();

                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Usuario eliminado permanentemente',
                        ),
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

// ==========================================
// TAB DE INFORMACIÓN PERSONAL
// ==========================================

class _InfoTab extends StatelessWidget {
  final UserModel user;

  const _InfoTab({required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildInfoCard([
        // 1. Estado
        _InfoRow(
          icon: user.active ? Icons.check_circle : Icons.cancel,
          label: 'Estado',
          value: user.active ? 'Activo' : 'Inactivo',
        ),

        // 2. Edad
        _InfoRow(
          icon: Icons.cake,
          label: 'Edad',
          value: user.age != null ? '${user.age} años' : '--',
        ),

        // 3. Altura
        _InfoRow(
          icon: Icons.height,
          label: 'Altura',
          value: user.height != null
              ? '${user.height!.toStringAsFixed(0)} cm'
              : '--',
        ),

        // 4. Peso
        _InfoRow(
          icon: Icons.monitor_weight_outlined,
          label: 'Peso',
          value: user.weight != null
              ? '${user.weight!.toStringAsFixed(1)} kg'
              : '--',
        ),

        // 5. Género
        _InfoRow(icon: Icons.wc, label: 'Género', value: user.gender ?? '--'),

        // 6. Objetivo
        _InfoRow(
          icon: Icons.flag,
          label: 'Objetivo',
          value: user.objective ?? '--',
        ),
        // 7. Teléfono
        _InfoRow(
          icon: Icons.phone,
          label: 'Teléfono',
          value: user.phone ?? '--',
        ),

        // 8. Plan
        _InfoRow(
          icon: Icons.workspace_premium,
          label: 'Plan',
          value: user.plan,
        ),
      ]),
    );
  }
}

Widget _buildInfoCard(List<_InfoRow> rows) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        for (int i = 0; i < rows.length; i++) ...[
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  rows[i].icon,
                  color: AppColors.bluePrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rows[i].label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rows[i].value,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (i < rows.length - 1) const Divider(height: 32),
        ],
      ],
    ),
  );
}

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;

  _InfoRow({required this.icon, required this.label, required this.value});
}

// ==========================================
// OTROS TABS (Placeholders)
// ==========================================

class _PivotTab extends StatelessWidget {
  final String userId;
  const _PivotTab({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Rendimiento del Usuario',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aquí verás el progreso en los ejercicios',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _PlanningTab extends StatelessWidget {
  final String userId;
  const _PlanningTab({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Planificación Semanal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Planificación que el cliente verá',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _SupplementsTab extends StatelessWidget {
  final String userId;
  const _SupplementsTab({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Suplementos Asignados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Suplementos que el admin asigna',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _DietTab extends StatelessWidget {
  final String userId;
  const _DietTab({required this.userId});

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
            'Dieta del Cliente',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Dieta escogida según indicaciones',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
