import 'package:hive_flutter/hive_flutter.dart';
part 'goal_model.g.dart';

@HiveType(typeId: 1)
class GoalModel {
  @HiveField(0)
  String name;

  @HiveField(1)
  double targetAmount;

  @HiveField(2)
  double savedAmount;

  @HiveField(3)
  DateTime startDate;

  @HiveField(4)
  DateTime endDate;

  GoalModel({
    required this.name,
    required this.targetAmount,
    this.savedAmount = 0,
    required this.startDate,
    required this.endDate,
  });
}
