// lib/utils/contractStatusHelper.dart
import 'package:flutter/material.dart';
import 'package:super_project/model/contractModel.dart';

class ContractStatusHelper {
  static Color color(ContractStatus status) {
    switch (status) {
      case ContractStatus.pending:
        return const Color(0xFFFF9800);
      case ContractStatus.active:
        return const Color(0xFF00BFA5);
      case ContractStatus.completed:
        return const Color(0xFF5B67F1);
      case ContractStatus.cancelled:
        return Colors.red;
    }
  }

  static String label(ContractStatus status) {
    switch (status) {
      case ContractStatus.pending:
        return 'Pending';
      case ContractStatus.active:
        return 'Active';
      case ContractStatus.completed:
        return 'Completed';
      case ContractStatus.cancelled:
        return 'Cancelled';
    }
  }

  static String emoji(ContractStatus status) {
    switch (status) {
      case ContractStatus.pending:
        return '⏳';
      case ContractStatus.active:
        return '🟢';
      case ContractStatus.completed:
        return '✅';
      case ContractStatus.cancelled:
        return '❌';
    }
  }

  static IconData icon(ContractStatus status) {
    switch (status) {
      case ContractStatus.pending:
        return Icons.hourglass_top_outlined;
      case ContractStatus.active:
        return Icons.play_circle_outline;
      case ContractStatus.completed:
        return Icons.check_circle_outline;
      case ContractStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  static Widget badge(ContractStatus status) {
    final c = color(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon(status), size: 12, color: c),
          const SizedBox(width: 4),
          Text(
            '${emoji(status)} ${label(status)}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}