import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ExpensesListScreen extends StatelessWidget {
  const ExpensesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add expense - Coming soon!')),
          );
        },
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add),
      ),
      body: const Center(
        child: Text('Expenses - Implementation in progress'),
      ),
    );
  }
}
