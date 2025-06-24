import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'vehicle_type_model.dart';
import 'vehicle_detail_model.dart';

class VehicleDb {
  static final VehicleDb _instance = VehicleDb._internal();
  factory VehicleDb() => _instance;
  VehicleDb._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'vehicle_app.db');
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
        await db.execute('''
          CREATE TABLE vehicle_details(
            id TEXT PRIMARY KEY,
            name TEXT,
            imageUrl TEXT
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

  Future<void> insertVehicleDetail(VehicleDetailModel detail) async {
    final db = await database;
    await db.insert(
      'vehicle_details',
      detail.toDbJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<VehicleDetailModel?> getVehicleDetail(String id) async {
    final db = await database;
    final maps = await db.query(
      'vehicle_details',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return VehicleDetailModel.fromDbJson(maps.first);
    }
    return null;
  }

  Future<void> clearVehicleDetails() async {
    final db = await database;
    await db.delete('vehicle_details');
  }
}
