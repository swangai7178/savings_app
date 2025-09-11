import 'package:hive/hive.dart';
import 'package:my_saver/models/goalmodel.dart';
import 'package:my_saver/models/transactionmodel.dart';


class HiveService {
  static const balanceKey = 'current_balance';

  static Future<double> getBalance() async {
    final box = await Hive.openBox('wallet');
    return box.get(balanceKey, defaultValue: 0.0);
  }

  static Future<void> setBalance(double amount) async {
    final box = await Hive.openBox('wallet');
    await box.put(balanceKey, amount);
  }

  static Future<void> addTransaction(TransactionModel t) async {
    final box = await Hive.openBox<TransactionModel>('transactions');
    await box.add(t);
  }

  static Future<List<TransactionModel>> getTransactions() async {
    final box = await Hive.openBox<TransactionModel>('transactions');
    return box.values.toList();
  }

  static Future<void> addGoal(GoalModel goal) async {
    final box = await Hive.openBox<GoalModel>('goals');
    await box.add(goal);
  }

  static Future<List<GoalModel>> getGoals() async {
    final box = await Hive.openBox<GoalModel>('goals');
    return box.values.toList();
  }

  static Future<void> updateGoal(int index, GoalModel goal) async {
    final box = await Hive.openBox<GoalModel>('goals');
    await box.putAt(index, goal);
  }
}
