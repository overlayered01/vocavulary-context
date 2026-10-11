import 'package:flutter/material.dart';

import '../theme.dart';

class WordFormSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final Widget? child;
  final Widget? trailing;

  const WordFormSection({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.line),
    ),
    child: Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: AppColors.accentDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 10),
            Text(
              description!,
              style: TextStyle(
                color: AppColors.sub,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
          if (child != null) ...[const SizedBox(height: 14), child!],
        ],
      ),
    ),
  );
}
