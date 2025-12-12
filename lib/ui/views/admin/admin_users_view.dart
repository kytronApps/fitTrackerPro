import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../widgets/widgets.dart';

class AdminUsersView extends StatelessWidget {
  const AdminUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ----------------------
        //   TOP AREA COMPACTA
        // ----------------------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Texto pequeño como subtítulo
              Text(
                "1 activo • 1 archivado", // Lo conectamos a Firestore luego
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary.withOpacity(0.7),
                ),
              ),

              // Botón Nuevo Usuario
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const CreateUserDialog(),
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Nuevo Usuario"),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.bluePrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // ----------------------
        //   CONTENIDO / LISTA
        // ----------------------
        Expanded(
          child: Center(
            child: Text(
              "Lista de usuarios próximamente",
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.6),
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
