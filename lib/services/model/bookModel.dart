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
          .map((e) => Episode.fromJson(e))
          .toList(),
      coverImage: json['coverImage'] ?? '',
      // backgroundCover not included in API, defaults to local value
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
      // Don’t include backgroundCover since it’s local-only
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
      'backgroundCover': backgroundCover, // Stored locally
      'status': status,
      'percentage': percentage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      episodes: [], // Episodes handled separately
      coverImage: map['coverImage'],
      backgroundCover: map['backgroundCover'], // Retrieved from local DB
      status: map['status'],
      percentage: map['percentage'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}

// Episode class remains unchanged
class Episode {
  final String title;
  final String coverImage;
  final double percentage;
  final List<dynamic> conversations;
  final String id;

  Episode({
    required this.title,
    required this.coverImage,
    required this.percentage,
    required this.conversations,
    required this.id,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      title: json['title'],
      coverImage: json['coverImage'] ?? '',
      percentage: json['percentage'].toDouble(),
      conversations: json['conversations'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'coverImage': coverImage,
      'percentage': percentage,
      'conversations': conversations,
      '_id': id,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'coverImage': coverImage,
      'percentage': percentage,
      'conversations': conversations.toString(), // Store as string for simplicity
      'bookId': id, // Foreign key to link to Book
    };
  }

  factory Episode.fromMap(Map<String, dynamic> map) {
    return Episode(
      id: map['id'],
      title: map['title'],
      coverImage: map['coverImage'],
      percentage: map['percentage'],
      conversations: [], // Parse this as needed
    );
  }
}