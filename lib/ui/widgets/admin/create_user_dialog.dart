import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../data/user_management_service.dart';

class CreateUserDialog extends StatefulWidget {
  const CreateUserDialog({super.key});

  @override
  State<CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<CreateUserDialog> {
  // --- Controllers ---
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  // --- Estado ---
  bool sending = false;

  // --- Planes disponibles ---
  final List<String> plans = ["1 mes", "2 meses", "3 meses", "6 meses", "12 meses"];
  String selectedPlan = "1 mes";

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- TÍTULO ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Nuevo Usuario",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                )
              ],
            ),

            const SizedBox(height: 16),

            // --- CAMPOS ---
            _input("Nombre completo", nameCtrl),
            const SizedBox(height: 12),

            _input("Correo electrónico", emailCtrl),
            const SizedBox(height: 12),

            _input("Contraseña inicial", passCtrl, obscure: true),

            const SizedBox(height: 16),

            // --- SELECTOR DE PLAN ---
            DropdownButtonFormField<String>(
              value: selectedPlan,
              items: plans
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => selectedPlan = v!),
              decoration: InputDecoration(
                labelText: "Plan",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- BOTÓN CREAR ---
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bluePrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: sending ? null : () => _createUser(context),
                child: sending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Crear Usuario",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------
  // CAMPO DE TEXTO
  // --------------------
  Widget _input(String label, TextEditingController ctrl,
      {bool obscure = false}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // --------------------
  // CREACIÓN DE USUARIO
  // --------------------
  Future<void> _createUser(BuildContext context) async {
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();

    // Validaciones
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todos los campos son obligatorios")),
      );
      return;
    }

    final emailRegExp =
        RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$"); // formato de email
    if (!emailRegExp.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El email no es válido")),
      );
      return;
    }

    setState(() => sending = true);

    final service = UserManagementService();
    final error = await service.createUser(
      name: name,
      email: email,
      password: password,
      plan: selectedPlan,
    );

    setState(() => sending = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return;
    }

    Navigator.pop(context); // cerrar modal

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Usuario creado correctamente"),
        backgroundColor: Colors.green,
      ),
    );
  }
}
