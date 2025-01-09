import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/movie.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDB('movies.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE movies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        year TEXT NOT NULL,
        genre TEXT NOT NULL,
        description TEXT NOT NULL,
        poster TEXT NOT NULL,
        director TEXT NOT NULL,
        rating DOUBLE NOT NULL,
        ownRating DOUBLE NOT NULL,
        comment TEXT NOT NULL,
        watched INTEGER NOT NULL
      )
    ''');
  }
  Future<int> insertMovie(Movie movie) async {
    final db = await instance.database;
    return await db.insert('movies', movie.toMap());
  }
  Future<int> deleteMovie(Movie movie) async {
    final db = await instance.database;
    return await db.delete('movies',where: 'id =?', whereArgs: [movie.id]);
  }
  //Filmler izlenme bilgisine göre çekilir
  Future<List<Movie>> getMovies({required bool watched}) async {
    final db = await instance.database;
    final result = await db.query('movies',
        where: 'watched = ?',
        whereArgs: [watched ? 1 : 0],
        orderBy: 'id DESC');
        
    return result.map((map) => Movie.fromMap(map)).toList();
  }
  //Film türüne göre alınır.
   Future<List<Movie>> getCategory({required bool watched,required String genre}) async {
    final db = await instance.database;
    final result = await db.query('movies',
         where: 'watched = ? AND genre LIKE ?',
        whereArgs: [watched ? 1 : 0, '%$genre%'],
        orderBy: 'id DESC');
        
    return result.map((map) => Movie.fromMap(map)).toList();
  }
}
