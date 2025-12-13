import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../models/poster_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return await openDatabase('posters.db', version: 1, onCreate: _onCreate);
    } else {
      String path = join(await getDatabasesPath(), 'posters.db');
      return await openDatabase(path, version: 1, onCreate: _onCreate);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE posters(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        price TEXT NOT NULL,
        unit TEXT NOT NULL,
        offerPrice TEXT,
        description TEXT NOT NULL,
        imageBase64 TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  // Insert a poster
  Future<int> insertPoster(PosterModel poster) async {
    final db = await database;
    return await db.insert('posters', poster.toMap());
  }

  // Update a poster
  Future<int> updatePoster(PosterModel poster) async {
    final db = await database;
    return await db.update(
      'posters',
      poster.toMap(),
      where: 'id = ?',
      whereArgs: [poster.id],
    );
  }

  // Delete a poster
  Future<int> deletePoster(int id) async {
    final db = await database;
    return await db.delete('posters', where: 'id = ?', whereArgs: [id]);
  }

  // Get all posters
  Future<List<PosterModel>> getAllPosters() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'posters',
      orderBy: 'updatedAt DESC',
    );
    return List.generate(maps.length, (i) => PosterModel.fromMap(maps[i]));
  }

  // Search posters by title
  Future<List<PosterModel>> searchPosters(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'posters',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'updatedAt DESC',
    );
    return List.generate(maps.length, (i) => PosterModel.fromMap(maps[i]));
  }

  // Get poster by id
  Future<PosterModel?> getPosterById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'posters',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return PosterModel.fromMap(maps.first);
    }
    return null;
  }
}
