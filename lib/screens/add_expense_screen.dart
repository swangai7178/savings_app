import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/period_model.dart';
import '../models/expense_model.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  late Box<PeriodModel> periodBox;
  late Box<ExpenseModel> expenseBox;

  @override
  void initState() {
    super.initState();
    periodBox = Hive.box<PeriodModel>('periods');
    expenseBox = Hive.box<ExpenseModel>('expenses');
  }

  PeriodModel? get currentPeriod {
    if (periodBox.isEmpty) return null;
    return periodBox.getAt(periodBox.length - 1);
  }

  void _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    if (currentPeriod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active period. Add one first.')),
      );
      return;
    }

    final category = _categoryController.text.trim();
    final amount = double.parse(_amountController.text.trim());

    final newExpense = ExpenseModel(
      date: DateTime.now(),
      category: category,
      amount: amount,
      periodKey: currentPeriod!.key as int,
    );

    await expenseBox.add(newExpense);

    // update period totals (optional)
    currentPeriod!.totalSpent += amount;
    currentPeriod!.savings =
        currentPeriod!.startingAmount - currentPeriod!.totalSpent;
    await currentPeriod!.save();

    Navigator.pop(context); // go back to dashboard
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  hintText: 'e.g. Food, Transport',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: 'e.g. 250.00',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save Expense'),
                onPressed: _saveExpense,
              )
            ],
          ),
        ),
      ),
    );
  }
}
