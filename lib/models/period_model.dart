import 'package:hive_flutter/hive_flutter.dart';

part 'period_model.g.dart'; // generated adapter file

@HiveType(typeId: 0)
class PeriodModel extends HiveObject {
  @HiveField(0)
  DateTime startDate;

  @HiveField(1)
  DateTime endDate;

  @HiveField(2)
  double startingAmount;

  @HiveField(3)
  double totalSpent;

  @HiveField(4)
  double savings;

  @HiveField(5)
  double savingsLimit; // new field

  PeriodModel({
    required this.startDate,
    required this.endDate,
    required this.startingAmount,
    this.totalSpent = 0,
    this.savings = 0,
    this.savingsLimit = 0,
  });
}

