import 'package:playground_02/controllers/book/book_controller.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import '../model/bookModel.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'books.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE books (
            id TEXT PRIMARY KEY,
            userId TEXT,
            title TEXT,
            coverImage TEXT,
            backgroundCover TEXT,
            status TEXT,
            percentage REAL,
            createdAt TEXT,
            updatedAt TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE episodes (
            id TEXT PRIMARY KEY,
            bookId TEXT,
            title TEXT,
            coverImage TEXT,
            backgroundCover TEXT,
            percentage REAL,
            conversations TEXT,
            FOREIGN KEY (bookId) REFERENCES books (id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE episodes ADD COLUMN backgroundCover TEXT');
        }
      },
    );
  }

  Future<void> insertBook(Book book) async {
    final db = await database;
    print("Inserting/Updating book: ${book.id}, title: ${book.title}");

    // Check if book exists, update if it does, insert if it doesn’t
    final existingBook = (await db.query('books', where: 'id = ?', whereArgs: [book.id])).firstOrNull;
    if (existingBook != null) {
      await db.update('books', book.toMap(), where: 'id = ?', whereArgs: [book.id]);
    } else {
      await db.insert('books', book.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Merge episodes
    for (var episode in book.episodes) {
      print("Inserting/Updating episode: ${episode.id}, bookId: ${episode.bookId}, title: ${episode.title}");
      final existingEpisode = (await db.query('episodes', where: 'id = ?', whereArgs: [episode.id])).firstOrNull;
      if (existingEpisode != null) {
        final existingEpisodeObj = Episode.fromMap(existingEpisode);
        final mergedEpisode = episode.copyWith(
          backgroundCover: existingEpisodeObj.backgroundCover, // Preserve local backgroundCover
        );
        await db.update('episodes', mergedEpisode.toMap(), where: 'id = ?', whereArgs: [episode.id]);
      } else {
        await db.insert('episodes', episode.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
  }

  Future<List<Book>> getBooks() async {
    final db = await database;
    final bookMaps = await db.query('books');
    final books = <Book>[];
    for (var bookMap in bookMaps) {
      final episodeMaps = await db.query('episodes', where: 'bookId = ?', whereArgs: [bookMap['id']]);
      final episodes = episodeMaps.map((e) => Episode.fromMap(e)).toList();
      print("Fetched episodes for book ${bookMap['id']}: ${episodeMaps.map((e) => e['id']).toList()}");
      books.add(Book(
        id: bookMap['id'] as String,
        userId: bookMap['userId'] as String,
        title: bookMap['title'] as String,
        episodes: episodes,
        coverImage: bookMap['coverImage'] as String,
        backgroundCover: bookMap['backgroundCover'] as String,
        status: bookMap['status'] as String,
        percentage: bookMap['percentage'] as double,
        createdAt: DateTime.parse(bookMap['createdAt'] as String),
        updatedAt: DateTime.parse(bookMap['updatedAt'] as String),
      ));
    }
    return books;
  }

  Future<void> updateBook(Book book) async {
    final db = await database;
    await db.update('books', book.toMap(), where: 'id = ?', whereArgs: [book.id]);
    for (var episode in book.episodes) {
      await db.update('episodes', episode.toMap(), where: 'id = ?', whereArgs: [episode.id]);
    }
  }

  Future<void> clearBooks() async {
    final db = await database;
    await db.delete('books');
    await db.delete('episodes');
  }

  Future<void> updateEpisode(Episode episode) async {
    final db = await database;
    await db.update('episodes', episode.toMap(), where: 'id = ?', whereArgs: [episode.id]);
  }
}