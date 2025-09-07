import 'media.dart';

enum MovieIndustry {
  hollywood('Hollywood', 'film'),
  bollywood('Bollywood', 'star'),
  both('Both', 'globe');

  const MovieIndustry(this.displayName, this.icon);

  final String displayName;
  final String icon;
}

class YearRange {
  final int startYear;
  final int endYear;

  YearRange({
    required this.startYear,
    required this.endYear,
  });

  Map<String, dynamic> toJson() => {
    'startYear': startYear,
    'endYear': endYear,
  };

  factory YearRange.fromJson(Map<String, dynamic> json) => YearRange(
    startYear: json['startYear'],
    endYear: json['endYear'],
  );
}

class RecommendationRequest {
  final String id;
  final String userId;
  final List<String> genreTags;
  final YearRange yearRange;
  final MovieIndustry movieIndustry;
  final String? note;
  final DateTime createdAt;
  final bool isActive;

  RecommendationRequest({
    required this.id,
    required this.userId,
    required this.genreTags,
    required this.yearRange,
    this.movieIndustry = MovieIndustry.both,
    this.note,
    DateTime? createdAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'genreTags': genreTags,
    'yearRange': yearRange.toJson(),
    'movieIndustry': movieIndustry.name,
    'note': note,
    'createdAt': createdAt.toIso8601String(),
    'isActive': isActive,
  };

  factory RecommendationRequest.fromJson(Map<String, dynamic> json) => RecommendationRequest(
    id: json['id'],
    userId: json['userId'],
    genreTags: List<String>.from(json['genreTags']),
    yearRange: YearRange.fromJson(json['yearRange']),
    movieIndustry: MovieIndustry.values.byName(json['movieIndustry']),
    note: json['note'],
    createdAt: DateTime.parse(json['createdAt']),
    isActive: json['isActive'] ?? true,
  );
}

class Recommendation {
  final String id;
  final String requestId;
  final String mediaItemId;
  final String recommenderId;
  final int likeCount;
  final List<String> likerIds;
  final DateTime createdAt;

  Recommendation({
    required this.id,
    required this.requestId,
    required this.mediaItemId,
    required this.recommenderId,
    this.likeCount = 0,
    this.likerIds = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'requestId': requestId,
    'mediaItemId': mediaItemId,
    'recommenderId': recommenderId,
    'likeCount': likeCount,
    'likerIds': likerIds,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Recommendation.fromJson(Map<String, dynamic> json) => Recommendation(
    id: json['id'],
    requestId: json['requestId'],
    mediaItemId: json['mediaItemId'],
    recommenderId: json['recommenderId'],
    likeCount: json['likeCount'] ?? 0,
    likerIds: List<String>.from(json['likerIds'] ?? []),
    createdAt: DateTime.parse(json['createdAt']),
  );

  Recommendation copyWith({
    String? id,
    String? requestId,
    String? mediaItemId,
    String? recommenderId,
    int? likeCount,
    List<String>? likerIds,
    DateTime? createdAt,
  }) => Recommendation(
    id: id ?? this.id,
    requestId: requestId ?? this.requestId,
    mediaItemId: mediaItemId ?? this.mediaItemId,
    recommenderId: recommenderId ?? this.recommenderId,
    likeCount: likeCount ?? this.likeCount,
    likerIds: likerIds ?? this.likerIds,
    createdAt: createdAt ?? this.createdAt,
  );
}

class RecommendationWithDetails {
  final String id;
  final Recommendation recommendation;
  final MediaItem mediaItem;
  final String recommenderName;
  final RecommendationRequest request;

  RecommendationWithDetails({
    required this.recommendation,
    required this.mediaItem,
    required this.recommenderName,
    required this.request,
  }) : id = recommendation.id;
}

class RecommendationRequestWithDetails {
  final String id;
  final RecommendationRequest request;
  final String requesterName;
  final List<RecommendationWithDetails> recommendations;

  RecommendationRequestWithDetails({
    required this.request,
    required this.requesterName,
    this.recommendations = const [],
  }) : id = request.id;

  int get totalRecommendations => recommendations.length;

  List<RecommendationWithDetails> get topRecommendations {
    final sorted = List<RecommendationWithDetails>.from(recommendations);
    sorted.sort((a, b) {
      if (a.recommendation.likeCount != b.recommendation.likeCount) {
        return b.recommendation.likeCount.compareTo(a.recommendation.likeCount);
      }
      return b.recommendation.likerIds.length.compareTo(a.recommendation.likerIds.length);
    });
    return sorted;
  }

  List<RecommendationWithDetails> get leaderboard => 
      topRecommendations.take(3).toList();

  List<RecommendationWithDetails> get otherRecommendations => 
      topRecommendations.skip(3).toList();
}
