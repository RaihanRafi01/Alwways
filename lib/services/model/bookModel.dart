import 'dart:convert';

import 'package:get/get.dart';

class Book {
  final String id;
  final String userId;
  final String title;
  final List<Episode> episodes;
  final String coverImage; // Overlay image (synced with server)
  final String backgroundCover; // Local-only background SVG
  final String status;
  final double percentage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Book({
    required this.id,
    required this.userId,
    required this.title,
    required this.episodes,
    required this.coverImage,
    this.backgroundCover = 'assets/images/book/cover_image_1.svg', // Default local value
    required this.status,
    required this.percentage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['_id'],
      userId: json['userId'],
      title: json['title'],
      episodes: (json['episodes'] as List)
          .map((e) => Episode.fromJson(e, bookId: json['_id'])) // Pass bookId to Episode
          .toList(),
      coverImage: json['coverImage'] ?? '',
      status: json['status'],
      percentage: json['percentage'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'title': title,
      'episodes': episodes.map((e) => e.toJson()).toList(),
      'coverImage': coverImage,
      'status': status,
      'percentage': percentage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'coverImage': coverImage,
      'backgroundCover': backgroundCover,
      'status': status,
      'percentage': percentage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      episodes: (map['episodes'] as List<dynamic>? ?? [])
          .map((e) => Episode.fromMap(e as Map<String, dynamic>))
          .toList(), // Ensure episodes are parsed correctly
      coverImage: map['coverImage'] as String? ?? '',
      backgroundCover: map['backgroundCover'] as String? ?? 'assets/images/book/cover_image_1.svg',
      status: map['status'] as String,
      percentage: map['percentage'] as double,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}

class Episode {
  final String id;
  final String bookId;
  final Map<String, String> title; // Changed from String to Map<String, String>
  final String coverImage;
  final String? backgroundCover;
  final double percentage;
  final List<dynamic> conversations;
  final String? story;
  final String? storyId;

  Episode({
    required this.id,
    required this.bookId,
    required this.title,
    required this.coverImage,
    this.backgroundCover = 'assets/images/book/cover_image_1.svg',
    required this.percentage,
    required this.conversations,
    this.story,
    this.storyId,
  });

  factory Episode.fromJson(Map<String, dynamic> json, {String? bookId}) {
    return Episode(
      id: json['_id'],
      bookId: bookId ?? json['bookId'] ?? '',
      title: Map<String, String>.from(json['title'] ?? {'en': ''}), // Parse title as a map
      coverImage: json['coverImage'] ?? '',
      percentage: json['percentage'].toDouble(),
      conversations: json['conversations'] ?? [],
      story: json['story'],
      storyId: json['storyId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'bookId': bookId,
      'title': title, // Store as a map
      'coverImage': coverImage,
      'percentage': percentage,
      'conversations': conversations,
      'story': story,
      'storyId': storyId,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'title': jsonEncode(title), // Store as JSON string
      'coverImage': coverImage,
      'backgroundCover': backgroundCover,
      'percentage': percentage,
      'conversations': jsonEncode(conversations),
      'story': story,
      'storyId': storyId,
    };
  }

  factory Episode.fromMap(Map<String, dynamic> map) {
    return Episode(
      id: map['id'] as String,
      bookId: map['bookId'] as String,
      title: Map<String, String>.from(jsonDecode(map['title'])), // Parse JSON string back to map
      coverImage: map['coverImage'] as String? ?? '',
      backgroundCover: map['backgroundCover'] as String? ?? 'assets/images/book/cover_image_1.svg',
      percentage: map['percentage'] as double,
      conversations: map['conversations'] != null
          ? jsonDecode(map['conversations'] as String)
          : [],
      story: map['story'] as String?,
      storyId: map['storyId'] as String?,
    );
  }

  Episode copyWith({
    String? id,
    String? bookId,
    Map<String, String>? title,
    String? coverImage,
    String? backgroundCover,
    double? percentage,
    List<dynamic>? conversations,
    String? story,
    String? storyId,
  }) {
    return Episode(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      coverImage: coverImage ?? this.coverImage,
      backgroundCover: backgroundCover ?? this.backgroundCover,
      percentage: percentage ?? this.percentage,
      conversations: conversations ?? this.conversations,
      story: story ?? this.story,
      storyId: storyId ?? this.storyId,
    );
  }

  // Getter for localized title
  String get localizedTitle {
    final lang = Get.locale?.languageCode ?? 'en';
    return title[lang] ?? title['en'] ?? '';
  }
}

class Section {
  final String id;
  final Map<String, String> name; // Changed from String to Map<String, String>
  final int numberOfQuestions;
  final bool published;
  final String createdAt;
  final String updatedAt;
  final int v;
  final int questionsCount;
  final int? episodeIndex;

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
      name: Map<String, String>.from(json['name']), // Parse name as a map
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
      'name': jsonEncode(name), // Store as JSON string
      'numberOfQuestions': numberOfQuestions,
      'published': published ? 1 : 0,
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
      name: Map<String, String>.from(jsonDecode(map['name'])), // Parse JSON string back to map
      numberOfQuestions: map['numberOfQuestions'] as int,
      published: (map['published'] as int) == 1,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
      v: map['v'] as int,
      questionsCount: map['questionsCount'] as int,
      episodeIndex: map['episodeIndex'] as int?,
    );
  }

  // Getter for localized name
  String get localizedName {
    final lang = Get.locale?.languageCode ?? 'en';
    return name[lang] ?? name['en'] ?? '';
  }
}

// New Question model
class Question {
  final String id;
  final String episodeId;
  final String sectionId;
  final Map<String, String> text; // Changed from String to Map<String, String>
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
      episodeId: '', // Remains empty as per your usage
      sectionId: json['sectionId'] as String,
      text: Map<String, String>.from(json['text']), // Parse text as a map
      v: json['__v'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'episodeId': episodeId,
      'sectionId': sectionId,
      'text': jsonEncode(text), // Store as JSON string
      'v': v,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] as String,
      episodeId: map['episodeId'] as String,
      sectionId: map['sectionId'] as String,
      text: Map<String, String>.from(jsonDecode(map['text'])), // Expects valid JSON
      v: map['v'] as int,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
    );
  }

  // Getter for localized text
  String get localizedText {
    final lang = Get.locale?.languageCode ?? 'en';
    return text[lang] ?? text['en'] ?? '';
  }
}