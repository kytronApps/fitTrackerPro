import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';

class LoginAccessButtons extends StatelessWidget {
  final VoidCallback onAdminTap;
  final VoidCallback onUserTap;

  const LoginAccessButtons({
    super.key,
    required this.onAdminTap,
    required this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _button(
          "Administrador",
          "Panel completo",
          Icons.admin_panel_settings,
          AppColors.purplePrimary,
          onAdminTap,
        ),
        const SizedBox(height: 16),
        _button(
          "Usuario",
          "Plan personalizado",
          Icons.person_outline,
          AppColors.bluePrimary, // 👈 Color más bonito
          onUserTap,
          disabled: false, // 👈 CAMBIO AQUÍ: false en vez de true
        ),
      ],
    );
  }

  Widget _button(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool disabled = false,
  }) {
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withOpacity(disabled ? 0.3 : 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      )),
                  Text(subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(.9),
                        fontSize: 13,
                      )),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}