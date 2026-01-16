import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../widgets/widgets.dart';

enum LoginMode { none, admin, user }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginMode mode = LoginMode.none;

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  void _resetForm() {
    emailCtrl.clear();
    passCtrl.clear();
    setState(() => mode = LoginMode.none);
  }

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
                child: _buildContent(),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (mode) {
      case LoginMode.admin:
        return LoginForm(
          emailCtrl: emailCtrl,
          passCtrl: passCtrl,
          onBack: _resetForm,
        );

      case LoginMode.user:
        return UserLoginForm(
          emailCtrl: emailCtrl,
          passCtrl: passCtrl,
          onBack: _resetForm,
        );

      case LoginMode.none:
      default:
        return LoginAccessButtons(
          onAdminTap: () => setState(() => mode = LoginMode.admin),
          onUserTap: () => setState(() => mode = LoginMode.user),
        );
    }
  }
}
