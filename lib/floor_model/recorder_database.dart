import 'package:floor/floor.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'recorder_entity.dart';
import 'recorder_dao.dart';

part 'recorder_database.g.dart';

@Database(version: 1, entities: [EmotionRecord, DietRecord, WorkoutRecord])
abstract class RecorderDatabase extends FloorDatabase {
  EmotionRecordDao get emotionRecordDao;
  DietRecordDao get dietRecordDao;
  WorkoutRecordDao get workoutRecordDao;
}