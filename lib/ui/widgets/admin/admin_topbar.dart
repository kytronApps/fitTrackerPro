import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';

class AdminTopBar extends StatelessWidget {
  final VoidCallback onLogout;

  const AdminTopBar({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          
          IconButton(
            onPressed: onLogout,
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.red,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}
