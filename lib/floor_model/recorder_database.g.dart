// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recorder_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorRecorderDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$RecorderDatabaseBuilder databaseBuilder(String name) =>
      _$RecorderDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$RecorderDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$RecorderDatabaseBuilder(null);
}

class _$RecorderDatabaseBuilder {
  _$RecorderDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$RecorderDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$RecorderDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<RecorderDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$RecorderDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$RecorderDatabase extends RecorderDatabase {
  _$RecorderDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  EmotionRecordDao? _emotionRecordDaoInstance;

  DietRecordDao? _dietRecordDaoInstance;

  WorkoutRecordDao? _workoutRecordDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `emotionRecords` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `emoji` TEXT NOT NULL, `dateTime` TEXT NOT NULL, `points` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `dietRecords` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `foodItem` TEXT NOT NULL, `calories` INTEGER NOT NULL, `dateTime` TEXT NOT NULL, `points` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `workoutRecords` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `workout` TEXT NOT NULL, `durationOrReps` INTEGER NOT NULL, `caloriesBurned` INTEGER NOT NULL, `dateTime` TEXT NOT NULL, `points` INTEGER NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  EmotionRecordDao get emotionRecordDao {
    return _emotionRecordDaoInstance ??=
        _$EmotionRecordDao(database, changeListener);
  }

  @override
  DietRecordDao get dietRecordDao {
    return _dietRecordDaoInstance ??= _$DietRecordDao(database, changeListener);
  }

  @override
  WorkoutRecordDao get workoutRecordDao {
    return _workoutRecordDaoInstance ??=
        _$WorkoutRecordDao(database, changeListener);
  }
}

class _$EmotionRecordDao extends EmotionRecordDao {
  _$EmotionRecordDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _emotionRecordInsertionAdapter = InsertionAdapter(
            database,
            'emotionRecords',
            (EmotionRecord item) => <String, Object?>{
                  'id': item.id,
                  'emoji': item.emoji,
                  'dateTime': item.dateTime,
                  'points': item.points
                }),
        _emotionRecordDeletionAdapter = DeletionAdapter(
            database,
            'emotionRecords',
            ['id'],
            (EmotionRecord item) => <String, Object?>{
                  'id': item.id,
                  'emoji': item.emoji,
                  'dateTime': item.dateTime,
                  'points': item.points
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<EmotionRecord> _emotionRecordInsertionAdapter;

  final DeletionAdapter<EmotionRecord> _emotionRecordDeletionAdapter;

  @override
  Future<List<EmotionRecord>> findAllEmotionRecords() async {
    return _queryAdapter.queryList('SELECT * FROM emotionRecords',
        mapper: (Map<String, Object?> row) => EmotionRecord(
            id: row['id'] as int?,
            emoji: row['emoji'] as String,
            dateTime: row['dateTime'] as String,
            points: row['points'] as int));
  }

  @override
  Future<int?> getSumOfPoints() async {
    return _queryAdapter.query(
        'SELECT COALESCE(SUM(points), 0) FROM emotionRecords',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<EmotionRecord?> getLastInsertedRecord() async {
    return _queryAdapter.query(
        'SELECT * FROM emotionRecords ORDER BY id DESC LIMIT 1',
        mapper: (Map<String, Object?> row) => EmotionRecord(
            id: row['id'] as int?,
            emoji: row['emoji'] as String,
            dateTime: row['dateTime'] as String,
            points: row['points'] as int));
  }

  @override
  Future<void> insertEmotionRecord(EmotionRecord emotionRecord) async {
    await _emotionRecordInsertionAdapter.insert(
        emotionRecord, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteEmotionRecord(EmotionRecord emotionRecord) async {
    await _emotionRecordDeletionAdapter.delete(emotionRecord);
  }
}

class _$DietRecordDao extends DietRecordDao {
  _$DietRecordDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _dietRecordInsertionAdapter = InsertionAdapter(
            database,
            'dietRecords',
            (DietRecord item) => <String, Object?>{
                  'id': item.id,
                  'foodItem': item.foodItem,
                  'calories': item.calories,
                  'dateTime': item.dateTime,
                  'points': item.points
                }),
        _dietRecordDeletionAdapter = DeletionAdapter(
            database,
            'dietRecords',
            ['id'],
            (DietRecord item) => <String, Object?>{
                  'id': item.id,
                  'foodItem': item.foodItem,
                  'calories': item.calories,
                  'dateTime': item.dateTime,
                  'points': item.points
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<DietRecord> _dietRecordInsertionAdapter;

  final DeletionAdapter<DietRecord> _dietRecordDeletionAdapter;

  @override
  Future<List<DietRecord>> findAllDietRecords() async {
    return _queryAdapter.queryList('SELECT * FROM dietRecords',
        mapper: (Map<String, Object?> row) => DietRecord(
            id: row['id'] as int?,
            foodItem: row['foodItem'] as String,
            calories: row['calories'] as int,
            dateTime: row['dateTime'] as String,
            points: row['points'] as int));
  }

  @override
  Future<void> updateDietRecordCalories(
    int id,
    int calories,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE dietRecords SET calories = ?2 WHERE id = ?1',
        arguments: [id, calories]);
  }

  @override
  Future<int?> getSumOfPoints() async {
    return _queryAdapter.query(
        'SELECT COALESCE(SUM(points), 0) FROM dietRecords',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<DietRecord?> getLastInsertedRecord() async {
    return _queryAdapter.query(
        'SELECT * FROM dietRecords ORDER BY id DESC LIMIT 1',
        mapper: (Map<String, Object?> row) => DietRecord(
            id: row['id'] as int?,
            foodItem: row['foodItem'] as String,
            calories: row['calories'] as int,
            dateTime: row['dateTime'] as String,
            points: row['points'] as int));
  }

  @override
  Future<void> insertDietRecord(DietRecord dietRecord) async {
    await _dietRecordInsertionAdapter.insert(
        dietRecord, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteDietRecord(DietRecord dietRecord) async {
    await _dietRecordDeletionAdapter.delete(dietRecord);
  }
}

class _$WorkoutRecordDao extends WorkoutRecordDao {
  _$WorkoutRecordDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _workoutRecordInsertionAdapter = InsertionAdapter(
            database,
            'workoutRecords',
            (WorkoutRecord item) => <String, Object?>{
                  'id': item.id,
                  'workout': item.workout,
                  'durationOrReps': item.durationOrReps,
                  'caloriesBurned': item.caloriesBurned,
                  'dateTime': item.dateTime,
                  'points': item.points
                }),
        _workoutRecordDeletionAdapter = DeletionAdapter(
            database,
            'workoutRecords',
            ['id'],
            (WorkoutRecord item) => <String, Object?>{
                  'id': item.id,
                  'workout': item.workout,
                  'durationOrReps': item.durationOrReps,
                  'caloriesBurned': item.caloriesBurned,
                  'dateTime': item.dateTime,
                  'points': item.points
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<WorkoutRecord> _workoutRecordInsertionAdapter;

  final DeletionAdapter<WorkoutRecord> _workoutRecordDeletionAdapter;

  @override
  Future<List<WorkoutRecord>> findAllWorkoutRecords() async {
    return _queryAdapter.queryList('SELECT * FROM workoutRecords',
        mapper: (Map<String, Object?> row) => WorkoutRecord(
            id: row['id'] as int?,
            workout: row['workout'] as String,
            durationOrReps: row['durationOrReps'] as int,
            caloriesBurned: row['caloriesBurned'] as int,
            dateTime: row['dateTime'] as String,
            points: row['points'] as int));
  }

  @override
  Future<int?> getSumOfPoints() async {
    return _queryAdapter.query(
        'SELECT COALESCE(SUM(points), 0) FROM workoutRecords',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<WorkoutRecord?> getLastInsertedRecord() async {
    return _queryAdapter.query(
        'SELECT * FROM workoutRecords ORDER BY id DESC LIMIT 1',
        mapper: (Map<String, Object?> row) => WorkoutRecord(
            id: row['id'] as int?,
            workout: row['workout'] as String,
            durationOrReps: row['durationOrReps'] as int,
            caloriesBurned: row['caloriesBurned'] as int,
            dateTime: row['dateTime'] as String,
            points: row['points'] as int));
  }

  @override
  Future<void> insertWorkoutRecord(WorkoutRecord workoutRecord) async {
    await _workoutRecordInsertionAdapter.insert(
        workoutRecord, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteWorkoutRecord(WorkoutRecord workoutRecord) async {
    await _workoutRecordDeletionAdapter.delete(workoutRecord);
  }
}
