// lib/models/goalmodel.dart
import 'package:hive/hive.dart';

part 'goalmodel.g.dart';

@HiveType(typeId: 1)
class GoalModel extends HiveObject {
  @HiveField(0)
  String name;           // ✅ Add this
  @HiveField(1)
  double targetAmount;   // ✅ maybe you already had this
  @HiveField(2)
  double savedAmount;

  GoalModel({
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
  });
}
