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
      version: 1, // Keep version 1 since it’s a new database
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
          story TEXT, -- Added story column
          storyId TEXT, -- Added storyId column
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
        await db.execute('''
        CREATE TABLE chat_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          bookId TEXT,
          sectionId TEXT,
          question TEXT,
          answer TEXT,
          timestamp TEXT,
          FOREIGN KEY (bookId) REFERENCES books (id),
          FOREIGN KEY (sectionId) REFERENCES sections (id)
        )
      ''');
      },
    );
  }

  Future<Map<String, dynamic>?> getChatHistoryByQuestion(String bookId, String sectionId, String question) async {
    final db = await database;
    final result = await db.query(
      'chat_history',
      where: 'bookId = ? AND sectionId = ? AND question = ?',
      whereArgs: [bookId, sectionId, question],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> insertChatHistory(String bookId, String sectionId, String question, String answer) async {
    final db = await database;
    await db.insert(
      'chat_history',
      {
        'bookId': bookId,
        'sectionId': sectionId,
        'question': question,
        'answer': answer,
        'timestamp': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("Chat history inserted: bookId=$bookId, sectionId=$sectionId, question=$question");
  }

  Future<void> updateEpisode(Episode episode) async {
    final db = await database;
    await db.update(
      'episodes',
      episode.toMap(),
      where: 'id = ?',
      whereArgs: [episode.id],
    );
    print("Episode updated: id=${episode.id}, story=${episode.story?.substring(0, 50)}...");
  }

  Future<List<Map<String, String>>> getChatHistory(String bookId, String sectionId) async {
    final db = await database;
    final historyMaps = await db.query(
      'chat_history',
      where: 'bookId = ? AND sectionId = ?',
      whereArgs: [bookId, sectionId],
      orderBy: 'timestamp ASC',
    );
    return historyMaps.map((map) => {
      'question': map['question'] as String,
      'answer': map['answer'] as String,
    }).toList();
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
        // Preserve the story and backgroundCover from the existing episode
        final mergedEpisode = episode.copyWith(
          story: existingEpisodeObj.story ?? episode.story, // Preserve existing story
          backgroundCover: existingEpisodeObj.backgroundCover ?? episode.backgroundCover,
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
  Future<void> insertEpisode(Episode episode) async {
    final db = await database;
    await db.insert(
      'episodes',
      episode.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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