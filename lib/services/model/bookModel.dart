class Book {
  final String id;
  final String userId;
  final String title;
  final List<Episode> episodes;
  final String coverImage;
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
      coverImage: json['coverImage'],
      status: json['status'],
      percentage: json['percentage'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

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
      coverImage: json['coverImage'],
      percentage: json['percentage'].toDouble(),
      conversations: json['conversations'],
      id: json['_id'],
    );
  }
}