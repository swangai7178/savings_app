import 'package:hive/hive.dart';

part 'expense_model.g.dart'; // generated file

@HiveType(typeId: 1) // must be unique across all your models
class ExpenseModel extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  String category;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String name; // <— New: name/description

  @HiveField(4)
  int periodKey; // linking to period

  ExpenseModel({
    required this.date,
    required this.category,
    required this.amount,
    required this.name,
    required this.periodKey,
  });
}
