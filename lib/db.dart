import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class JsonDatabaseManager {
  static final String _databaseName = "planJsonDatabase.db";

  // Singleton class
  JsonDatabaseManager._privateConstructor();
  static final JsonDatabaseManager instance = JsonDatabaseManager._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    DatabaseFactory dbFactory = databaseFactoryIo;
    // get the application documents directory
    var dir = await getApplicationDocumentsDirectory();
    // make sure it exists
    await dir.create(recursive: true);
    // build the database path
    var dbPath = join(dir.path, _databaseName);
    // open the database
    return await dbFactory.openDatabase(dbPath);
  }
}
