import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/colors.dart';
import '../../../providers/auth_provider.dart';

// Barriles de widgets y vistas
import '../../widgets/widgets.dart';
import '../../views/views.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int currentIndex = 0;

  // Lista de vistas - se mantiene en memoria
  final List<Widget> views = const [
    AdminUsersView(),
    AdminWeeklyView(),
    // AdminMetricsView(),
    //AdminMenusView(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        centerTitle: false,
      ),

      // IndexedStack mantiene todas las vistas vivas
      // Esto evita que los StreamBuilders se destruyan
      body: IndexedStack(
        index: currentIndex,
        children: views,
      ),

      bottomNavigationBar: AdminNavBar(
        currentIndex: currentIndex,
        onChange: (i) => setState(() => currentIndex = i),
        onLogout: () {
          auth.logout();
          Navigator.pushReplacementNamed(context, "/");
        },
      ),
    );
  }
}