// lib/models/transactionmodel.dart
import 'package:hive/hive.dart';

part 'transactionmodel.g.dart';

@HiveType(typeId: 2)
class TransactionModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  double amount;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  bool isExpense; // ✅ Add this

  TransactionModel({
    required this.title,
    required this.amount,
    required this.date,
    required this.isExpense,
  });
}
