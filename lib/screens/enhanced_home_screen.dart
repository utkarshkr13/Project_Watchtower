import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/app_data_store.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/media_card.dart';
import '../models/genre.dart';
import '../models/media.dart';

class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen> 
    with TickerProviderStateMixin {
  Genre? _selectedGenre;
  bool _isRefreshing = false;
  late AnimationController _headerAnimationController;
  late AnimationController _feedAnimationController;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _feedAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _feedAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _feedAnimationController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _isRefreshing = true;
    });
    
    await Future.delayed(const Duration(milliseconds: 800));
    
    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataStore>(
      builder: (context, store, child) {
        final brightness = store.brightness;
        final filteredActivities = _getFilteredActivities(store);
        
        return Scaffold(
          backgroundColor: AppTheme.appBackground(brightness),
          body: RefreshIndicator(
            onRefresh: _refresh,
            color: AppTheme.primaryColor(brightness),
            backgroundColor: AppTheme.appSurface(brightness),
            child: CustomScrollView(
              slivers: [
                _buildModernHeader(store, brightness),
                _buildTrendingSection(store, brightness),
                _buildActivityFeed(store, filteredActivities, brightness),
              ],
            ),
          ),
        );
      },
    );
  }

  // Modern header with design system styling
  Widget _buildModernHeader(AppDataStore store, Brightness brightness) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _headerAnimationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - _headerAnimationController.value)),
            child: Opacity(
              opacity: _headerAnimationController.value,
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.gridMargin, 
                  60, 
                  AppTheme.gridMargin, 
                  AppTheme.lg
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getPersonalizedGreeting(),
                            style: AppTheme.heading1.copyWith(
                              color: AppTheme.primaryText(brightness),
                            ),
                          ),
                          const SizedBox(height: AppTheme.xs),
                          Text(
                            'Discover what\'s trending with friends',
                            style: AppTheme.body.copyWith(
                              color: AppTheme.secondaryText(brightness),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Profile avatar with modern styling
                    GestureDetector(
                      onTap: () {
                        DefaultTabController.of(context)?.animateTo(4);
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.appSurface(brightness),
                          boxShadow: const [AppTheme.cardShadow],
                        ),
                        child: Center(
                          child: Text(
                            store.currentUser.name[0].toUpperCase(),
                            style: AppTheme.heading2.copyWith(
                              color: AppTheme.primaryColor(brightness),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Trending section with gradient cards
  Widget _buildTrendingSection(AppDataStore store, Brightness brightness) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _headerAnimationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 30 * (1 - _headerAnimationController.value)),
            child: Opacity(
              opacity: _headerAnimationController.value,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.gridMargin),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.sm),
                          decoration: BoxDecoration(
                            color: AppTheme.lightSecondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: Icon(
                            Icons.trending_up,
                            color: AppTheme.lightSecondary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppTheme.sm),
                        Text(
                          'What\'s Hot?',
                          style: AppTheme.heading2.copyWith(
                            color: AppTheme.primaryText(brightness),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.lg),
                  
                  SizedBox(
                    height: AppTheme.trendingCardHeight,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.gridMargin),
                      scrollDirection: Axis.horizontal,
                      itemCount: _getTrendingItems(store).length,
                      separatorBuilder: (context, index) => const SizedBox(width: AppTheme.gridGutter),
                      itemBuilder: (context, index) {
                        final item = _getTrendingItems(store)[index];
                        return _buildTrendingCard(item, index, brightness);
                      },
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.xl),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Trending card with design system styling
  Widget _buildTrendingCard(Map<String, dynamic> item, int index, Brightness brightness) {
    return GestureDetector(
      onTap: () => _handleTrendingCardTap(item),
      child: Container(
        width: AppTheme.trendingCardWidth,
        decoration: AppTheme.trendingCardDecoration(index),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.xs),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const Spacer(),
                  if (item['isLive'] == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ).animate(onPlay: (controller) => controller.repeat())
                           .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2))
                           .then(delay: const Duration(milliseconds: 500))
                           .scale(begin: const Offset(1.2, 1.2), end: const Offset(0.8, 0.8)),
                          const SizedBox(width: 4),
                          Text(
                            'LIVE',
                            style: AppTheme.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              const Spacer(),
              
              Text(
                item['category'] as String,
                style: AppTheme.caption.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppTheme.xs),
              Text(
                item['title'] as String,
                style: AppTheme.heading2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppTheme.xs),
              Text(
                item['subtitle'] as String,
                style: AppTheme.caption.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * index))
     .fadeIn(duration: const Duration(milliseconds: 400))
     .slideX(begin: 0.3, end: 0, duration: const Duration(milliseconds: 400));
  }

  // Activity feed with new design
  Widget _buildActivityFeed(
    AppDataStore store,
    List<WatchingActivity> activities,
    Brightness brightness,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.gridMargin),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return AnimatedBuilder(
                animation: _feedAnimationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - _feedAnimationController.value)),
                    child: Opacity(
                      opacity: _feedAnimationController.value,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: AppTheme.lg),
                        child: Row(
                          children: [
                            Text(
                              'Recent Activity',
                              style: AppTheme.heading2.copyWith(
                                color: AppTheme.primaryText(brightness),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.sm,
                                vertical: AppTheme.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor(brightness).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                              ),
                              child: Text(
                                '${activities.length} activities',
                                style: AppTheme.caption.copyWith(
                                  color: AppTheme.primaryColor(brightness),
                                  fontWeight: FontWeight.w600,
                                ),
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

            if (activities.isEmpty && index == 1) {
              return _buildEmptyState(brightness);
            }

            if (index - 1 >= activities.length) return null;

            final activity = activities[index - 1];
            return AnimatedBuilder(
              animation: _feedAnimationController,
              builder: (context, child) {
                final delay = (index - 1) * 0.1;
                final animationValue = Curves.easeOutCubic.transform(
                  (_feedAnimationController.value - delay).clamp(0.0, 1.0),
                );

                return Transform.translate(
                  offset: Offset(0, 30 * (1 - animationValue)),
                  child: Opacity(
                    opacity: animationValue,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.md),
                      child: _buildActivityItem(activity, store, brightness),
                    ),
                  ),
                );
              },
            );
          },
          childCount: activities.isEmpty ? 2 : activities.length + 1,
        ),
      ),
    );
  }

  // Activity item with design system styling
  Widget _buildActivityItem(
    WatchingActivity activity,
    AppDataStore store,
    Brightness brightness,
  ) {
    final friendName = store.friends
        .where((f) => f.id == activity.userId)
        .firstOrNull?.name ?? 'Unknown Friend';

    return GestureDetector(
      onTap: () => _showMediaDetail(activity),
      child: Container(
        decoration: AppTheme.cardDecoration(brightness),
        padding: const EdgeInsets.all(AppTheme.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryColor(brightness).withOpacity(0.1),
                  child: Text(
                    friendName[0].toUpperCase(),
                    style: AppTheme.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor(brightness),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friendName,
                        style: AppTheme.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryText(brightness),
                        ),
                      ),
                      Text(
                        _formatTimeAgo(activity.createdAt),
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.secondaryText(brightness),
                        ),
                      ),
                    ],
                  ),
                ),
                if (activity.isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.lightSecondary,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Text(
                      'LIVE',
                      style: AppTheme.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: AppTheme.md),
            
            // Media content
            Row(
              children: [
                Container(
                  width: 60,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.appSurface(brightness),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Icon(
                    Icons.movie,
                    color: AppTheme.secondaryText(brightness),
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppTheme.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.media.title,
                        style: AppTheme.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryText(brightness),
                        ),
                      ),
                      const SizedBox(height: AppTheme.xs),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            (activity.media.imdbRating ?? 0.0).toStringAsFixed(1),
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.primaryText(brightness),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: AppTheme.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.xs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.appSurface(brightness),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              activity.media.genre.displayName,
                              style: AppTheme.caption.copyWith(
                                color: AppTheme.primaryText(brightness),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.xs),
                      Text(
                        activity.media.platform,
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.secondaryText(brightness),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.md),
            
            // Engagement buttons
            Row(
              children: [
                _buildEngagementButton(
                  Icons.favorite_border,
                  activity.reactions.length,
                  () => store.addReaction(activity.id, ReactionType.love),
                  AppTheme.lightSecondary,
                  brightness,
                ),
                const SizedBox(width: AppTheme.md),
                _buildEngagementButton(
                  Icons.chat_bubble_outline,
                  activity.comments.length,
                  () => _showComments(activity),
                  AppTheme.primaryColor(brightness),
                  brightness,
                ),
                const Spacer(),
                _buildEngagementButton(
                  Icons.bookmark_add_outlined,
                  0,
                  () => store.addToWatchlist(activity.media),
                  Colors.purple,
                  brightness,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementButton(
    IconData icon,
    int count,
    VoidCallback onTap,
    Color color,
    Brightness brightness,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.sm,
          vertical: AppTheme.xs,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            if (count > 0) ...[
              const SizedBox(width: AppTheme.xs),
              Text(
                count.toString(),
                style: AppTheme.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Brightness brightness) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.xl),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.xl),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor(brightness).withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.tv_off,
                size: 80,
                color: AppTheme.primaryColor(brightness),
              ),
            ),
            const SizedBox(height: AppTheme.xl),
            Text(
              'No Activities Yet',
              style: AppTheme.heading2.copyWith(
                color: AppTheme.primaryText(brightness),
              ),
            ),
            const SizedBox(height: AppTheme.sm),
            Text(
              'Connect with friends to see what they\'re watching',
              style: AppTheme.body.copyWith(
                color: AppTheme.secondaryText(brightness),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  List<WatchingActivity> _getFilteredActivities(AppDataStore store) {
    var activities = store.feedForYou;
    if (_selectedGenre != null) {
      activities = activities.where((a) => a.media.genre == _selectedGenre).toList();
    }
    return activities;
  }

  List<Map<String, dynamic>> _getTrendingItems(AppDataStore store) {
    return [
      {
        'category': 'Trending with Friends',
        'title': 'The Bear',
        'subtitle': '${store.friends.length} friends watching',
        'icon': Icons.local_fire_department,
        'isLive': false,
      },
      {
        'category': 'Highest Rated',
        'title': 'Dune: Part Two',
        'subtitle': '9.2 avg rating',
        'icon': Icons.star,
        'isLive': false,
      },
      {
        'category': 'New Activity',
        'title': store.activities.isNotEmpty ? store.activities.first.media.title : 'The Last of Us',
        'subtitle': store.activities.isNotEmpty 
            ? '${store.getFriendById(store.activities.first.userId)?.name ?? "Friend"} just started'
            : 'Sarah just started',
        'icon': Icons.play_circle_fill,
        'isLive': store.activities.isNotEmpty && store.activities.first.isLive,
      },
    ];
  }

  String _getPersonalizedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning!';
    if (hour < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
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

  // Navigation methods
  void _handleTrendingCardTap(Map<String, dynamic> item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Showing details for ${item['title']}'),
        backgroundColor: AppTheme.primaryColor(Theme.of(context).brightness),
      ),
    );
  }

  void _showMediaDetail(WatchingActivity activity) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${activity.media.title}'),
        backgroundColor: AppTheme.primaryColor(Theme.of(context).brightness),
      ),
    );
  }

  void _showComments(WatchingActivity activity) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${activity.comments.length} comments'),
        backgroundColor: AppTheme.primaryColor(Theme.of(context).brightness),
      ),
    );
  }
}