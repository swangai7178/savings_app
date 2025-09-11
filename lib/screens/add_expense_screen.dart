import 'package:flutter/cupertino.dart';
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  late Box<PeriodModel> periodBox;
  late Box<ExpenseModel> expenseBox;

  // Predefined categories for picker
  final List<String> _categories = [
    'Food',
    'Transport',
    'Rent',
    'Utilities',
    'Shopping',
    'Entertainment'
  ];
  int _selectedCategoryIndex = 0;

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

    final category = _categories[_selectedCategoryIndex];
    final name = _nameController.text.trim();
    final amount = double.parse(_amountController.text.trim());

    final newExpense = ExpenseModel(
      date: DateTime.now(),
      category: category,
      name: name, // add a 'name' field to your model
      amount: amount,
      periodKey: currentPeriod!.key as int,
    );

    await expenseBox.add(newExpense);

    // update totals
    currentPeriod!.totalSpent += amount;
    currentPeriod!.savings =
        currentPeriod!.startingAmount - currentPeriod!.totalSpent;
    await currentPeriod!.save();

    Navigator.pop(context);
  }

  void _showCategoryPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => SizedBox(
        height: 250,
        child: CupertinoPicker(
          backgroundColor: CupertinoColors.systemGrey6,
          itemExtent: 40,
          scrollController:
              FixedExtentScrollController(initialItem: _selectedCategoryIndex),
          onSelectedItemChanged: (index) {
            setState(() {
              _selectedCategoryIndex = index;
            });
          },
          children: _categories.map((c) => Text(c)).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Add Expense'),
        backgroundColor: CupertinoColors.systemGrey6,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Category Picker
                GestureDetector(
                  onTap: _showCategoryPicker,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_categories[_selectedCategoryIndex]),
                        const Icon(CupertinoIcons.chevron_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Name/Description
                CupertinoTextFormFieldRow(
                  controller: _nameController,
                  placeholder: 'Name / Description',
                  decoration: const BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter a name/description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Amount
                CupertinoTextFormFieldRow(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  placeholder: 'Amount (e.g. 250.00)',
                  decoration: const BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
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
                const SizedBox(height: 30),

                // Save Button
                SizedBox(
                  height: 48,
                  child: CupertinoButton.filled(
                    borderRadius: BorderRadius.circular(12),
                    onPressed: _saveExpense,
                    child: const Text(
                      'Save Expense',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Make sure you have an active period created.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: CupertinoColors.systemGrey),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
