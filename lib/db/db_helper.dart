import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('karyawan.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE karyawan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        jabatan TEXT NOT NULL,
        tanggal_masuk TEXT NOT NULL
      )
    ''');
  }

  Future<int> addKaryawan(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('karyawan', data);
  }

  Future<List<Map<String, dynamic>>> getAllKaryawan() async {
    final db = await instance.database;
    return await db.query('karyawan', orderBy: 'id ASC');
  }

  Future<int> updateKaryawan(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db
        .update('karyawan', data, where: 'id = ?', whereArgs: [data['id']]);
  }

  Future<int> deleteKaryawan(int id) async {
    final db = await instance.database;
    return await db.delete('karyawan', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
