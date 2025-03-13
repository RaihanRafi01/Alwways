import 'dart:convert';

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
  final String bookId; // Foreign key to Book
  final String title;
  final String coverImage;
  final String? backgroundCover; // Added for consistency with Book
  final double percentage;
  final List<dynamic> conversations;

  Episode({
    required this.id,
    required this.bookId,
    required this.title,
    required this.coverImage,
    this.backgroundCover = 'assets/images/book/cover_image_1.svg', // Default local value
    required this.percentage,
    required this.conversations,
  });

  factory Episode.fromJson(Map<String, dynamic> json, {String? bookId}) {
    return Episode(
      id: json['_id'],
      bookId: bookId ?? json['bookId'] ?? '', // Use provided bookId or fallback
      title: json['title'],
      coverImage: json['coverImage'] ?? '',
      percentage: json['percentage'].toDouble(),
      conversations: json['conversations'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'bookId': bookId,
      'title': title,
      'coverImage': coverImage,
      'percentage': percentage,
      'conversations': conversations,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId, // Correct foreign key
      'title': title,
      'coverImage': coverImage,
      'backgroundCover': backgroundCover,
      'percentage': percentage,
      'conversations': jsonEncode(conversations),
    };
  }

  factory Episode.fromMap(Map<String, dynamic> map) {
    return Episode(
      id: map['id'] as String,
      bookId: map['bookId'] as String,
      title: map['title'] as String,
      coverImage: map['coverImage'] as String? ?? '',
      backgroundCover: map['backgroundCover'] as String? ?? 'assets/images/book/cover_image_1.svg',
      percentage: map['percentage'] as double,
      conversations: map['conversations'] != null
          ? jsonDecode(map['conversations'] as String)
          : [],
    );
  }
}