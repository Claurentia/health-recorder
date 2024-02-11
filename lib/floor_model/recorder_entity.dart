import 'package:floor/floor.dart';
import 'package:intl/intl.dart';

@TypeConverters([DateTimeStringConverter])
@Entity(tableName: 'emotionRecords')
class EmotionRecord {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String emoji;
  final DateTime dateTime;
  final int points;

  EmotionRecord({this.id, required this.emoji, required this.dateTime, required this.points});
}

@TypeConverters([DateTimeStringConverter])
@Entity(tableName: 'dietRecords')
class DietRecord {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String foodItem;
  final int calories;
  final DateTime dateTime;
  final int points;

  DietRecord({this.id, required this.foodItem, required this.calories, required this.dateTime, required this.points});
}

@TypeConverters([DateTimeStringConverter])
@Entity(tableName: 'workoutRecords')
class WorkoutRecord {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  String workout;
  int durationOrReps;
  int caloriesBurned;
  DateTime dateTime;
  final int points;

  WorkoutRecord({this.id, required this.workout, required this.durationOrReps, required this.caloriesBurned, required this.dateTime, required this.points});
}

class DateTimeStringConverter extends TypeConverter<DateTime, String> {
  @override
  DateTime decode(String databaseValue) {
    return DateFormat('yyyy-MM-dd – kk:mm').parse(databaseValue);
  }

  @override
  String encode(DateTime value) {
    return DateFormat('yyyy-MM-dd – kk:mm').format(value);
  }
}