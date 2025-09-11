import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 5) // unique ID for this model
class UserModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String email;

  @HiveField(2)
  String pin;

  UserModel({
    required this.name,
    required this.email,
    required this.pin,
  });
}
