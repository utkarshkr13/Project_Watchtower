import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_models.dart';
import '../models/media.dart';
import '../models/genre.dart';
import '../models/social_models.dart';
import '../theme/app_theme.dart';

extension StringCapitalize on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

class AppDataStore extends ChangeNotifier {
  static const _uuid = Uuid();
  
  // User data
  UserProfile _currentUser = UserProfile(
    id: _uuid.v4(),
    name: 'You',
    favoriteGenres: {Genre.action, Genre.drama, Genre.sciFi, Genre.thriller},
  );

  List<Friend> _friends = [];
  List<WatchingActivity> _activities = [];
  List<WatchParty> _watchParties = [];
  List<Achievement> _achievements = [];
  List<MediaItem> _trendingContent = [];
  List<RecommendationRequest> _recommendationRequests = [];
  List<Recommendation> _recommendations = [];

  // Theme
  ThemeMode _themeMode = ThemeMode.dark;
  AmbientColor _ambientColor = AmbientColor.blue;

  // Auth
  bool _isAuthenticated = false;
  final Map<String, String> _accounts = {}; // email -> password
  final Map<String, String> _accountNames = {}; // email -> name

  AppDataStore() {
    loadSampleData();
  }

  // Getters
  UserProfile get currentUser => _currentUser;
  List<Friend> get friends => List.unmodifiable(_friends);
  List<WatchingActivity> get activities => List.unmodifiable(_activities);
  List<WatchParty> get watchParties => List.unmodifiable(_watchParties);
  List<Achievement> get achievements => List.unmodifiable(_achievements);
  List<MediaItem> get trendingContent => List.unmodifiable(_trendingContent);
  List<RecommendationRequest> get recommendationRequests => List.unmodifiable(_recommendationRequests);
  List<Recommendation> get recommendations => List.unmodifiable(_recommendations);
  ThemeMode get themeMode => _themeMode;
  AmbientColor get ambientColor => _ambientColor;
  bool get isAuthenticated => _isAuthenticated;
  Brightness get brightness => _themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light;

  // Computed properties
  List<WatchingActivity> get feedForYou {
    final sortedActivities = List<WatchingActivity>.from(_activities);
    sortedActivities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedActivities;
  }

  List<WatchingActivity> get liveWatching =>
      _activities.where((activity) => activity.isLive).toList();

  List<MediaItem> get trendingNow {
    final sortedContent = List<MediaItem>.from(_trendingContent);
    sortedContent.sort((a, b) => (b.trendingScore ?? 0).compareTo(a.trendingScore ?? 0));
    return sortedContent;
  }

  List<WatchParty> get upcomingWatchParties {
    final upcoming = _watchParties
        .where((party) => party.scheduledFor.isAfter(DateTime.now()))
        .toList();
    upcoming.sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor));
    return upcoming;
  }

  List<RecommendationRequestWithDetails> get activeRecommendationRequests {
    final activeRequests = _recommendationRequests.where((r) => r.isActive).toList();
    return activeRequests.map((request) {
      final requestRecommendations = _recommendations
          .where((r) => r.requestId == request.id)
          .toList();
      
      final detailedRecommendations = requestRecommendations
          .map((recommendation) {
            final mediaItem = _trendingContent
                .where((m) => m.id == recommendation.mediaItemId)
                .firstOrNull;
            final recommender = _friends
                .where((f) => f.id == recommendation.recommenderId)
                .firstOrNull;
            
            if (mediaItem != null && recommender != null) {
              return RecommendationWithDetails(
                recommendation: recommendation,
                mediaItem: mediaItem,
                recommenderName: recommender.name,
                request: request,
              );
            }
            return null;
          })
          .where((r) => r != null)
          .cast<RecommendationWithDetails>()
          .toList();

      return RecommendationRequestWithDetails(
        request: request,
        requesterName: _currentUser.name,
        recommendations: detailedRecommendations,
      );
    }).toList();
  }

  List<RecommendationRequestWithDetails> get friendsRecommendationRequests {
    final friendRequests = _recommendationRequests
        .where((r) => r.userId != _currentUser.id && r.isActive)
        .toList();
    
    return friendRequests.map((request) {
      final requestRecommendations = _recommendations
          .where((r) => r.requestId == request.id)
          .toList();
      
      final detailedRecommendations = requestRecommendations
          .map((recommendation) {
            final mediaItem = _trendingContent
                .where((m) => m.id == recommendation.mediaItemId)
                .firstOrNull;
            final recommender = _friends
                .where((f) => f.id == recommendation.recommenderId)
                .firstOrNull;
            
            if (mediaItem != null && recommender != null) {
              return RecommendationWithDetails(
                recommendation: recommendation,
                mediaItem: mediaItem,
                recommenderName: recommender.name,
                request: request,
              );
            }
            return null;
          })
          .where((r) => r != null)
          .cast<RecommendationWithDetails>()
          .toList();

      final requesterName = _friends
          .where((f) => f.id == request.userId)
          .firstOrNull?.name ?? 'Friend';

      return RecommendationRequestWithDetails(
        request: request,
        requesterName: requesterName,
        recommendations: detailedRecommendations,
      );
    }).toList();
  }



  void _initializeData() {
    // Initialize friends
    _friends = [
      Friend(id: _uuid.v4(), name: 'Ava'),
      Friend(id: _uuid.v4(), name: 'Liam'),
      Friend(id: _uuid.v4(), name: 'Mia'),
      Friend(id: _uuid.v4(), name: 'Noah'),
    ];

    // Initialize achievements
    _achievements = [
      Achievement(id: _uuid.v4(), type: AchievementType.firstWatch),
      Achievement(
        id: _uuid.v4(),
        type: AchievementType.socialButterfly,
        progress: 4,
        maxProgress: 10,
      ),
      Achievement(
        id: _uuid.v4(),
        type: AchievementType.genreExplorer,
        progress: 3,
        maxProgress: 5,
      ),
    ];

    // Initialize trending content
    _trendingContent = [
      MediaItem(
        id: _uuid.v4(),
        title: 'The Bear',
        type: MediaType.show,
        genre: Genre.drama,
        platform: 'Hulu',
        posterImage: 'https://image.tmdb.org/t/p/w500/9PqD3wSIjntyJDBzMNuxuKHwpUD.jpg',
        imdbRating: 8.6,
        year: 2022,
        trendingScore: 9.2,
        watchCount: 15,
        description: 'A young chef from the fine dining world returns to Chicago to run his family\'s Italian beef sandwich shop.',
        director: 'Christopher Storer',
        cast: ['Jeremy Allen White', 'Ayo Edebiri', 'Ebon Moss-Bachrach'],
      ),
      MediaItem(
        id: _uuid.v4(),
        title: 'Poor Things',
        type: MediaType.movie,
        genre: Genre.drama,
        platform: 'Hulu',
        posterImage: 'https://image.tmdb.org/t/p/w500/kCGlIMHnOm8JPXq3rXM6c5wMxcT.jpg',
        imdbRating: 7.8,
        year: 2023,
        trendingScore: 8.7,
        watchCount: 8,
        description: 'The incredible tale about the fantastical evolution of Bella Baxter.',
        director: 'Yorgos Lanthimos',
        cast: ['Emma Stone', 'Mark Ruffalo', 'Willem Dafoe'],
      ),
      MediaItem(
        id: _uuid.v4(),
        title: 'True Detective: Night Country',
        type: MediaType.show,
        genre: Genre.thriller,
        platform: 'Max',
        posterImage: 'https://image.tmdb.org/t/p/w500/8b8R8l88Qje9dn9OE8PY05Nxl1X.jpg',
        imdbRating: 8.1,
        year: 2024,
        trendingScore: 8.9,
        watchCount: 12,
      ),
      MediaItem(
        id: _uuid.v4(),
        title: 'Oppenheimer',
        type: MediaType.movie,
        genre: Genre.drama,
        platform: 'Peacock',
        posterImage: 'https://image.tmdb.org/t/p/w500/8GxTt6qjG5sF5b7r4v1Xr5YYLwC.jpg',
        imdbRating: 8.3,
        year: 2023,
        trendingScore: 9.1,
        watchCount: 19,
      ),
      MediaItem(
        id: _uuid.v4(),
        title: 'Spider‑Man: Across the Spider‑Verse',
        type: MediaType.movie,
        genre: Genre.sciFi,
        platform: 'Netflix',
        posterImage: 'https://image.tmdb.org/t/p/w500/8Vt6mWEReuy4Of61Lnj5Xj704m8.jpg',
        imdbRating: 8.7,
        year: 2023,
        trendingScore: 9.0,
        watchCount: 21,
      ),
    ];

    // Initialize sample activities
    final friend1 = _friends[0];
    final friend2 = _friends[1];
    final friend3 = _friends[2];
    final friend4 = _friends[3];

    _activities = [
      WatchingActivity(
        id: _uuid.v4(),
        userId: friend1.id,
        media: _trendingContent[0],
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        isLive: true,
        progress: 0.7,
        reactions: [
          Reaction(id: _uuid.v4(), userId: friend2.id, type: ReactionType.fire),
          Reaction(id: _uuid.v4(), userId: friend3.id, type: ReactionType.like),
        ],
        comments: [
          Comment(id: _uuid.v4(), userId: friend2.id, text: 'This is absolutely incredible! 🔥'),
          Comment(id: _uuid.v4(), userId: friend3.id, text: 'Jeremy Allen White is amazing in this'),
        ],
      ),
      WatchingActivity(
        id: _uuid.v4(),
        userId: friend2.id,
        media: _trendingContent[1],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        reactions: [
          Reaction(id: _uuid.v4(), userId: friend1.id, type: ReactionType.like),
          Reaction(id: _uuid.v4(), userId: friend4.id, type: ReactionType.thumbsUp),
        ],
        comments: [
          Comment(id: _uuid.v4(), userId: friend1.id, text: 'Emma Stone is phenomenal!'),
        ],
      ),
      WatchingActivity(
        id: _uuid.v4(),
        userId: friend3.id,
        media: _trendingContent[2],
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        reactions: [
          Reaction(id: _uuid.v4(), userId: friend1.id, type: ReactionType.wow),
          Reaction(id: _uuid.v4(), userId: friend2.id, type: ReactionType.fire),
        ],
      ),
      WatchingActivity(
        id: _uuid.v4(),
        userId: friend4.id,
        media: _trendingContent[3],
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      WatchingActivity(
        id: _uuid.v4(),
        userId: _currentUser.id,
        media: _trendingContent[4],
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];

    // Initialize watch parties
    _watchParties = [
      WatchParty(
        id: _uuid.v4(),
        hostId: friend1.id,
        hostName: friend1.name,
        media: MediaItem(
          id: _uuid.v4(),
          title: 'Dune: Part Two',
          type: MediaType.movie,
          genre: Genre.sciFi,
          platform: 'Max',
          posterImage: 'https://image.tmdb.org/t/p/w500/8b8R8l88Qje9dn9OE8PY05Nxl1X.jpg',
          imdbRating: 8.2,
          year: 2024,
        ),
        participants: [friend2.id, friend3.id],
        scheduledFor: DateTime.now().add(const Duration(hours: 1)),
      ),
    ];

    // Initialize demo account
    _accounts['demo@fwb.app'] = 'demo1234';
    _accountNames['demo@fwb.app'] = _currentUser.name;

    // Initialize social data
    final socialRequest1 = RecommendationRequest(
      id: _uuid.v4(),
      userId: _currentUser.id,
      genreTags: ['Action', 'Sci-Fi'],
      yearRange: YearRange(startYear: 2020, endYear: 2024),
      movieIndustry: MovieIndustry.hollywood,
      note: 'Looking for something exciting and futuristic',
    );

    final socialRequest2 = RecommendationRequest(
      id: _uuid.v4(),
      userId: friend1.id,
      genreTags: ['Drama', 'Thriller'],
      yearRange: YearRange(startYear: 2015, endYear: 2023),
      movieIndustry: MovieIndustry.both,
      note: 'Need a good series to binge watch',
    );

    _recommendationRequests = [socialRequest1, socialRequest2];

    _recommendations = [
      Recommendation(
        id: _uuid.v4(),
        requestId: socialRequest1.id,
        mediaItemId: _trendingContent[0].id,
        recommenderId: friend1.id,
        likeCount: 3,
        likerIds: [friend1.id, friend2.id, friend3.id],
      ),
      Recommendation(
        id: _uuid.v4(),
        requestId: socialRequest1.id,
        mediaItemId: _trendingContent[1].id,
        recommenderId: friend2.id,
        likeCount: 2,
        likerIds: [friend1.id, friend2.id],
      ),
      Recommendation(
        id: _uuid.v4(),
        requestId: socialRequest2.id,
        mediaItemId: _trendingContent[2].id,
        recommenderId: _currentUser.id,
        likeCount: 1,
        likerIds: [_currentUser.id],
      ),
    ];
  }

  Future<void> _loadPersistedAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('userEmail') ?? '';
    final password = prefs.getString('userPassword') ?? '';
    final name = prefs.getString('userName') ?? '';

    if (email.isNotEmpty && password.isNotEmpty) {
      _currentUser = UserProfile(
        id: _currentUser.id,
        name: name.isNotEmpty ? name : 'You',
        favoriteGenres: _currentUser.favoriteGenres,
        avatarURL: _currentUser.avatarURL,
      );
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  // Theme methods
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setTheme(ThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners();
  }

  void setAmbientColor(AmbientColor color) {
    _ambientColor = color;
    notifyListeners();
  }

  // Activity methods
  void addWatchingActivity(MediaItem media) {
    final newActivity = WatchingActivity(
      id: _uuid.v4(),
      userId: _currentUser.id,
      media: media,
      createdAt: DateTime.now(),
    );
    _activities.insert(0, newActivity);
    _checkAndUnlockAchievements();
    notifyListeners();
  }

  void addReaction(String activityId, ReactionType type) {
    final activityIndex = _activities.indexWhere((a) => a.id == activityId);
    if (activityIndex == -1) return;

    final activity = _activities[activityIndex];
    final reactions = List<Reaction>.from(activity.reactions);
    reactions.add(Reaction(
      id: _uuid.v4(),
      userId: _currentUser.id,
      type: type,
    ));

    _activities[activityIndex] = WatchingActivity(
      id: activity.id,
      userId: activity.userId,
      media: activity.media,
      createdAt: activity.createdAt,
      reactions: reactions,
      comments: activity.comments,
      watchPartyId: activity.watchPartyId,
      isLive: activity.isLive,
      progress: activity.progress,
    );
    notifyListeners();
  }

  void addComment(String activityId, String text) {
    final activityIndex = _activities.indexWhere((a) => a.id == activityId);
    if (activityIndex == -1) return;

    final activity = _activities[activityIndex];
    final comments = List<Comment>.from(activity.comments);
    comments.add(Comment(
      id: _uuid.v4(),
      userId: _currentUser.id,
      text: text,
    ));

    _activities[activityIndex] = WatchingActivity(
      id: activity.id,
      userId: activity.userId,
      media: activity.media,
      createdAt: activity.createdAt,
      reactions: activity.reactions,
      comments: comments,
      watchPartyId: activity.watchPartyId,
      isLive: activity.isLive,
      progress: activity.progress,
    );
    notifyListeners();
  }

  // Watch party methods
  void createWatchParty(MediaItem media, DateTime scheduledFor) {
    final party = WatchParty(
      id: _uuid.v4(),
      hostId: _currentUser.id,
      hostName: _currentUser.name,
      media: media,
      participants: [_currentUser.id],
      scheduledFor: scheduledFor,
      maxParticipants: 10,
      progress: 0.0,
    );
    _watchParties.add(party);
    _unlockAchievement(AchievementType.trendsetter);
    notifyListeners();
  }

  void joinWatchParty(String partyId) {
    final partyIndex = _watchParties.indexWhere((p) => p.id == partyId);
    if (partyIndex == -1) return;

    final party = _watchParties[partyIndex];
    if (!party.participants.contains(_currentUser.id)) {
      final participants = List<String>.from(party.participants);
      participants.add(_currentUser.id);
      
      _watchParties[partyIndex] = WatchParty(
        id: party.id,
        name: party.name,
        hostId: party.hostId,
        hostName: party.hostName,
        media: party.media,
        participants: participants,
        scheduledFor: party.scheduledFor,
        startTime: party.startTime,
        isLive: party.isLive,
        maxParticipants: party.maxParticipants,
        progress: party.progress,
      );
      notifyListeners();
    }
  }

  // Achievement methods
  void _checkAndUnlockAchievements() {
    // Check for first watch
    final userActivities = _activities.where((a) => a.userId == _currentUser.id);
    if (userActivities.length == 1) {
      _unlockAchievement(AchievementType.firstWatch);
    }

    // Check for genre explorer
    final watchedGenres = userActivities.map((a) => a.media.genre).toSet();
    if (watchedGenres.length >= 5) {
      _unlockAchievement(AchievementType.genreExplorer);
    }

    // Check for social butterfly
    if (_friends.length >= 10) {
      _unlockAchievement(AchievementType.socialButterfly);
    }
  }

  void _unlockAchievement(AchievementType type) {
    final hasAchievement = _achievements.any((a) => a.type == type);
    if (!hasAchievement) {
      _achievements.add(Achievement(
        id: _uuid.v4(),
        type: type,
      ));
    }
  }

  // Friend methods
  String generateShareCodeForCurrentUser() {
    return 'fwb:user:${_currentUser.id}';
  }

  bool addFriend(String shareCode) {
    if (!shareCode.startsWith('fwb:user:')) return false;
    
    final parts = shareCode.split(':');
    if (parts.length != 3) return false;
    
    final userId = parts[2];
    if (_friends.any((f) => f.id == userId)) return true;
    
    final newFriend = Friend(
      id: userId,
      name: 'Friend ${_friends.length + 1}',
    );
    _friends.add(newFriend);
    notifyListeners();
    return true;
  }

  List<Friend> getFriendsWatching(MediaItem media) {
    final watchingFriends = _activities
        .where((a) => a.media.title == media.title)
        .map((a) => _friends.where((f) => f.id == a.userId).firstOrNull)
        .where((f) => f != null)
        .cast<Friend>()
        .toSet()
        .toList();
    return watchingFriends;
  }

  double calculateLikeProbability(MediaItem media) {
    final genreMatch = _currentUser.favoriteGenres.contains(media.genre) ? 0.4 : 0.1;
    final ratingBonus = (media.imdbRating ?? 5.0) / 10.0 * 0.6;
    return (genreMatch + ratingBonus).clamp(0.0, 1.0);
  }

  int getReactionCount(String activityId, ReactionType type) {
    final activity = _activities.where((a) => a.id == activityId).firstOrNull;
    if (activity == null) return 0;
    return activity.reactions.where((r) => r.type == type).length;
  }

  bool hasUserReacted(String activityId, ReactionType type) {
    final activity = _activities.where((a) => a.id == activityId).firstOrNull;
    if (activity == null) return false;
    return activity.reactions.any((r) => r.userId == _currentUser.id && r.type == type);
  }

  // Social recommendation methods
  void addRecommendationRequest(RecommendationRequest request) {
    _recommendationRequests.add(request);
    notifyListeners();
  }

  void addRecommendation(Recommendation recommendation, String requestId) {
    _recommendations.add(recommendation);
    notifyListeners();
  }

  void toggleRecommendationLike(String recommendationId) {
    final recommendationIndex = _recommendations.indexWhere((r) => r.id == recommendationId);
    if (recommendationIndex == -1) return;

    final recommendation = _recommendations[recommendationIndex];
    final likerIds = List<String>.from(recommendation.likerIds);
    int likeCount = recommendation.likeCount;

    if (likerIds.contains(_currentUser.id)) {
      // Unlike
      likerIds.remove(_currentUser.id);
      likeCount = (likeCount - 1).clamp(0, double.infinity).toInt();
    } else {
      // Like
      likerIds.add(_currentUser.id);
      likeCount += 1;
    }

    _recommendations[recommendationIndex] = recommendation.copyWith(
      likeCount: likeCount,
      likerIds: likerIds,
    );
    notifyListeners();
  }

  // Auth methods
  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) return false;

    String name;
    if (_accounts.containsKey(email) && _accounts[email] == password) {
      // Existing account
      name = _accountNames[email] ?? _currentUser.name;
    } else {
      // Create ephemeral account for demo
      _accounts[email] = password;
      name = email.split('@').first;
      name = name[0].toUpperCase() + name.substring(1);
      _accountNames[email] = name;
    }

    _currentUser = UserProfile(
      id: _currentUser.id,
      name: name,
      favoriteGenres: _currentUser.favoriteGenres,
      avatarURL: _currentUser.avatarURL,
    );
    _isAuthenticated = true;

    // Save credentials
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userEmail', email);
    await prefs.setString('userPassword', password);
    await prefs.setString('userName', name);

    notifyListeners();
    return true;
  }

  Future<bool> register(String name, String email, String password) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) return false;
    if (_accounts.containsKey(email)) return false;

    _accounts[email] = password;
    _accountNames[email] = name;
    
    _currentUser = UserProfile(
      id: _uuid.v4(),
      name: name,
      favoriteGenres: _currentUser.favoriteGenres,
    );
    _isAuthenticated = true;

    // Save credentials
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userEmail', email);
    await prefs.setString('userPassword', password);
    await prefs.setString('userName', name);

    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    
    // Clear persistent credentials
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userEmail');
    await prefs.remove('userPassword');
    await prefs.remove('userName');
    
    // Reset to default user
    _currentUser = UserProfile(
      id: _uuid.v4(),
      name: 'You',
      favoriteGenres: {Genre.action, Genre.drama, Genre.sciFi, Genre.thriller},
    );
    
    notifyListeners();
  }

  // Additional getters for new UI
  List<RecommendationRequest> get myRecommendationRequestsSimple => 
      _recommendationRequests.where((r) => r.userId == _currentUser.id).toList();
  
  List<RecommendationRequest> get friendsRecommendationRequestsSimple => 
      _recommendationRequests.where((r) => r.userId != _currentUser.id).toList();
  
  // Get recommendations for a specific request
  List<Recommendation> getRecommendationsForRequest(String requestId) {
    return _recommendations.where((r) => r.requestId == requestId).toList();
  }
  
  // Watchlist management
  List<MediaItem> getUserWatchlist() {
    // Return sample watchlist for now
    return [
      MediaItem(
        id: 'w1',
        title: 'The Batman',
        type: MediaType.movie,
        genre: Genre.action,
        platform: 'HBO Max',
        imdbRating: 8.2,
        year: 2022,
      ),
      MediaItem(
        id: 'w2', 
        title: 'Everything Everywhere All at Once',
        type: MediaType.movie,
        genre: Genre.sciFi,
        platform: 'A24',
        imdbRating: 8.7,
        year: 2022,
      ),
    ];
  }
  
  void addToWatchlist(MediaItem item) {
    // Implementation for adding to watchlist
    notifyListeners();
  }
  
  void removeFromWatchlist(String itemId) {
    // Implementation for removing from watchlist
    notifyListeners();
  }
  
  // Watch parties
  List<WatchParty> getUpcomingWatchParties() {
    return _watchParties.where((p) => p.scheduledFor.isAfter(DateTime.now())).toList();
  }
  
  // Helper methods
  Friend? getFriendById(String id) {
    return _friends.where((f) => f.id == id).firstOrNull;
  }
  
  // Recommendation interactions
  bool hasLikedRecommendation(String recommendationId) {
    final recommendation = _recommendations.where((r) => r.id == recommendationId).firstOrNull;
    return recommendation?.likerIds.contains(_currentUser.id) ?? false;
  }

  // Load comprehensive sample data for demonstration
  void loadSampleData() {
    // Sample friends with realistic profiles
    _friends = [
      Friend(id: 'friend_1', name: 'Sarah Chen'),
      Friend(id: 'friend_2', name: 'Marcus Williams'),
      Friend(id: 'friend_3', name: 'Elena Rodriguez'),
      Friend(id: 'friend_4', name: 'David Kim'),
      Friend(id: 'friend_5', name: 'Maya Patel'),
      Friend(id: 'friend_6', name: 'Alex Thompson'),
      Friend(id: 'friend_7', name: 'Zoe Martinez'),
      Friend(id: 'friend_8', name: 'Ryan O\'Connor'),
    ];

    // Popular trending content with real titles
    _trendingContent = [
      MediaItem(
        id: 'trending_1',
        title: 'The Bear',
        type: MediaType.show,
        genre: Genre.drama,
        platform: 'Hulu',
        imdbRating: 8.7,
        year: 2022,
        description: 'A young chef from the fine dining world comes home to Chicago to run his family sandwich shop.',
        trendingScore: 95.0,
      ),
      MediaItem(
        id: 'trending_2',
        title: 'Dune: Part Two',
        type: MediaType.movie,
        genre: Genre.sciFi,
        platform: 'HBO Max',
        imdbRating: 8.9,
        year: 2024,
        description: 'Paul Atreides unites with Chani and the Fremen while seeking revenge against the conspirators.',
        trendingScore: 92.0,
      ),
      MediaItem(
        id: 'trending_3',
        title: 'The Last of Us',
        type: MediaType.show,
        genre: Genre.thriller,
        platform: 'HBO Max',
        imdbRating: 8.8,
        year: 2023,
        description: 'After a global pandemic destroys civilization, a hardened survivor takes charge of a 14-year-old girl.',
        trendingScore: 90.0,
      ),
      MediaItem(
        id: 'trending_4',
        title: 'Everything Everywhere All at Once',
        type: MediaType.movie,
        genre: Genre.action,
        platform: 'A24',
        imdbRating: 8.1,
        year: 2022,
        description: 'A Chinese-American woman gets swept up in an insane adventure in which she alone can save the world.',
        trendingScore: 88.0,
      ),
      MediaItem(
        id: 'trending_5',
        title: 'Wednesday',
        type: MediaType.show,
        genre: Genre.mystery,
        platform: 'Netflix',
        imdbRating: 8.2,
        year: 2022,
        description: 'Wednesday Addams is sent to Nevermore Academy, where she attempts to master her psychic powers.',
        trendingScore: 86.0,
      ),
    ];

    // Realistic watching activities from friends
    _activities = [
      WatchingActivity(
        id: 'activity_1',
        userId: 'friend_1',
        media: _trendingContent[0], // The Bear
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isLive: true,
        reactions: [
          Reaction(id: 'r1', userId: 'friend_2', type: ReactionType.love),
          Reaction(id: 'r2', userId: 'friend_3', type: ReactionType.fire),
        ],
        comments: [
          Comment(
            id: 'c1',
            userId: 'friend_2',
            text: 'This show is incredible! The kitchen scenes are so intense 👨‍🍳',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ],
      ),
      WatchingActivity(
        id: 'activity_2',
        userId: 'friend_4',
        media: _trendingContent[1], // Dune: Part Two
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isLive: false,
        reactions: [
          Reaction(id: 'r3', userId: 'friend_1', type: ReactionType.wow),
          Reaction(id: 'r4', userId: 'friend_5', type: ReactionType.love),
          Reaction(id: 'r5', userId: 'friend_6', type: ReactionType.fire),
        ],
        comments: [
          Comment(
            id: 'c2',
            userId: 'friend_1',
            text: 'The cinematography in this movie is absolutely stunning! 🏜️',
            createdAt: DateTime.now().subtract(const Duration(hours: 18)),
          ),
          Comment(
            id: 'c3',
            userId: 'friend_5',
            text: 'Hans Zimmer\'s score gives me chills every time',
            createdAt: DateTime.now().subtract(const Duration(hours: 16)),
          ),
        ],
      ),
      WatchingActivity(
        id: 'activity_3',
        userId: 'friend_3',
        media: _trendingContent[2], // The Last of Us
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        isLive: false,
        reactions: [
          Reaction(id: 'r6', userId: 'friend_7', type: ReactionType.love),
        ],
        comments: [],
      ),
      WatchingActivity(
        id: 'activity_4',
        userId: 'friend_6',
        media: _trendingContent[3], // Everything Everywhere All at Once
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isLive: false,
        reactions: [
          Reaction(id: 'r7', userId: 'friend_1', type: ReactionType.wow),
          Reaction(id: 'r8', userId: 'friend_2', type: ReactionType.love),
        ],
        comments: [
          Comment(
            id: 'c4',
            userId: 'friend_1',
            text: 'Mind-bending and heartwarming at the same time. A masterpiece! 🌟',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      ),
    ];

    // Sample recommendation requests
    _recommendationRequests = [
      RecommendationRequest(
        id: 'req_1',
        userId: _currentUser.id,
        genreTags: ['Sci-Fi', 'Action'],
        yearRange: YearRange(startYear: 2020, endYear: 2024),
        movieIndustry: MovieIndustry.hollywood,
        note: 'Looking for something mind-bending like Inception or Interstellar',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      RecommendationRequest(
        id: 'req_2',
        userId: 'friend_1',
        genreTags: ['Comedy', 'Romance'],
        yearRange: YearRange(startYear: 2018, endYear: 2024),
        movieIndustry: MovieIndustry.both,
        note: 'Need something light and fun for date night!',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      RecommendationRequest(
        id: 'req_3',
        userId: 'friend_4',
        genreTags: ['Horror', 'Thriller'],
        yearRange: YearRange(startYear: 2015, endYear: 2024),
        movieIndustry: MovieIndustry.hollywood,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    // Sample recommendations for requests
    _recommendations = [
      Recommendation(
        id: 'rec_1',
        requestId: 'req_1',
        mediaItemId: 'trending_2', // Dune: Part Two
        recommenderId: 'friend_1',
        likeCount: 5,
        likerIds: ['friend_2', 'friend_3', 'friend_4', 'friend_5', _currentUser.id],
      ),
      Recommendation(
        id: 'rec_2',
        requestId: 'req_1',
        mediaItemId: 'trending_4', // Everything Everywhere All at Once
        recommenderId: 'friend_3',
        likeCount: 3,
        likerIds: ['friend_1', 'friend_6', _currentUser.id],
      ),
      Recommendation(
        id: 'rec_3',
        requestId: 'req_2',
        mediaItemId: 'trending_5', // Wednesday (as a genre mix)
        recommenderId: 'friend_2',
        likeCount: 2,
        likerIds: ['friend_4', 'friend_7'],
      ),
    ];

    // Sample watch parties
    _watchParties = [
      WatchParty(
        id: 'party_1',
        name: 'The Bear Finale Watch Party',
        hostId: 'friend_1',
        hostName: 'Sarah Chen',
        media: _trendingContent[0],
        participants: ['friend_2', 'friend_3', _currentUser.id],
        scheduledFor: DateTime.now().add(const Duration(hours: 3)),
        maxParticipants: 8,
      ),
      WatchParty(
        id: 'party_2',
        name: 'Dune Marathon Night',
        hostId: 'friend_4',
        hostName: 'David Kim',
        media: _trendingContent[1],
        participants: ['friend_1', 'friend_5', 'friend_6'],
        scheduledFor: DateTime.now().add(const Duration(days: 1)),
        maxParticipants: 6,
      ),
    ];

    // Sample achievements
    _achievements = [
      Achievement(
        id: 'ach_1',
        type: AchievementType.genreExplorer,
        unlockedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Achievement(
        id: 'ach_2',
        type: AchievementType.socialButterfly,
        unlockedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Achievement(
        id: 'ach_3',
        type: AchievementType.critic,
        unlockedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    notifyListeners();
  }
}
