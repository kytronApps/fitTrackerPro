import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../app/theme/colors.dart';

class UserLoginForm extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final VoidCallback onBack;

  const UserLoginForm({
    super.key,
    required this.emailCtrl,
    required this.passCtrl,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: AppColors.textSecondary,
            ),
            const Text(
              "Acceso de Usuario",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // EMAIL
        _input(
          controller: emailCtrl,
          label: "Correo electrónico",
          icon: Icons.email_outlined,
        ),

        const SizedBox(height: 16),

        // PASSWORD
        _input(
          controller: passCtrl,
          label: "Contraseña",
          icon: Icons.lock_outline,
          obscure: true,
        ),

        const SizedBox(height: 28),

        // BUTTON
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
            onPressed: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);

              final ok = await auth.login(
                emailCtrl.text.trim(),
                passCtrl.text.trim(),
              );

              if (ok) {
                Navigator.pushReplacementNamed(context, "/user");
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      auth.errorMessage ?? "Error al iniciar sesión",
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              "Entrar",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }
}
