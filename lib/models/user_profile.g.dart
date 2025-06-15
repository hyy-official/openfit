// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 4;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      name: fields[0] as String?,
      gender: fields[1] as String?,
      weight: fields[2] as double?,
      bodyFat: fields[3] as double?,
      dietHabit: fields[4] as String?,
      goal: fields[5] as String?,
      gptKey: fields[6] as String?,
      age: fields[7] as int?,
      height: fields[8] as double?,
      targetWeight: fields[9] as double?,
      targetBodyFat: fields[10] as double?,
      targetMuscleMass: fields[11] as double?,
      currentMuscleMass: fields[41] as double?,
      lastBodyFatMeasurement: fields[42] as DateTime?,
      lastMuscleMassMeasurement: fields[43] as DateTime?,
      bodyFatMeasurementMethod: fields[44] as String?,
      muscleMassMeasurementMethod: fields[45] as String?,
      sleepHabits: fields[12] as String?,
      medications: (fields[13] as List?)?.cast<String>(),
      availableIngredients: (fields[14] as List?)?.cast<String>(),
      activityLevel: fields[15] as String?,
      availableWorkoutTime: fields[16] as String?,
      dietaryRestrictions: fields[17] as String?,
      dietaryType: fields[18] as String?,
      fitnessGoals: (fields[19] as List?)?.cast<String>(),
      desiredBodyShapes: (fields[20] as List?)?.cast<String>(),
      currentBodyType: fields[21] as String?,
      complexAreas: (fields[22] as List?)?.cast<String>(),
      hasSpecificGoalEvent: fields[23] as bool?,
      specificGoalEventDetails: fields[24] as String?,
      fitnessLevel: fields[25] as String?,
      weeklyWorkoutFrequency: fields[26] as String?,
      desiredWorkoutDuration: fields[27] as String?,
      workoutPreferences: (fields[28] as Map?)?.cast<String, String>(),
      usualSportsOrInterests: (fields[29] as List?)?.cast<String>(),
      pushupCount: fields[30] as int?,
      pullupCount: fields[31] as int?,
      preferredWorkoutLocations: (fields[32] as List?)?.cast<String>(),
      dietTypes: (fields[33] as List?)?.cast<String>(),
      sugarIntakeFrequency: fields[34] as String?,
      waterIntake: fields[35] as String?,
      mealPrepTime: fields[36] as String?,
      pastWorkoutProblems: (fields[37] as List?)?.cast<String>(),
      additionalWellnessGoals: (fields[38] as List?)?.cast<String>(),
      healthConditionsOrInjuries: (fields[39] as List?)?.cast<String>(),
      lastUpdated: fields[40] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(46)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.gender)
      ..writeByte(2)
      ..write(obj.weight)
      ..writeByte(3)
      ..write(obj.bodyFat)
      ..writeByte(4)
      ..write(obj.dietHabit)
      ..writeByte(5)
      ..write(obj.goal)
      ..writeByte(6)
      ..write(obj.gptKey)
      ..writeByte(7)
      ..write(obj.age)
      ..writeByte(8)
      ..write(obj.height)
      ..writeByte(9)
      ..write(obj.targetWeight)
      ..writeByte(10)
      ..write(obj.targetBodyFat)
      ..writeByte(11)
      ..write(obj.targetMuscleMass)
      ..writeByte(12)
      ..write(obj.sleepHabits)
      ..writeByte(13)
      ..write(obj.medications)
      ..writeByte(14)
      ..write(obj.availableIngredients)
      ..writeByte(15)
      ..write(obj.activityLevel)
      ..writeByte(16)
      ..write(obj.availableWorkoutTime)
      ..writeByte(17)
      ..write(obj.dietaryRestrictions)
      ..writeByte(18)
      ..write(obj.dietaryType)
      ..writeByte(19)
      ..write(obj.fitnessGoals)
      ..writeByte(20)
      ..write(obj.desiredBodyShapes)
      ..writeByte(21)
      ..write(obj.currentBodyType)
      ..writeByte(22)
      ..write(obj.complexAreas)
      ..writeByte(23)
      ..write(obj.hasSpecificGoalEvent)
      ..writeByte(24)
      ..write(obj.specificGoalEventDetails)
      ..writeByte(25)
      ..write(obj.fitnessLevel)
      ..writeByte(26)
      ..write(obj.weeklyWorkoutFrequency)
      ..writeByte(27)
      ..write(obj.desiredWorkoutDuration)
      ..writeByte(28)
      ..write(obj.workoutPreferences)
      ..writeByte(29)
      ..write(obj.usualSportsOrInterests)
      ..writeByte(30)
      ..write(obj.pushupCount)
      ..writeByte(31)
      ..write(obj.pullupCount)
      ..writeByte(32)
      ..write(obj.preferredWorkoutLocations)
      ..writeByte(33)
      ..write(obj.dietTypes)
      ..writeByte(34)
      ..write(obj.sugarIntakeFrequency)
      ..writeByte(35)
      ..write(obj.waterIntake)
      ..writeByte(36)
      ..write(obj.mealPrepTime)
      ..writeByte(37)
      ..write(obj.pastWorkoutProblems)
      ..writeByte(38)
      ..write(obj.additionalWellnessGoals)
      ..writeByte(39)
      ..write(obj.healthConditionsOrInjuries)
      ..writeByte(40)
      ..write(obj.lastUpdated)
      ..writeByte(41)
      ..write(obj.currentMuscleMass)
      ..writeByte(42)
      ..write(obj.lastBodyFatMeasurement)
      ..writeByte(43)
      ..write(obj.lastMuscleMassMeasurement)
      ..writeByte(44)
      ..write(obj.bodyFatMeasurementMethod)
      ..writeByte(45)
      ..write(obj.muscleMassMeasurementMethod);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
