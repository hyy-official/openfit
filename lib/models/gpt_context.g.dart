// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gpt_context.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GPTContextAdapter extends TypeAdapter<GPTContext> {
  @override
  final int typeId = 3;

  @override
  GPTContext read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GPTContext(
      userId: fields[0] as String,
      conversationId: fields[1] as String?,
      weight: fields[2] as double?,
      bodyFat: fields[3] as double?,
      targetBodyFat: fields[4] as double?,
      targetMuscleMass: fields[5] as double?,
      currentMuscleMass: fields[6] as double?,
      sleepHabits: fields[7] as String?,
      medications: (fields[8] as List?)?.cast<String>(),
      availableIngredients: (fields[9] as List?)?.cast<String>(),
      activityLevel: fields[10] as String?,
      availableWorkoutTime: fields[11] as String?,
      dietaryRestrictions: fields[12] as String?,
      historySummary: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, GPTContext obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.conversationId)
      ..writeByte(2)
      ..write(obj.weight)
      ..writeByte(3)
      ..write(obj.bodyFat)
      ..writeByte(4)
      ..write(obj.targetBodyFat)
      ..writeByte(5)
      ..write(obj.targetMuscleMass)
      ..writeByte(6)
      ..write(obj.currentMuscleMass)
      ..writeByte(7)
      ..write(obj.sleepHabits)
      ..writeByte(8)
      ..write(obj.medications)
      ..writeByte(9)
      ..write(obj.availableIngredients)
      ..writeByte(10)
      ..write(obj.activityLevel)
      ..writeByte(11)
      ..write(obj.availableWorkoutTime)
      ..writeByte(12)
      ..write(obj.dietaryRestrictions)
      ..writeByte(13)
      ..write(obj.historySummary);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GPTContextAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
