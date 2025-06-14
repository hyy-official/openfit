// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_plan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyPlanAdapter extends TypeAdapter<DailyPlan> {
  @override
  final int typeId = 2;

  @override
  DailyPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyPlan(
      date: fields[0] as String,
      mealPlan: (fields[1] as List).cast<String>(),
      workoutPlan: (fields[2] as List).cast<String>(),
      mealDone: (fields[3] as List).cast<bool>(),
      workoutDone: (fields[4] as List).cast<bool>(),
      mealCalories: (fields[5] as List).cast<double>(),
      workoutCalories: (fields[6] as List).cast<double>(),
      notes: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DailyPlan obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.mealPlan)
      ..writeByte(2)
      ..write(obj.workoutPlan)
      ..writeByte(3)
      ..write(obj.mealDone)
      ..writeByte(4)
      ..write(obj.workoutDone)
      ..writeByte(5)
      ..write(obj.mealCalories)
      ..writeByte(6)
      ..write(obj.workoutCalories)
      ..writeByte(7)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
