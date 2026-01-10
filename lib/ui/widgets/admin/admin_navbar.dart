import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';

class AdminNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onChange;
  final VoidCallback onLogout;

  const AdminNavBar({
    super.key,
    required this.currentIndex,
    required this.onChange,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 5) {
          onLogout();
          return;
        }
        onChange(index);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.bluePrimary,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.group_outlined),
          label: "Usuarios",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.checklist_outlined),
          label: "Cuestionarios",
        ),
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.monitor_weight_outlined),
        //   label: "Perímetros",
        // ),
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.calendar_month_outlined),
        //   label: "Menús",
        // ),
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.calculate_outlined),
        //   label: "Calculadora",
        // ),

        // 🔥 BOTÓN LOGOUT EN EL MENÚ
        BottomNavigationBarItem(
          icon: Icon(Icons.logout, color: Colors.red),
          label: "Salir",
        ),
      ],
    );
  }
}
