import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showForm = false;

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              const LoginHeader(),
              const SizedBox(height: 40),

              // CARD
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: showForm
                    ? LoginForm(
                        emailCtrl: emailCtrl,
                        passCtrl: passCtrl,
                        onBack: () => setState(() => showForm = false),
                      )
                    : LoginAccessButtons(
                        onAdminTap: () => setState(() => showForm = true),
                        onUserTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text("El acceso de usuario aún no está disponible"),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 40),

              
            ],
          ),
        ),
      ),
    );
  }
}