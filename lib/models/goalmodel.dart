import 'package:hive_flutter/hive_flutter.dart';

part 'goalmodel.g.dart';

@HiveType(typeId: 3)
class GoalModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double targetAmount;

  @HiveField(2)
  double savedAmount;

  /// If user sets a deadline date directly
  @HiveField(3)
  DateTime? deadline;

  /// If user prefers to store a duration instead of a specific deadline
  @HiveField(4)
  int? durationInDays; // you can also make this months or weeks depending on your UI

  GoalModel({
    required this.name,
    required this.targetAmount,
    this.savedAmount = 0,
    this.deadline,
    this.durationInDays,
  });
}
