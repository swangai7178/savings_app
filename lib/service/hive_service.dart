import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_saver/models/goalmodel.dart';
import 'package:my_saver/models/transactionmodel.dart';
import 'package:my_saver/models/period_model.dart';

class HiveService {
  /// ---------------- PERIODS ----------------

  /// Get the *current* (last) period.
  static Future<PeriodModel?> getCurrentPeriod() async {
    final box = await Hive.openBox<PeriodModel>('periods');
    if (box.isEmpty) return null;
    return box.getAt(box.length - 1);
  }

  /// Add a new period.
  static Future<void> addPeriod(PeriodModel period) async {
    final box = await Hive.openBox<PeriodModel>('periods');
    await box.add(period);
  }

  /// Update a period at a specific index.
  static Future<void> updatePeriod(int index, PeriodModel period) async {
    final box = await Hive.openBox<PeriodModel>('periods');
    await box.putAt(index, period);
  }

  /// Update the **current** (last) period.
  static Future<void> updateCurrentPeriod(PeriodModel period) async {
    final box = await Hive.openBox<PeriodModel>('periods');
    if (box.isNotEmpty) {
      await box.putAt(box.length - 1, period);
    }
  }

  /// ---------------- TRANSACTIONS ----------------

  static Future<void> addTransaction(TransactionModel t) async {
    final box = await Hive.openBox<TransactionModel>('transactions');
    await box.add(t);
  }

  static Future<List<TransactionModel>> getTransactions() async {
    final box = await Hive.openBox<TransactionModel>('transactions');
    return box.values.toList();
  }

  /// ---------------- GOALS ----------------

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
