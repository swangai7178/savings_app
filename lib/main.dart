import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_saver/models/expense_model.dart';
import 'package:my_saver/models/period_model.dart';
import 'package:my_saver/screens/add_expense_screen.dart';
import 'package:my_saver/screens/new_period_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(PeriodModelAdapter());
  Hive.registerAdapter(ExpenseModelAdapter());

  // Open boxes
  await Hive.openBox<PeriodModel>('periods');
  await Hive.openBox<ExpenseModel>('expenses');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Tracker',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
       routes: {
        '/addExpense': (context) => const AddExpenseScreen(),
        '/newPeriod': (context) => const NewPeriodScreen(),
      },
      home: const DashboardScreen(),
    );
  }
}
