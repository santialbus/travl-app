import 'package:flutter/material.dart';

class ExpenseCard extends StatelessWidget {
  const ExpenseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: ListTile(
        leading: Icon(Icons.money),
        title: Text('Expense Description'),
        trailing: Text('\$0.00'),
      ),
    );
  }
}
