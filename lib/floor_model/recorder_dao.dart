import 'package:floor/floor.dart';
import 'recorder_entity.dart';

@dao
abstract class EmotionRecordDao {
  @Query('SELECT * FROM emotionRecords')
  Future<List<EmotionRecord>> findAllEmotionRecords();

  @insert
  Future<void> insertEmotionRecord(EmotionRecord emotionRecord);

  @delete
  Future<void> deleteEmotionRecord(EmotionRecord emotionRecord);

  @Query('SELECT COALESCE(SUM(points), 0) FROM emotionRecords')
  Future<int?> getSumOfPoints();

  @Query('SELECT * FROM emotionRecords ORDER BY id DESC LIMIT 1')
  Future<EmotionRecord?> getLastInsertedRecord();
}

@dao
abstract class DietRecordDao {
  @Query('SELECT * FROM dietRecords')
  Future<List<DietRecord>> findAllDietRecords();

  @insert
  Future<void> insertDietRecord(DietRecord dietRecord);

  @Query('UPDATE dietRecords SET calories = :calories WHERE id = :id')
  Future<void> updateDietRecordCalories(int id, int calories);

  @delete
  Future<void> deleteDietRecord(DietRecord dietRecord);

  @Query('SELECT COALESCE(SUM(points), 0) FROM dietRecords')
  Future<int?> getSumOfPoints();

  @Query('SELECT * FROM dietRecords ORDER BY id DESC LIMIT 1')
  Future<DietRecord?> getLastInsertedRecord();
}

@dao
abstract class WorkoutRecordDao {
  @Query('SELECT * FROM workoutRecords')
  Future<List<WorkoutRecord>> findAllWorkoutRecords();

  @insert
  Future<void> insertWorkoutRecord(WorkoutRecord workoutRecord);

  @delete
  Future<void> deleteWorkoutRecord(WorkoutRecord workoutRecord);

  @Query('SELECT COALESCE(SUM(points), 0) FROM workoutRecords')
  Future<int?> getSumOfPoints();

  @Query('SELECT * FROM workoutRecords ORDER BY id DESC LIMIT 1')
  Future<WorkoutRecord?> getLastInsertedRecord();
}