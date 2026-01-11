import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../app/theme/colors.dart';
import '../../../models/models.dart';

class SupplementsUsersView extends StatefulWidget {
  final String userId;

  const SupplementsUsersView({super.key, required this.userId});

  @override
  State<SupplementsUsersView> createState() => _SupplementsUsersViewState();
}

class _SupplementsUsersViewState extends State<SupplementsUsersView> {
  // ─────────────────────────────────────
  // AÑADIR SUPLEMENTO
  // ─────────────────────────────────────
  Future<void> _addSupplement() async {
    final nameCtrl = TextEditingController();
    final dosageCtrl = TextEditingController();
    final timingCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Añadir Suplemento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del suplemento *',
                    hintText: 'Ej: Vitamina D3, Creatina, Omega-3',
                    prefixIcon: Icon(Icons.medication),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dosageCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Dosis (opcional)',
                    hintText: 'Ej: 5g, 1000mg, 2 cápsulas',
                    prefixIcon: Icon(Icons.medical_information),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: timingCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Momento (opcional)',
                    hintText: 'Ej: En ayunas, Con comida, Post-entreno',
                    prefixIcon: Icon(Icons.schedule),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notas (opcional)',
                    hintText: 'Indicaciones adicionales',
                    prefixIcon: Icon(Icons.note),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('El nombre del suplemento es obligatorio'),
                    ),
                  );
                  return;
                }
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bluePrimary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Añadir'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      try {
        final supplement = SupplementModel(
          id: '',
          userId: widget.userId,
          name: nameCtrl.text.trim(),
          dosage: dosageCtrl.text.trim().isEmpty ? null : dosageCtrl.text.trim(),
          timing: timingCtrl.text.trim().isEmpty ? null : timingCtrl.text.trim(),
          notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
          createdAt: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('suplementos')
            .add(supplement.toFirestore());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Suplemento añadido correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
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
  }

  // ─────────────────────────────────────
  // EDITAR SUPLEMENTO
  // ─────────────────────────────────────
  Future<void> _editSupplement(SupplementModel supplement) async {
    final nameCtrl = TextEditingController(text: supplement.name);
    final dosageCtrl = TextEditingController(text: supplement.dosage ?? '');
    final timingCtrl = TextEditingController(text: supplement.timing ?? '');
    final notesCtrl = TextEditingController(text: supplement.notes ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Editar Suplemento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del suplemento *',
                    prefixIcon: Icon(Icons.medication),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dosageCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Dosis (opcional)',
                    prefixIcon: Icon(Icons.medical_information),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: timingCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Momento (opcional)',
                    prefixIcon: Icon(Icons.schedule),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notas (opcional)',
                    prefixIcon: Icon(Icons.note),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('El nombre del suplemento es obligatorio'),
                    ),
                  );
                  return;
                }
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bluePrimary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      try {
        await FirebaseFirestore.instance
            .collection('suplementos')
            .doc(supplement.id)
            .update({
          'name': nameCtrl.text.trim(),
          'dosage': dosageCtrl.text.trim().isEmpty ? null : dosageCtrl.text.trim(),
          'timing': timingCtrl.text.trim().isEmpty ? null : timingCtrl.text.trim(),
          'notes': notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
          'updated_at': Timestamp.now(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Suplemento actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
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
  }

  // ─────────────────────────────────────
  // ELIMINAR SUPLEMENTO
  // ─────────────────────────────────────
  Future<void> _deleteSupplement(SupplementModel supplement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Eliminar Suplemento'),
          content: Text('¿Estás seguro de eliminar "${supplement.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('suplementos')
            .doc(supplement.id)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Suplemento eliminado correctamente'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
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
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Suplementación Asignada',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addSupplement,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Añadir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bluePrimary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('suplementos')
                  .where('id_user', isEqualTo: widget.userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _EmptySupplementsState(onAdd: _addSupplement);
                }

                final supplements = snapshot.data!.docs
                    .map((doc) => SupplementModel.fromFirestore(doc))
                    .toList();

                return ListView.builder(
                  itemCount: supplements.length,
                  itemBuilder: (context, index) {
                    final supplement = supplements[index];
                    return _SupplementCard(
                      supplement: supplement,
                      onEdit: () => _editSupplement(supplement),
                      onDelete: () => _deleteSupplement(supplement),
                    );
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
/// ESTADO VACÍO
/// =================================================
class _EmptySupplementsState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptySupplementsState({required this.onAdd});

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
            'Sin suplementos asignados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Añade suplementos para este usuario',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Añadir suplemento'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bluePrimary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// =================================================
/// TARJETA DE SUPLEMENTO
/// =================================================
class _SupplementCard extends StatelessWidget {
  final SupplementModel supplement;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SupplementCard({
    required this.supplement,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
                  color: AppColors.bluePrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medication,
                  color: AppColors.bluePrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  supplement.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                color: AppColors.bluePrimary,
                onPressed: onEdit,
                tooltip: 'Editar',
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                color: Colors.red,
                onPressed: onDelete,
                tooltip: 'Eliminar',
              ),
            ],
          ),

          if (supplement.dosage != null || supplement.timing != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
          ],

          if (supplement.dosage != null) ...[
            _InfoRow(
              icon: Icons.medical_information,
              label: 'Dosis',
              value: supplement.dosage!,
            ),
            const SizedBox(height: 8),
          ],

          if (supplement.timing != null) ...[
            _InfoRow(
              icon: Icons.schedule,
              label: 'Momento',
              value: supplement.timing!,
            ),
            const SizedBox(height: 8),
          ],

          if (supplement.notes != null && supplement.notes!.isNotEmpty) ...[
            _InfoRow(
              icon: Icons.note,
              label: 'Notas',
              value: supplement.notes!,
            ),
          ],
        ],
      ),
    );
  }
}

/// =================================================
/// FILA DE INFORMACIÓN
/// =================================================
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}