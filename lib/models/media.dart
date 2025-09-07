import 'package:flutter/material.dart';
import 'genre.dart';

enum MediaType {
  movie,
  show;

  String get displayName => name[0].toUpperCase() + name.substring(1);
}

enum ReactionType {
  like('Like', Icons.favorite, Colors.red),
  love('Love', Icons.favorite, Colors.pink),
  wow('Wow', Icons.warning, Colors.orange),
  sad('Sad', Icons.cloud, Colors.blue),
  fire('Fire', Icons.local_fire_department, Colors.orange),
  thumbsUp('Thumbs Up', Icons.thumb_up, Colors.green);

  const ReactionType(this.displayName, this.icon, this.color);

  final String displayName;
  final IconData icon;
  final Color color;
}

class Reaction {
  final String id;
  final String userId;
  final ReactionType type;
  final DateTime createdAt;

  Reaction({
    required this.id,
    required this.userId,
    required this.type,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'type': type.name,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Reaction.fromJson(Map<String, dynamic> json) => Reaction(
    id: json['id'],
    userId: json['userId'],
    type: ReactionType.values.byName(json['type']),
    createdAt: DateTime.parse(json['createdAt']),
  );
}

class Comment {
  final String id;
  final String userId;
  final String text;
  final DateTime createdAt;
  final List<Reaction> reactions;

  Comment({
    required this.id,
    required this.userId,
    required this.text,
    DateTime? createdAt,
    this.reactions = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
    'reactions': reactions.map((r) => r.toJson()).toList(),
  };

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json['id'],
    userId: json['userId'],
    text: json['text'],
    createdAt: DateTime.parse(json['createdAt']),
    reactions: (json['reactions'] as List?)?.map((r) => Reaction.fromJson(r)).toList() ?? [],
  );
}

class WatchParty {
  final String id;
  final String name;
  final String hostId;
  final String hostName;
  final MediaItem media;
  final List<String> participants;
  final DateTime scheduledFor;
  final DateTime startTime;
  final bool isLive;
  final int maxParticipants;
  final double progress;

  WatchParty({
    required this.id,
    this.name = 'Watch Party',
    required this.hostId,
    required this.hostName,
    required this.media,
    this.participants = const [],
    required this.scheduledFor,
    DateTime? startTime,
    this.isLive = false,
    this.maxParticipants = 10,
    this.progress = 0.0,
  }) : startTime = startTime ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'hostId': hostId,
    'hostName': hostName,
    'media': media.toJson(),
    'participants': participants,
    'scheduledFor': scheduledFor.toIso8601String(),
    'startTime': startTime.toIso8601String(),
    'isLive': isLive,
    'maxParticipants': maxParticipants,
    'progress': progress,
  };

  factory WatchParty.fromJson(Map<String, dynamic> json) => WatchParty(
    id: json['id'],
    name: json['name'] ?? 'Watch Party',
    hostId: json['hostId'],
    hostName: json['hostName'],
    media: MediaItem.fromJson(json['media']),
    participants: List<String>.from(json['participants'] ?? []),
    scheduledFor: DateTime.parse(json['scheduledFor']),
    startTime: DateTime.parse(json['startTime']),
    isLive: json['isLive'] ?? false,
    maxParticipants: json['maxParticipants'] ?? 10,
    progress: (json['progress'] ?? 0.0).toDouble(),
  );
}

enum AchievementType {
  firstWatch('First Watch', '🎬', 'Watched your first show'),
  genreExplorer('Genre Explorer', '🗺️', 'Watched 5 different genres'),
  socialButterfly('Social Butterfly', '🦋', 'Connected with 10 friends'),
  bingeWatcher('Binge Watcher', '📺', 'Watched 10 shows in a week'),
  critic('Critic', '⭐', 'Rated 20 shows'),
  trendsetter('Trendsetter', '🔥', 'Started a watch party');

  const AchievementType(this.displayName, this.icon, this.description);

  final String displayName;
  final String icon;
  final String description;
}

class Achievement {
  final String id;
  final AchievementType type;
  final DateTime unlockedAt;
  final int progress;
  final int maxProgress;

  Achievement({
    required this.id,
    required this.type,
    DateTime? unlockedAt,
    this.progress = 1,
    this.maxProgress = 1,
  }) : unlockedAt = unlockedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'unlockedAt': unlockedAt.toIso8601String(),
    'progress': progress,
    'maxProgress': maxProgress,
  };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id'],
    type: AchievementType.values.byName(json['type']),
    unlockedAt: DateTime.parse(json['unlockedAt']),
    progress: json['progress'] ?? 1,
    maxProgress: json['maxProgress'] ?? 1,
  );
}

class MediaItem {
  final String id;
  final String title;
  final MediaType type;
  final Genre genre;
  final String platform;
  final String posterImage;
  final double? imdbRating;
  final int? year;
  final String? description;
  final String? director;
  final List<String>? cast;
  final double? trendingScore;
  final double? userRating;
  final int watchCount;

  MediaItem({
    required this.id,
    required this.title,
    required this.type,
    required this.genre,
    required this.platform,
    this.posterImage = '',
    this.imdbRating,
    this.year,
    this.description,
    this.director,
    this.cast,
    this.trendingScore,
    this.userRating,
    this.watchCount = 0,
  });

  bool get isTrending => (trendingScore ?? 0) > 7.0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type.name,
    'genre': genre.name,
    'platform': platform,
    'posterImage': posterImage,
    'imdbRating': imdbRating,
    'year': year,
    'description': description,
    'director': director,
    'cast': cast,
    'trendingScore': trendingScore,
    'userRating': userRating,
    'watchCount': watchCount,
  };

  factory MediaItem.fromJson(Map<String, dynamic> json) => MediaItem(
    id: json['id'],
    title: json['title'],
    type: MediaType.values.byName(json['type']),
    genre: Genre.values.byName(json['genre']),
    platform: json['platform'],
    posterImage: json['posterImage'] ?? '',
    imdbRating: json['imdbRating']?.toDouble(),
    year: json['year'],
    description: json['description'],
    director: json['director'],
    cast: json['cast'] != null ? List<String>.from(json['cast']) : null,
    trendingScore: json['trendingScore']?.toDouble(),
    userRating: json['userRating']?.toDouble(),
    watchCount: json['watchCount'] ?? 0,
  );
}

class WatchingActivity {
  final String id;
  final String userId;
  final MediaItem media;
  final DateTime createdAt;
  final List<Reaction> reactions;
  final List<Comment> comments;
  final String? watchPartyId;
  final bool isLive;
  final double? progress;

  WatchingActivity({
    required this.id,
    required this.userId,
    required this.media,
    DateTime? createdAt,
    this.reactions = const [],
    this.comments = const [],
    this.watchPartyId,
    this.isLive = false,
    this.progress,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'media': media.toJson(),
    'createdAt': createdAt.toIso8601String(),
    'reactions': reactions.map((r) => r.toJson()).toList(),
    'comments': comments.map((c) => c.toJson()).toList(),
    'watchPartyId': watchPartyId,
    'isLive': isLive,
    'progress': progress,
  };

  factory WatchingActivity.fromJson(Map<String, dynamic> json) => WatchingActivity(
    id: json['id'],
    userId: json['userId'],
    media: MediaItem.fromJson(json['media']),
    createdAt: DateTime.parse(json['createdAt']),
    reactions: (json['reactions'] as List?)?.map((r) => Reaction.fromJson(r)).toList() ?? [],
    comments: (json['comments'] as List?)?.map((c) => Comment.fromJson(c)).toList() ?? [],
    watchPartyId: json['watchPartyId'],
    isLive: json['isLive'] ?? false,
    progress: json['progress']?.toDouble(),
  );
}
