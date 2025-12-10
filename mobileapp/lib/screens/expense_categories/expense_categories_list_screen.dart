import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ExpenseCategoriesListScreen extends StatelessWidget {
  const ExpenseCategoriesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Categories'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add category - Coming soon!')),
          );
        },
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add),
      ),
      body: const Center(
        child: Text('Expense Categories - Implementation in progress'),
      ),
    );
  }
}
