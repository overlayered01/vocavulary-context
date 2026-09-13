import 'package:flutter/material.dart';

import '../theme.dart';

class AddWordButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddWordButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add_rounded, size: 26),
      label: const Text('단어 추가'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 58),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.ink,
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
    );
  }
}
