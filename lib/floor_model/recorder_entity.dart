import 'package:floor/floor.dart';

@Entity(tableName: 'emotionRecords')
class EmotionRecord {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String emoji;
  final String dateTime;
  final int points;

  EmotionRecord({this.id, required this.emoji, required this.dateTime, required this.points});
}

@Entity(tableName: 'dietRecords')
class DietRecord {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String foodItem;
  final int calories;
  final String dateTime;
  final int points;

  DietRecord({this.id, required this.foodItem, required this.calories, required this.dateTime, required this.points});
}

@Entity(tableName: 'workoutRecords')
class WorkoutRecord {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String workout;
  final int durationOrReps;
  final int caloriesBurned;
  final String dateTime;
  final int points;

  WorkoutRecord({this.id, required this.workout, required this.durationOrReps, required this.caloriesBurned, required this.dateTime, required this.points});
}