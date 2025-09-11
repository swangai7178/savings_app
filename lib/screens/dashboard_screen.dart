import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
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

  double get avgPerDay {
    if (currentPeriod == null || currentExpenses.isEmpty) return 0;
    final daysPassed =
        DateTime.now().difference(currentPeriod!.startDate).inDays + 1;
    return totalSpent / daysPassed;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('My Saver'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            await Navigator.pushNamed(context, '/newPeriod');
            setState(() {});
          },
          child: const Icon(CupertinoIcons.refresh_thin, size: 26),
        ),
      ),
      child: SafeArea(
        child: currentPeriod == null
            ? Center(
                child: Text(
                  'No active period.\nTap refresh to create one.',
                  style: CupertinoTheme.of(context).textTheme.textStyle,
                  textAlign: TextAlign.center,
                ),
              )
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _periodHeader(context),
                          const SizedBox(height: 20),
                          _statsRow(context),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Recent Expenses',
                                  style: CupertinoTheme.of(context)
                                      .textTheme
                                      .navTitleTextStyle),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () async {
                                  await Navigator.pushNamed(
                                      context, '/addExpense');
                                  setState(() {});
                                },
                                child: const Text('+ Add'),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final expense = currentExpenses.reversed.toList()[index];
                      return _expenseItem(expense);
                    }, childCount: currentExpenses.length),
                  )
                ],
              ),
      ),
    );
  }

  Widget _periodHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(16),
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Period',
            style: CupertinoTheme.of(context)
                .textTheme
                .textStyle
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${currentPeriod!.startDate.toLocal().toString().split(' ')[0]}'
            '  →  '
            '${currentPeriod!.endDate.toLocal().toString().split(' ')[0]}',
            style: const TextStyle(color: CupertinoColors.systemGrey),
          ),
        ],
      ),
    );
  }

  Widget _statsRow(BuildContext context) {
    return Row(
      children: [
        _statCard('Starting', currentPeriod!.startingAmount,
            CupertinoColors.activeBlue),
        const SizedBox(width: 10),
        _statCard('Spent', totalSpent, CupertinoColors.systemRed),
        const SizedBox(width: 10),
        _statCard('Remaining', remaining, CupertinoColors.activeGreen),
      ],
    );
  }

  Widget _statCard(String label, double value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color)),
            const SizedBox(height: 4),
            Text(value.toStringAsFixed(2),
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _expenseItem(ExpenseModel expense) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey4,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(CupertinoIcons.money_dollar, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.category,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  expense.date.toLocal().toString().split(' ')[0],
                  style: const TextStyle(
                      fontSize: 12, color: CupertinoColors.systemGrey),
                ),
              ],
            ),
          ),
          Text(
            '-${expense.amount.toStringAsFixed(2)}',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: CupertinoColors.systemRed),
          )
        ],
      ),
    );
  }
}
