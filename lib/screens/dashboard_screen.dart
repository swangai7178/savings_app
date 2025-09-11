import 'package:flutter/material.dart';
import 'package:my_saver/models/goalmodel.dart';
import 'package:my_saver/models/transactionmodel.dart';
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
    final bal = await HiveService.getBalance();
    final txns = await HiveService.getTransactions();
    final g = await HiveService.getGoals();
    setState(() {
      balance = bal;
      transactions = txns;
      goals = g;
    });
  }

  void _addSavingToGoal(int index, double amount) async {
    if (balance >= amount) {
      // deduct from balance
      balance -= amount;
      await HiveService.setBalance(balance);

      // update goal
      final goal = goals[index];
      goal.savedAmount += amount;
      await HiveService.updateGoal(index, goal);

      // add transaction
      await HiveService.addTransaction(TransactionModel(
        title: 'Saved for ${goal.name}',
        amount: amount,
        date: DateTime.now(),
        isExpense: true,
      ));
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Insufficient balance'),
      ));
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
              Text('Hello, User!',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),

              // Balance Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B46C1), Color(0xFF805AD5)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Current Balance',
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text(
                      '\$${balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Goals
              Text('Goals', style: Theme.of(context).textTheme.titleLarge),
              ...goals.asMap().entries.map((entry) {
                final i = entry.key;
                final g = entry.value;
                return Card(
                  child: ListTile(
                    title: Text('${g.name} (${g.savedAmount}/${g.targetAmount})'),
                    subtitle: LinearProgressIndicator(
                        value: g.savedAmount / g.targetAmount),
                    trailing: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () async {
                          _addSavingToGoal(i, 10); // example add $10
                        }),
                  ),
                );
              }),

              const SizedBox(height: 20),

              Text('Recent Transactions',
                  style: Theme.of(context).textTheme.titleLarge),
              ...transactions.reversed.take(5).map((t) {
                return ListTile(
                  title: Text(t.title),
                  subtitle: Text(
                      '${t.date.toLocal().toString().substring(0, 16)}'),
                  trailing: Text(
                    (t.isExpense ? '-' : '+') + t.amount.toStringAsFixed(2),
                    style: TextStyle(
                        color: t.isExpense ? Colors.red : Colors.green),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
