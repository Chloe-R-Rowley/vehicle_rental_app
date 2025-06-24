import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'vehicle_type_model.dart';

class VehicleTypeDb {
  static final VehicleTypeDb _instance = VehicleTypeDb._internal();
  factory VehicleTypeDb() => _instance;
  VehicleTypeDb._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'vehicle_types.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE vehicle_types(
            id TEXT PRIMARY KEY,
            name TEXT,
            wheels INTEGER,
            type TEXT,
            vehicles TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertVehicleTypes(List<VehicleTypeModel> types) async {
    final db = await database;
    final batch = db.batch();
    for (final type in types) {
      batch.insert(
        'vehicle_types',
        type.toDbJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<VehicleTypeModel>> getVehicleTypes() async {
    final db = await database;
    final maps = await db.query('vehicle_types');
    return maps.map((json) => VehicleTypeModel.fromDbJson(json)).toList();
  }

  Future<void> clearVehicleTypes() async {
    final db = await database;
    await db.delete('vehicle_types');
  }
}
