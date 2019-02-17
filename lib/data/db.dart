import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Database _database;

Future<void> initDatabase() async {
  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'favs.db');

  // await deleteDatabase(path);

  _database = await openDatabase(path, version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE favorites (id STRING PRIMARY KEY, title TEXT, link TEXT, timestamp TEXT, favorite INTEGER)');
      }
  );
}

Future<Database> getDatabase() async {
  if (_database == null) {
    await initDatabase();
  }

  return _database;
}
