import 'package:playground_02/controllers/book/book_controller.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import '../model/bookModel.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import '../model/bookModel.dart'; // Assuming Book and Episode are here
// Import Section if it’s in a separate file

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
      version: 4, // Incremented version for sections table
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
        await db.execute('''
          CREATE TABLE questions (
            id TEXT PRIMARY KEY,
            episodeId TEXT,
            sectionId TEXT,
            text TEXT,
            v INTEGER,
            createdAt TEXT,
            updatedAt TEXT,
            FOREIGN KEY (episodeId) REFERENCES episodes (id)
          )
        ''');
        await db.execute('''
          CREATE TABLE sections (
            id TEXT PRIMARY KEY,
            name TEXT,
            numberOfQuestions INTEGER,
            published INTEGER,
            createdAt TEXT,
            updatedAt TEXT,
            v INTEGER,
            questionsCount INTEGER,
            episodeIndex INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE episodes ADD COLUMN backgroundCover TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE questions (
              id TEXT PRIMARY KEY,
              episodeId TEXT,
              sectionId TEXT,
              text TEXT,
              v INTEGER,
              createdAt TEXT,
              updatedAt TEXT,
              FOREIGN KEY (episodeId) REFERENCES episodes (id)
            )
          ''');
        }
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE sections (
              id TEXT PRIMARY KEY,
              name TEXT,
              numberOfQuestions INTEGER,
              published INTEGER,
              createdAt TEXT,
              updatedAt TEXT,
              v INTEGER,
              questionsCount INTEGER,
              episodeIndex INTEGER
            )
          ''');
        }
      },
    );
  }

  // Existing methods (unchanged for brevity)
  Future<void> insertBook(Book book) async {
    final db = await database;
    print("Inserting/Updating book: ${book.id}, title: ${book.title}");
    final existingBook = (await db.query('books', where: 'id = ?', whereArgs: [book.id])).firstOrNull;
    if (existingBook != null) {
      await db.update('books', book.toMap(), where: 'id = ?', whereArgs: [book.id]);
    } else {
      await db.insert('books', book.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    for (var episode in book.episodes) {
      print("Inserting/Updating episode: ${episode.id}, bookId: ${episode.bookId}, title: ${episode.title}");
      final existingEpisode = (await db.query('episodes', where: 'id = ?', whereArgs: [episode.id])).firstOrNull;
      if (existingEpisode != null) {
        final existingEpisodeObj = Episode.fromMap(existingEpisode);
        final mergedEpisode = episode.copyWith(backgroundCover: existingEpisodeObj.backgroundCover);
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

  Future<List<Question>> getQuestionsForSection(String sectionId) async {
    final db = await database;
    final questionMaps = await db.query('questions', where: 'sectionId = ?', whereArgs: [sectionId]);
    return questionMaps.map((map) => Question.fromMap(map)).toList();
  }

// Note: insertQuestions remains unchanged but uses sectionId now
  Future<void> insertQuestions(List<Question> questions, String sectionId) async {
    final db = await database;
    for (var question in questions) {
      await db.insert(
        'questions',
        {
          'id': question.id,
          'episodeId': question.episodeId, // Can be empty or removed if not needed
          'sectionId': sectionId, // Explicitly use sectionId
          'text': question.text,
          'v': question.v,
          'createdAt': question.createdAt,
          'updatedAt': question.updatedAt,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Existing methods (unchanged for brevity) - insertBook, getBooks, updateBook, clearBooks, updateEpisode, insertQuestions, getQuestionsForEpisode

  Future<void> insertSections(List<Section> sections) async {
    final db = await database;
    for (var section in sections) {
      await db.insert(
        'sections',
        section.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> updateSection(Section section) async {
    final db = await database;
    await db.update(
      'sections',
      section.toMap(),
      where: 'id = ?',
      whereArgs: [section.id],
    );
  }

  Future<List<Section>> getSections() async {
    final db = await database;
    final sectionMaps = await db.query('sections');
    return sectionMaps.map((map) => Section.fromMap(map)).toList();
  }
}

class Section {
  final String id;
  final String name;
  final int numberOfQuestions;
  final bool published;
  final String createdAt;
  final String updatedAt;
  final int v;
  final int questionsCount;
  final int? episodeIndex; // Optional field, as it’s not always present

  Section({
    required this.id,
    required this.name,
    required this.numberOfQuestions,
    required this.published,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.questionsCount,
    this.episodeIndex,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['_id'] as String,
      name: json['name'] as String,
      numberOfQuestions: json['numberOfQuestions'] as int,
      published: json['published'] as bool,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      v: json['__v'] as int,
      questionsCount: json['questionsCount'] as int,
      episodeIndex: json['episodeIndex'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'numberOfQuestions': numberOfQuestions,
      'published': published ? 1 : 0, // SQLite uses 1/0 for boolean
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'v': v,
      'questionsCount': questionsCount,
      'episodeIndex': episodeIndex,
    };
  }

  factory Section.fromMap(Map<String, dynamic> map) {
    return Section(
      id: map['id'] as String,
      name: map['name'] as String,
      numberOfQuestions: map['numberOfQuestions'] as int,
      published: (map['published'] as int) == 1,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
      v: map['v'] as int,
      questionsCount: map['questionsCount'] as int,
      episodeIndex: map['episodeIndex'] as int?,
    );
  }
}

// New Question model
class Question {
  final String id;
  final String episodeId; // Can be deprecated or removed if not needed
  final String sectionId;
  final String text;
  final int v;
  final String createdAt;
  final String updatedAt;

  Question({
    required this.id,
    required this.episodeId,
    required this.sectionId,
    required this.text,
    required this.v,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['_id'] as String,
      episodeId: '', // Set to empty since we’re using sectionId
      sectionId: json['sectionId'] as String,
      text: json['text'] as String,
      v: json['__v'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] as String,
      episodeId: map['episodeId'] as String,
      sectionId: map['sectionId'] as String,
      text: map['text'] as String,
      v: map['v'] as int,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'episodeId': episodeId,
      'sectionId': sectionId,
      'text': text,
      'v': v,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}