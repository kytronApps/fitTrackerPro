import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo con gradiente sutil
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.bluePrimary,
                AppColors.bluePrimary.withOpacity(0.7),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.bluePrimary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.fitness_center,
            size: 40,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          "FitTrack Pro",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.bluePrimary,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          "Transformando vidas a través del fitness",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary.withOpacity(0.8),
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
