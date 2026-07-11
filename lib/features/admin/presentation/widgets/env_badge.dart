import 'package:flutter/material.dart';
import 'package:wordshool/features/admin/data/admin_environment_store.dart';

class EnvBadge extends StatelessWidget {
  const EnvBadge({super.key, required this.environment});

  final AdminTargetEnvironment environment;

  @override
  Widget build(BuildContext context) {
    final isProd = environment.isProd;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isProd ? Colors.green.shade900 : Colors.orange.shade900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isProd ? Colors.green : Colors.orange,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isProd ? Icons.shield : Icons.build,
            size: 16,
            color: isProd ? Colors.greenAccent : Colors.orangeAccent,
          ),
          const SizedBox(width: 6),
          Text(
            environment.label.toUpperCase(),
            style: TextStyle(
              color: isProd ? Colors.greenAccent : Colors.orangeAccent,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
