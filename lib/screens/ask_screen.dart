import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_data_store.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/primary_button.dart';
import '../models/social_models.dart';
import '../models/media.dart';
import 'create_recommendation_request_screen.dart';

class AskScreen extends StatefulWidget {
  const AskScreen({super.key});

  @override
  State<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends State<AskScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataStore>(
      builder: (context, store, child) {
        final brightness = store.brightness;
        
        return Scaffold(
          backgroundColor: AppTheme.appBackground(brightness),
          body: CustomScrollView(
            slivers: [
              // Dynamic Header with SliverAppBar
              SliverAppBar(
                expandedHeight: 140,
                floating: true,
                pinned: false,
                backgroundColor: AppTheme.appBackground(brightness),
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.help_center,
                                  color: Colors.blue,
                                  size: 28,
                                ),
                                const SizedBox(width: AppTheme.sm),
                                Text(
                                  'Ask Friends',
                                  style: AppTheme.largeTitle.copyWith(
                                    color: AppTheme.primaryText(brightness),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.xs),
                            Text(
                              'Get personalized recommendations from your circle',
                              style: AppTheme.body.copyWith(
                                color: AppTheme.secondaryText(brightness),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.lg),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Ask Your Friends CTA
                    _buildAskFriendsCTA(store, brightness),
                    const SizedBox(height: AppTheme.xl),
                    
                    // Your Polls Section
                    _buildYourPolls(store, brightness),
                    const SizedBox(height: AppTheme.xl),
                    
                    // Friends' Polls Section
                    _buildFriendsPolls(store, brightness),
                    const SizedBox(height: AppTheme.xl),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAskFriendsCTA(AppDataStore store, Brightness brightness) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            50 * (1 - _animationController.value),
          ),
          child: Opacity(
            opacity: _animationController.value,
            child: GlassCard(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.md),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.psychology,
                      size: 40,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: AppTheme.lg),
                  Text(
                    'What Should I Watch?',
                    style: AppTheme.title1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText(brightness),
                    ),
                  ),
                  const SizedBox(height: AppTheme.sm),
                  Text(
                    'Create a poll and let your friends recommend the perfect movie or show for your mood',
                    style: AppTheme.body.copyWith(
                      color: AppTheme.secondaryText(brightness),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.xl),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      title: 'Ask Your Friends',
                      onPressed: () => _createRecommendationPoll(store),
                      icon: Icons.add_circle_outline,
                      height: AppTheme.buttonHeightLarge,

                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildYourPolls(AppDataStore store, Brightness brightness) {
    final myRequests = store.myRecommendationRequestsSimple;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.poll,
              color: AppTheme.primaryText(brightness),
              size: 24,
            ),
            const SizedBox(width: AppTheme.sm),
            Text(
              'Your Polls',
              style: AppTheme.title2.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText(brightness),
              ),
            ),
            const Spacer(),
            if (myRequests.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.sm,
                  vertical: AppTheme.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: Text(
                  '${myRequests.length}',
                  style: AppTheme.caption1.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppTheme.lg),
        
        if (myRequests.isEmpty)
          _buildEmptyState(
            icon: Icons.poll_outlined,
            title: 'No polls yet',
            description: 'Create your first poll to get personalized recommendations from friends',
            brightness: brightness,
          )
        else
          ...myRequests.take(3).map((request) => Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.md),
            child: _buildPollCard(request, store, brightness, isOwnPoll: true),
          )),
        
        if (myRequests.length > 3)
          TextButton(
            onPressed: () {
              // Navigate to full list
            },
            child: Text(
              'View all ${myRequests.length} polls',
              style: AppTheme.callout.copyWith(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFriendsPolls(AppDataStore store, Brightness brightness) {
    final friendsRequests = store.friendsRecommendationRequestsSimple;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.people,
              color: AppTheme.primaryText(brightness),
              size: 24,
            ),
            const SizedBox(width: AppTheme.sm),
            Text(
              'Friends\' Polls',
              style: AppTheme.title2.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText(brightness),
              ),
            ),
            const Spacer(),
            if (friendsRequests.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.sm,
                  vertical: AppTheme.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: Text(
                  '${friendsRequests.length}',
                  style: AppTheme.caption1.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppTheme.lg),
        
        if (friendsRequests.isEmpty)
          _buildEmptyState(
            icon: Icons.people_outline,
            title: 'No active polls',
            description: 'Your friends haven\'t created any polls yet. Be the first to ask!',
            brightness: brightness,
          )
        else
          ...friendsRequests.map((request) => Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.md),
            child: _buildPollCard(request, store, brightness, isOwnPoll: false),
          )),
      ],
    );
  }

  Widget _buildPollCard(RecommendationRequest request, AppDataStore store, 
      Brightness brightness, {required bool isOwnPoll}) {
    final recommendations = store.getRecommendationsForRequest(request.id);
    final topRecommendations = recommendations.take(3).toList();
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isOwnPoll 
                    ? Colors.blue.withOpacity(0.2)
                    : Colors.green.withOpacity(0.2),
                child: Text(
                  isOwnPoll 
                      ? 'You'[0] 
                      : store.getFriendById(request.userId)?.name[0] ?? '?',
                  style: AppTheme.caption1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isOwnPoll ? Colors.blue : Colors.green,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOwnPoll 
                          ? 'Your Poll'
                          : store.getFriendById(request.userId)?.name ?? 'Friend',
                      style: AppTheme.callout.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryText(brightness),
                      ),
                    ),
                    Text(
                      _formatTimeAgo(request.createdAt),
                      style: AppTheme.caption1.copyWith(
                        color: AppTheme.secondaryText(brightness),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.sm,
                  vertical: AppTheme.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.thumb_up,
                      size: 12,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: AppTheme.xs),
                    Text(
                        '${recommendations.fold(0, (sum, r) => sum + r.likeCount)}',
                      style: AppTheme.caption1.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.md),
          
          // Poll Question & Details
          if (request.note != null && request.note!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(AppTheme.sm),
              decoration: BoxDecoration(
                color: AppTheme.minimalSurface(brightness),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Text(
                request.note!,
                style: AppTheme.body.copyWith(
                  color: AppTheme.primaryText(brightness),
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(AppTheme.sm),
              decoration: BoxDecoration(
                color: AppTheme.minimalSurface(brightness),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Text(
                'Looking for ${request.genreTags.join(", ")} recommendations',
                style: AppTheme.body.copyWith(
                  color: AppTheme.primaryText(brightness),
                ),
              ),
            ),
          
          const SizedBox(height: AppTheme.md),
          
          // Genre Tags
          Wrap(
            spacing: AppTheme.xs,
            runSpacing: AppTheme.xs,
            children: request.genreTags.take(3).map((genre) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.sm,
                  vertical: AppTheme.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: Text(
                  genre,
                  style: AppTheme.caption1.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
          
          if (topRecommendations.isNotEmpty) ...[
            const SizedBox(height: AppTheme.lg),
            
            // Top Recommendations Leaderboard
            Row(
              children: [
                Icon(
                  Icons.leaderboard,
                  size: 16,
                  color: AppTheme.secondaryText(brightness),
                ),
                const SizedBox(width: AppTheme.xs),
                Text(
                  'Top Recommendations',
                  style: AppTheme.caption1.copyWith(
                    color: AppTheme.secondaryText(brightness),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.sm),
            
            ...topRecommendations.asMap().entries.map((entry) {
              final index = entry.key;
              final recommendation = entry.value;
              final maxLikes = topRecommendations.first.likeCount;
              final percentage = maxLikes > 0 ? recommendation.likeCount / maxLikes : 0.0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.sm),
                child: _buildRecommendationBar(
                  recommendation, 
                  percentage, 
                  index + 1, 
                  store, 
                  brightness,
                  isOwnPoll: isOwnPoll,
                ),
              );
            }),
          ],
          
          const SizedBox(height: AppTheme.md),
          
          // Action Buttons
          Row(
            children: [
              if (!isOwnPoll)
                Expanded(
                  child: PrimaryButton(
                    title: 'Add Suggestion',
                    onPressed: () => _addSuggestion(request),
                    icon: Icons.add,
                    height: 36,
                  ),
                ),
              if (!isOwnPoll)
                const SizedBox(width: AppTheme.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _viewFullPoll(request),
                  icon: Icon(
                    Icons.visibility,
                    size: 16,
                    color: AppTheme.primaryText(brightness),
                  ),
                  label: Text(
                    'View All',
                    style: AppTheme.caption1.copyWith(
                      color: AppTheme.primaryText(brightness),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    side: BorderSide(
                      color: AppTheme.minimalStroke(brightness),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationBar(Recommendation recommendation, double percentage, 
      int rank, AppDataStore store, Brightness brightness, {required bool isOwnPoll}) {
    final medal = rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉';
    
    return Row(
      children: [
        Text(
          medal,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: AppTheme.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child:                       Text(
                        'Movie ${recommendation.mediaItemId}',
                      style: AppTheme.callout.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryText(brightness),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${recommendation.likeCount}',
                    style: AppTheme.callout.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.xs),
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.minimalSurface(brightness),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  widthFactor: percentage,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: rank == 1 
                            ? [Colors.amber, Colors.orange] 
                            : rank == 2 
                                ? [AppTheme.secondaryText(brightness), Colors.blueGrey]
                                : [Colors.brown, Colors.orange.shade800],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isOwnPoll) ...[
          const SizedBox(width: AppTheme.sm),
          GestureDetector(
            onTap: () => store.toggleRecommendationLike(recommendation.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(AppTheme.xs),
              decoration: BoxDecoration(
                color: store.hasLikedRecommendation(recommendation.id)
                    ? Colors.red.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Icon(
                store.hasLikedRecommendation(recommendation.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                size: 16,
                color: store.hasLikedRecommendation(recommendation.id)
                    ? Colors.red
                    : AppTheme.secondaryText(brightness),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
    required Brightness brightness,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.xl),
      child: Column(
        children: [
          Icon(
            icon,
            size: 64,
            color: AppTheme.secondaryText(brightness).withOpacity(0.5),
          ),
          const SizedBox(height: AppTheme.lg),
          Text(
            title,
            style: AppTheme.title3.copyWith(
              color: AppTheme.primaryText(brightness),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.sm),
          Text(
            description,
            style: AppTheme.body.copyWith(
              color: AppTheme.secondaryText(brightness),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _createRecommendationPoll(AppDataStore store) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateRecommendationRequestScreen(),
      ),
    );
  }

  void _addSuggestion(RecommendationRequest request) {
    // TODO: Navigate to add suggestion screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add suggestion feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _viewFullPoll(RecommendationRequest request) {
    // TODO: Navigate to full poll view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Full poll view coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
