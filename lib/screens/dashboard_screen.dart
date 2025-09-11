import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:my_saver/models/goalmodel.dart';
import 'package:my_saver/models/period_model.dart';
import 'package:my_saver/models/transactionmodel.dart';
import 'package:my_saver/screens/add_transaction_screen.dart';
import 'package:my_saver/service/hive_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double balance = 0.0;
  List<TransactionModel> transactions = [];
  List<GoalModel> goals = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
  final period = await HiveService.getCurrentPeriod();
  final txns = await HiveService.getTransactions();
  final g = await HiveService.getGoals();
  setState(() {
    balance = period?.savings ?? 0.0;
    transactions = txns;
    goals = g;
  });
}

  Future<void> _addSavingToGoal(int index, double amount) async {
  // get current period
  final period = await HiveService.getCurrentPeriod();
  if (period == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No active period found')),
    );
    return;
  }

  // pick a "balance" from period (for example startingAmount - totalSpent - savings)
  double availableBalance = period.startingAmount - period.totalSpent - period.savings;

  if (availableBalance >= amount) {
    // update period savings
    period.savings += amount;

    // update the Hive box for period
    final box = await Hive.openBox<PeriodModel>('periods');
    // assuming current period is the last one
    final currentIndex = box.length - 1;
    await box.putAt(currentIndex, period);

    // update goal savedAmount
    final goal = goals[index];
    goal.savedAmount += amount;
    await HiveService.updateGoal(index, goal);

    // add transaction record
    await HiveService.addTransaction(TransactionModel(
      title: 'Saved for ${goal.name}',
      amount: amount,
      date: DateTime.now(),
      isExpense: true,
    ));

    // refresh UI
    _loadData();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Insufficient balance')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Greeting
              Text(
                'Hello, User!',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Balance Card
             Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFF6B46C1), Color(0xFF805AD5)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
  ),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Left side: Balance text
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Balance',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${balance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      // Right side: Big + button
     IconButton(
  iconSize: 40,
  color: Colors.white,
  icon: const Icon(Icons.add_circle),
  onPressed: () async {
    // wait for the NewPeriodScreen to finish
    await Navigator.pushNamed(context, '/newPeriod');

    // then reload your data and rebuild
    setState(() {
      // if you have a method like _loadData() use it here:
       _loadData();
      // or re-fetch the balance/goals etc
    });
  },
),
    ],
  ),
),


              const SizedBox(height: 20),

              // Goals Section
             // Goals section header + list
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      'Goals',
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontWeight: FontWeight.bold),
    ),
    IconButton(
      icon: const Icon(Icons.add),
      onPressed: () async {
        // navigate to add goal screen
        await Navigator.pushNamed(context, '/addGoal'); 
        // after returning, reload data
        _loadData();
      },
    ),
  ],
),

// Goals list
...goals.asMap().entries.map((entry) {
  final i = entry.key;
  final g = entry.value;
  final progress =
      g.targetAmount == 0 ? 0.0 : (g.savedAmount / g.targetAmount);
  return Card(
    shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(g.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '\$${g.savedAmount.toStringAsFixed(2)} / \$${g.targetAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
            ),
            if (g.deadline != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Deadline: ${DateFormat.yMMMd().format(g.deadline!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.savings),
          tooltip: 'Save \$10 to this goal',
          onPressed: () => _addSavingToGoal(i, 10),
        ),
      ),
    ),
  );
}),


              const SizedBox(height: 20),

              // Recent Transactions Section
              Text(
                'Recent Transactions',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...transactions.reversed.take(5).map((t) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      child: Icon(
                        t.isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                        color: t.isExpense ? Colors.red : Colors.green,
                      ),
                    ),
                    title: Text(t.title),
                    subtitle:
                        Text(t.date.toLocal().toString().substring(0, 16)),
                    trailing: Text(
                      (t.isExpense ? '-' : '+') +
                          t.amount.toStringAsFixed(2),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: t.isExpense ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
     floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // navigate to add transaction page and wait for result
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
          // refresh the list after returning
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
