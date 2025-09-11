import 'package:hive_flutter/hive_flutter.dart';

part 'expense_model.g.dart'; // generated adapter file

@HiveType(typeId: 1)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  String category;

  @HiveField(2)
  double amount;

  @HiveField(3)
  int periodKey; // link to PeriodModel key

  ExpenseModel({
    required this.date,
    required this.category,
    required this.amount,
    required this.periodKey,
  });
}
