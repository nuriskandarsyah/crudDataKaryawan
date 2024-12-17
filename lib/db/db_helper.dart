import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  // Membuat instance database
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await _initializeDatabase();
      return _database!;
    }
  }

  // Membuat dan menginisialisasi database
  Future<Database> _initializeDatabase() async {
    String path = join(await getDatabasesPath(), 'notes.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, date TEXT, content TEXT)',
        );
      },
    );
  }

  // Menambahkan note baru
  Future<void> addNote(String title, String date, String content) async {
    final db = await database;
    await db.insert(
      'notes',
      {'title': title, 'date': date, 'content': content},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Mengambil semua notes
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    final db = await database;
    return await db.query('notes');
  }

  // Mengupdate note berdasarkan id
  Future<void> updateNote(
      int id, String title, String date, String content) async {
    final db = await database;
    await db.update(
      'notes',
      {'title': title, 'date': date, 'content': content},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Menghapus note berdasarkan id
  Future<void> deleteNote(int id) async {
    final db = await database;
    await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
