import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';

class AdminNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onChange;

  const AdminNavBar({
    super.key,
    required this.currentIndex,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      ("Usuarios", Icons.people_alt_rounded),
      ("Cuestionarios", Icons.list_alt_rounded),
      ("Perímetros", Icons.straighten_rounded),
      ("Menús", Icons.calendar_month_rounded),
      ("Calculadora", Icons.calculate_rounded),
    ];

    return Container(
      color: AppColors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(items.length, (i) {
            final selected = i == currentIndex;

            return GestureDetector(
              onTap: () => onChange(i),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected ? AppColors.purplePrimary : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      items[i].$2,
                      size: 22,
                      color: selected
                          ? AppColors.purplePrimary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      items[i].$1,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected
                            ? AppColors.purplePrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
