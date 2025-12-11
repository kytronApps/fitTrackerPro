import 'package:flutter/material.dart';

class AdminCalculatorView extends StatelessWidget {
  const AdminCalculatorView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Calculadora Nutricional",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }
}
