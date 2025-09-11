import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/period_model.dart';
import '../models/expense_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Box<PeriodModel> periodBox;
  late Box<ExpenseModel> expenseBox;

  @override
  void initState() {
    super.initState();
    periodBox = Hive.box<PeriodModel>('periods');
    expenseBox = Hive.box<ExpenseModel>('expenses');
  }

  PeriodModel? get currentPeriod =>
      periodBox.isEmpty ? null : periodBox.getAt(periodBox.length - 1);

  List<ExpenseModel> get currentExpenses {
    if (currentPeriod == null) return [];
    return expenseBox.values
        .where((e) => e.periodKey == currentPeriod!.key)
        .toList();
  }

  double get totalSpent =>
      currentExpenses.fold(0, (sum, e) => sum + e.amount);

  double get remaining =>
      (currentPeriod?.startingAmount ?? 0) - totalSpent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text('My Saver'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'New Period',
            onPressed: () async {
              await Navigator.pushNamed(context, '/newPeriod');
              setState(() {});
            },
          ),
        ],
      ),
      body: currentPeriod == null
          ? const Center(
              child: Text('No active period. Tap refresh to add one.'),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // HEADER
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Period: ${currentPeriod!.startDate.toLocal().toString().split(' ')[0]} - ${currentPeriod!.endDate.toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _summaryCard(
                              'Spent', totalSpent, Colors.red.shade100),
                          const SizedBox(width: 10),
                          _summaryCard(
                              'Remaining', remaining, Colors.green.shade100),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Recent Expenses',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...currentExpenses.reversed.map((expense) {
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: const Icon(Icons.attach_money, color: Colors.black),
                      ),
                      title: Text(
                        expense.category,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        expense.date.toLocal().toString().split(' ')[0],
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      trailing: Text(
                        '-${expense.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, '/addExpense');
          setState(() {});
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  Widget _summaryCard(String title, double value, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 4),
            Text(value.toStringAsFixed(2),
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
