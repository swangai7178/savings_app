
import 'package:hive_flutter/hive_flutter.dart';
part 'goalmodel.g.dart'; // ✅ correct part directive
@HiveType(typeId: 3)
class GoalModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double targetAmount;

  @HiveField(2)
  double savedAmount;

  @HiveField(3)
  DateTime? deadline;

  GoalModel({
    required this.name,
    required this.targetAmount,
    this.savedAmount = 0,
    this.deadline,
  });
}

