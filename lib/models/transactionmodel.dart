import 'package:hive/hive.dart';
part 'transactionmodel.g.dart';

@HiveType(typeId: 4) // different from GoalModel
class TransactionModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  double amount;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  bool isExpense;

  TransactionModel({
    required this.title,
    required this.amount,
    required this.date,
    required this.isExpense,
  });
}
