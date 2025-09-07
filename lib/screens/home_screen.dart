import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_data_store.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/media_card.dart';
import '../widgets/stat_card.dart';
import '../models/genre.dart';
import '../models/media.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Genre? _selectedGenre;
  bool _isRefreshing = false;

  Future<void> _refresh() async {
    setState(() {
      _isRefreshing = true;
    });
    
    // Simulate network refresh
    await Future.delayed(const Duration(milliseconds: 500));
    
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
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _refresh,
              color: Colors.blue,
              backgroundColor: AppTheme.minimalSurface(brightness),
              child: CustomScrollView(
                slivers: [
                  // App Bar
                  SliverAppBar(
                    expandedHeight: 120,
                    floating: true,
                    pinned: true,
                    backgroundColor: AppTheme.appBackground(brightness),
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.only(
                        left: AppTheme.lg,
                        bottom: AppTheme.md,
                      ),
                      title: Text(
                        'Home',
                        style: AppTheme.largeTitle.copyWith(
                          color: AppTheme.primaryText(brightness),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    actions: [
                      _buildThemeToggle(store, brightness),
                      const SizedBox(width: AppTheme.sm),
                    ],
                  ),
                  
                  // Content
                  SliverPadding(
                    padding: const EdgeInsets.all(AppTheme.lg),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Welcome header
                        _buildWelcomeHeader(store, brightness),
                        const SizedBox(height: AppTheme.sectionSpacing),
                        
                        // Quick stats
                        _buildQuickStats(store),
                        const SizedBox(height: AppTheme.sectionSpacing),
                        
                        // Genre filter
                        if (store.activities.isNotEmpty) ...[
                          _buildGenreFilter(store, brightness),
                          const SizedBox(height: AppTheme.lg),
                        ],
                        
                        // Activity feed
                        if (filteredActivities.isEmpty)
                          _buildEmptyState(brightness)
                        else
                          _buildActivityFeed(store, filteredActivities, brightness),
                      ]),
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

  Widget _buildThemeToggle(AppDataStore store, Brightness brightness) {
    return IconButton(
      onPressed: store.toggleTheme,
      icon: Icon(
        brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode,
        color: AppTheme.primaryText(brightness),
      ),
    );
  }

  Widget _buildWelcomeHeader(AppDataStore store, Brightness brightness) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: AppTheme.title2.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText(brightness),
                      ),
                    ),
                    const SizedBox(height: AppTheme.xs),
                    Text(
                      'Discover what your friends are watching',
                      style: AppTheme.subheadline.copyWith(
                        color: AppTheme.secondaryText(brightness),
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.blue.withOpacity(0.2),
                child: Text(
                  store.currentUser.name[0].toUpperCase(),
                  style: AppTheme.title2.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.lg),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Add Activity',
                  Icons.add_circle,
                  Colors.blue,
                  () {
                    // TODO: Show add activity modal
                  },
                ),
              ),
              const SizedBox(width: AppTheme.sm),
              Expanded(
                child: _buildQuickActionButton(
                  'Find Friends',
                  Icons.people,
                  Colors.purple,
                  () {
                    // TODO: Navigate to connect screen
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
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
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: AppTheme.xs),
            Text(
              title,
              style: AppTheme.caption1.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(AppDataStore store) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Friends',
            value: '${store.friends.length}',
            icon: Icons.people,
            isTappable: true,
            onTap: () {
              // TODO: Navigate to friends list
            },
          ),
        ),
        const SizedBox(width: AppTheme.sm),
        Expanded(
          child: StatCard(
            title: 'Watching',
            value: '${store.activities.length}',
            icon: Icons.tv,
            iconColor: Colors.orange,
          ),
        ),
        const SizedBox(width: AppTheme.sm),
        Expanded(
          child: StatCard(
            title: 'Genres',
            value: '${store.activities.map((a) => a.media.genre).toSet().length}',
            icon: Icons.category,
            iconColor: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildGenreFilter(AppDataStore store, Brightness brightness) {
    final genreCounts = <Genre, int>{};
    for (final activity in store.activities) {
      genreCounts[activity.media.genre] = (genreCounts[activity.media.genre] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter by Genre',
          style: AppTheme.headline.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryText(brightness),
          ),
        ),
        const SizedBox(height: AppTheme.sm),
        SizedBox(
          height: 35,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildGenreChip(
                'All',
                store.activities.length,
                _selectedGenre == null,
                () {
                  setState(() {
                    _selectedGenre = null;
                  });
                },
                brightness,
              ),
              const SizedBox(width: AppTheme.xs),
              ...genreCounts.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppTheme.xs),
                  child: _buildGenreChip(
                    entry.key.displayName,
                    entry.value,
                    _selectedGenre == entry.key,
                    () {
                      setState(() {
                        _selectedGenre = entry.key;
                      });
                    },
                    brightness,
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenreChip(
    String label,
    int count,
    bool isSelected,
    VoidCallback onTap,
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
          color: isSelected
              ? Colors.blue
              : AppTheme.minimalSurface(brightness),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: isSelected
                ? Colors.blue
                : AppTheme.minimalStroke(brightness),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTheme.caption1.copyWith(
                color: isSelected
                    ? Colors.white
                    : AppTheme.primaryText(brightness),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '($count)',
              style: AppTheme.caption2.copyWith(
                color: isSelected
                    ? Colors.white.withOpacity(0.8)
                    : AppTheme.secondaryText(brightness),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Brightness brightness) {
    return Center(
      child: GlassCard(
        child: Column(
          children: [
            Icon(
              Icons.tv_off,
              size: 60,
              color: AppTheme.secondaryText(brightness),
            ),
            const SizedBox(height: AppTheme.lg),
            Text(
              _selectedGenre == null ? 'No Activities Yet' : 'No ${_selectedGenre?.displayName} Content',
              style: AppTheme.headline.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryText(brightness),
              ),
            ),
            const SizedBox(height: AppTheme.sm),
            Text(
              _selectedGenre == null
                  ? 'Start by adding what you\'re watching to discover friends with similar tastes.'
                  : 'Try adding some ${_selectedGenre?.displayName} content to get started.',
              style: AppTheme.subheadline.copyWith(
                color: AppTheme.secondaryText(brightness),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.lg),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Show add activity modal
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Activity'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityFeed(
    AppDataStore store,
    List<WatchingActivity> activities,
    Brightness brightness,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Activity',
              style: AppTheme.headline.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryText(brightness),
              ),
            ),
            const Spacer(),
            Text(
              '${activities.length} activities',
              style: AppTheme.caption1.copyWith(
                color: AppTheme.secondaryText(brightness),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.md),
        ...activities.map((activity) {
          final friendName = store.friends
              .where((f) => f.id == activity.userId)
              .firstOrNull?.name ?? 'Unknown';
          
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.md),
            child: MediaCard(
              friendName: friendName,
              activity: activity,
              onTap: () {
                // TODO: Navigate to media detail
              },
            ),
          );
        }).toList(),
      ],
    );
  }

  List<WatchingActivity> _getFilteredActivities(AppDataStore store) {
    var activities = store.feedForYou;
    if (_selectedGenre != null) {
      activities = activities.where((a) => a.media.genre == _selectedGenre).toList();
    }
    return activities;
  }
}
