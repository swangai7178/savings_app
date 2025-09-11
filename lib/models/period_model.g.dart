// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'period_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PeriodModelAdapter extends TypeAdapter<PeriodModel> {
  @override
  final int typeId = 0;

  @override
  PeriodModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PeriodModel(
      startDate: fields[0] as DateTime,
      endDate: fields[1] as DateTime,
      startingAmount: fields[2] as double,
      totalSpent: fields[3] as double,
      savings: fields[4] as double,
      savingsLimit: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, PeriodModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.startDate)
      ..writeByte(1)
      ..write(obj.endDate)
      ..writeByte(2)
      ..write(obj.startingAmount)
      ..writeByte(3)
      ..write(obj.totalSpent)
      ..writeByte(4)
      ..write(obj.savings)
      ..writeByte(5)
      ..write(obj.savingsLimit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PeriodModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
