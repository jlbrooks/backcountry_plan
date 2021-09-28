import 'dart:io';
import 'package:backcountry_plan/models/checkinPoint.dart';
import 'package:backcountry_plan/models/trip.dart';
import 'package:backcountry_plan/models/plan.dart';
import 'package:backcountry_plan/models/problem.dart';
import 'package:backcountry_plan/models/terrainPlan.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseManager {
  static final String _databaseName = "planDatabase.db";

  static final int _databaseVersion = 1;

  // Singleton class
  DatabaseManager._privateConstructor();
  static final DatabaseManager instance = DatabaseManager._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    // Get a location using getDatabasesPath
    String databasesPath = await getDatabasesPath();
    stderr.writeln("Opening db at $databasesPath");
    String path = join(databasesPath, _databaseName);
    //await deleteDatabase(path);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  _onCreate(Database db, int version) async {
    stderr.writeln("Creating db version $version");
    await db.execute(TripModelProvider.createStatement);
    await db.execute(PlanModelProvider.createStatement);
    await db.execute(AvalancheProblemModelProvider.createStatement);
    await db.execute(TerrainPlanModelProvider.createStatement);
    await db.execute(CheckinPointModelProvider.createStatement);
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await _onCreate(db, newVersion);
  }
}
