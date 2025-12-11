import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'routes/routes.dart';

class FitTrackerPro extends StatelessWidget {
  const FitTrackerPro({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitTrackerPro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRouter.initialRoute,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
