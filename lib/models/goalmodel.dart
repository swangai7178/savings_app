import 'package:hive/hive.dart';
part 'goalmodel.g.dart'; // ✅ correct part directive

@HiveType(typeId: 3) // give each model a unique typeId
class GoalModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double targetAmount;

  @HiveField(2)
  double savedAmount;

  GoalModel({
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
  });
}
