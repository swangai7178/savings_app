import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// your models
import 'package:my_saver/models/expense_model.dart';
import 'package:my_saver/models/goalmodel.dart';
import 'package:my_saver/models/period_model.dart';
import 'package:my_saver/models/transactionmodel.dart';
import 'package:my_saver/models/user_model.dart';


// your screens
import 'package:my_saver/screens/add_expense_screen.dart';
import 'package:my_saver/screens/add_goals_screen.dart';
import 'package:my_saver/screens/add_transaction_screen.dart';
import 'package:my_saver/screens/loginscreen.dart';
import 'package:my_saver/screens/new_period_screen.dart';
import 'package:my_saver/screens/dashboard_screen.dart';
import 'package:my_saver/screens/signupscreen.dart';
import 'package:my_saver/welcomepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register all adapters
  Hive.registerAdapter(PeriodModelAdapter());
  Hive.registerAdapter(ExpenseModelAdapter());
  Hive.registerAdapter(GoalModelAdapter());
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(UserModelAdapter());   

  // Open boxes
  await Hive.openBox<PeriodModel>('periods');
  await Hive.openBox<ExpenseModel>('expenses');
  await Hive.openBox<GoalModel>('goals');
  await Hive.openBox<TransactionModel>('transactions');
 // 👈 register the adapter
  await Hive.openBox<UserModel>('userBox'); 

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
      // ❗ don’t mix `home` with "/" in routes
      initialRoute: '/', // starting screen
      routes: {
        '/': (context) => const WelcomePage(),
        '/dashboard': (context) => const DashboardPage(),
        '/addExpense': (context) => const AddExpenseScreen(),
        '/newPeriod': (context) => const NewPeriodScreen(),
        '/addGoal': (context) => const AddGoalScreen(),
        '/addTransaction': (context) => const AddTransactionScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),

        // you can add more routes for goals/transactions if needed
      },
    );
  }
}
