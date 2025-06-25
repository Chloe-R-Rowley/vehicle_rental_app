import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'step_data_model.dart';

class StepDataDB {
  static final StepDataDB _instance = StepDataDB._internal();
  factory StepDataDB() => _instance;
  StepDataDB._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'step_data.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE step_data(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            key TEXT UNIQUE,
            value TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertOrUpdateStepData(StepData data) async {
    final db = await database;
    await db.insert(
      'step_data',
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<StepData?> getStepData(String key) async {
    final db = await database;
    final maps = await db.query(
      'step_data',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isNotEmpty) {
      return StepData.fromMap(maps.first);
    }
    return null;
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('step_data');
  }
}
