import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_data_store.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/primary_button.dart';
import '../models/media.dart';
import 'create_watch_party_screen.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _heroAnimationController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _heroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _heroAnimationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _heroAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataStore>(
      builder: (context, store, child) {
        final brightness = store.brightness;
        
        return Scaffold(
          backgroundColor: AppTheme.appBackground(brightness),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                backgroundColor: AppTheme.appBackground(brightness),
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppTheme.sm),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                  ),
                                  child: Icon(
                                    Icons.bookmark,
                                    color: Colors.purple,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: AppTheme.sm),
                                Text(
                                  'My Watchlist',
                                  style: AppTheme.largeTitle.copyWith(
                                    color: AppTheme.primaryText(brightness),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.xs),
                            Text(
                              'Your personal library of movies & shows',
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
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(50),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppTheme.lg),
                    decoration: BoxDecoration(
                      color: AppTheme.minimalSurface(brightness),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.white,
                      unselectedLabelColor: AppTheme.secondaryText(brightness),
                      indicator: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.purple, Colors.blue],
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'To Watch'),
                        Tab(text: 'Watch Parties'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildToWatchTab(store, brightness),
                _buildWatchPartiesTab(store, brightness),
              ],
            ),
          ),
          floatingActionButton: _buildSmartFAB(store, brightness),
        );
      },
    );
  }

  Widget _buildToWatchTab(AppDataStore store, Brightness brightness) {
    final watchlistItems = store.getUserWatchlist();
    
    if (watchlistItems.isEmpty) {
      return _buildEmptyWatchlist(brightness);
    }

    return AnimatedBuilder(
      animation: _heroAnimationController,
      builder: (context, child) {
        return CustomScrollView(
          slivers: [
            // Smart Recommendations Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.lg),
                child: _buildSmartRecommendations(store, brightness),
              ),
            ),
            
            // Watchlist Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.lg),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: AppTheme.md,
                  mainAxisSpacing: AppTheme.md,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = watchlistItems[index];
                    return Transform.translate(
                      offset: Offset(
                        0,
                        50 * (1 - _heroAnimationController.value) * (index % 4),
                      ),
                      child: Opacity(
                        opacity: _heroAnimationController.value,
                        child: _buildWatchlistItem(item, store, brightness),
                      ),
                    );
                  },
                  childCount: watchlistItems.length,
                ),
              ),
            ),
            
            const SliverToBoxAdapter(
              child: SizedBox(height: 100), // FAB space
            ),
          ],
        );
      },
    );
  }

  Widget _buildWatchPartiesTab(AppDataStore store, Brightness brightness) {
    final upcomingParties = store.getUpcomingWatchParties();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.lg),
      child: Column(
        children: [
          // Quick Start Section
                      GlassCard(
            child: Column(
              children: [
                Icon(
                  Icons.play_circle_fill,
                  size: 48,
                  color: Colors.orange,
                ),
                const SizedBox(height: AppTheme.lg),
                Text(
                  'Start a Watch Party',
                  style: AppTheme.title2.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText(brightness),
                  ),
                ),
                const SizedBox(height: AppTheme.sm),
                Text(
                  'Watch movies together with friends in real-time',
                  style: AppTheme.body.copyWith(
                    color: AppTheme.secondaryText(brightness),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.lg),
                PrimaryButton(
                  title: 'Create Watch Party',
                  onPressed: () => _createWatchParty(),
                  icon: Icons.group_add,
                  backgroundColor: Colors.orange,
                ),
              ],
            ),
          ),
          
          if (upcomingParties.isNotEmpty) ...[
            const SizedBox(height: AppTheme.xl),
            _buildUpcomingParties(upcomingParties, store, brightness),
          ],
        ],
      ),
    );
  }

  Widget _buildSmartRecommendations(AppDataStore store, Brightness brightness) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.xs),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(
                  Icons.psychology,
                  size: 16,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: AppTheme.sm),
              Text(
                'Smart Picks for You',
                style: AppTheme.headline.copyWith(
                  fontWeight: FontWeight.bold,
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
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: Text(
                  '92% Match',
                  style: AppTheme.caption1.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.md),
          
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                child: Container(
                  width: 60,
                  height: 90,
                  color: AppTheme.secondaryText(brightness).withOpacity(0.3),
                  child: Icon(
                    Icons.movie,
                    color: AppTheme.secondaryText(brightness),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dune: Part Two',
                      style: AppTheme.callout.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText(brightness),
                      ),
                    ),
                    const SizedBox(height: AppTheme.xs),
                    Text(
                      'Because you like Sci-Fi and your friend Sarah loved it',
                      style: AppTheme.caption1.copyWith(
                        color: AppTheme.secondaryText(brightness),
                      ),
                    ),
                    const SizedBox(height: AppTheme.sm),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: AppTheme.xs),
                        Text(
                          '8.7 IMDb',
                          style: AppTheme.caption1.copyWith(
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
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Sci-Fi',
                            style: AppTheme.caption2.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _addToWatchlist('Dune: Part Two'),
                icon: Icon(
                  Icons.add_circle_outline,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlistItem(MediaItem item, AppDataStore store, Brightness brightness) {
    return Hero(
      tag: 'watchlist-${item.id}',
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster with overlay
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusMd),
                  ),
                  color: AppTheme.secondaryText(brightness).withOpacity(0.3),
                ),
                child: Stack(
                  children: [
                    // Poster placeholder
                    Center(
                      child: Icon(
                        Icons.movie,
                        size: 40,
                        color: AppTheme.secondaryText(brightness),
                      ),
                    ),
                    
                    // Watch Party Button
                    Positioned(
                      top: AppTheme.sm,
                      right: AppTheme.sm,
                      child: GestureDetector(
                        onTap: () => _startWatchParty(item),
                        child: Container(
                          padding: const EdgeInsets.all(AppTheme.xs),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryText(brightness).withOpacity(0.7),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    
                    // Match Score
                    Positioned(
                      bottom: AppTheme.sm,
                      left: AppTheme.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        child: Text(
                          '${(85 + item.id.hashCode % 15)}% Match',
                          style: AppTheme.caption2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTheme.callout.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText(brightness),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          (item.imdbRating ?? 0.0).toStringAsFixed(1),
                          style: AppTheme.caption1.copyWith(
                            color: AppTheme.primaryText(brightness),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => store.removeFromWatchlist(item.id),
                          child: Icon(
                            Icons.remove_circle_outline,
                            size: 16,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.genre.displayName,
                        style: AppTheme.caption2.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingParties(List<WatchParty> parties, AppDataStore store, Brightness brightness) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Watch Parties',
          style: AppTheme.title2.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryText(brightness),
          ),
        ),
        const SizedBox(height: AppTheme.lg),
        
        ...parties.map((party) => Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.md),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryText(brightness).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Icon(
                        Icons.movie,
                        color: AppTheme.secondaryText(brightness),
                      ),
                    ),
                    const SizedBox(width: AppTheme.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            party.media.title,
                            style: AppTheme.callout.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryText(brightness),
                            ),
                          ),
                          const SizedBox(height: AppTheme.xs),
                          Text(
                            'Hosted by ${store.getFriendById(party.hostId)?.name ?? "Friend"}',
                            style: AppTheme.caption1.copyWith(
                              color: AppTheme.secondaryText(brightness),
                            ),
                          ),
                          const SizedBox(height: AppTheme.xs),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 14,
                                color: AppTheme.secondaryText(brightness),
                              ),
                              const SizedBox(width: AppTheme.xs),
                              Text(
                                _formatScheduledTime(party.scheduledFor),
                                style: AppTheme.caption1.copyWith(
                                  color: AppTheme.primaryText(brightness),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.md),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        title: 'Join Party',
                        onPressed: () => store.joinWatchParty(party.id),
                        height: 36,
                      ),
                    ),
                    const SizedBox(width: AppTheme.sm),
                    OutlinedButton(
                      onPressed: () => _viewPartyDetails(party),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 36),
                      ),
                      child: Text(
                        'Details',
                        style: AppTheme.caption1.copyWith(
                          color: AppTheme.primaryText(brightness),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildEmptyWatchlist(Brightness brightness) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.xl),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.bookmark_add,
                size: 80,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: AppTheme.xl),
            Text(
              'Your Watchlist is Empty',
              style: AppTheme.title2.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText(brightness),
              ),
            ),
            const SizedBox(height: AppTheme.sm),
            Text(
              'Discover movies and shows from friends\' recommendations and add them here',
              style: AppTheme.body.copyWith(
                color: AppTheme.secondaryText(brightness),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.xl),
            PrimaryButton(
              title: 'Explore Recommendations',
              onPressed: () {
                // Switch to Ask tab
                DefaultTabController.of(context)?.animateTo(1);
              },
              icon: Icons.explore,
              backgroundColor: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartFAB(AppDataStore store, Brightness brightness) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddToWatchlistSheet(store, brightness),
      backgroundColor: Colors.purple,
      icon: Icon(Icons.add, color: Colors.white),
      label: Text(
        'Add Movie',
        style: AppTheme.callout.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showAddToWatchlistSheet(AppDataStore store, Brightness brightness) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppTheme.appBackground(brightness),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusLg),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: AppTheme.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryText(brightness),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.lg),
                child: Text(
                  'Add to Watchlist',
                  style: AppTheme.title2.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText(brightness),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.lg),
                  children: [
                    // Search bar placeholder
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.md,
                        vertical: AppTheme.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.minimalSurface(brightness),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: AppTheme.secondaryText(brightness),
                          ),
                          const SizedBox(width: AppTheme.sm),
                          Text(
                            'Search movies and shows...',
                            style: AppTheme.body.copyWith(
                              color: AppTheme.secondaryText(brightness),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.lg),
                    
                    // Popular suggestions
                    Text(
                      'Popular This Week',
                      style: AppTheme.headline.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText(brightness),
                      ),
                    ),
                    const SizedBox(height: AppTheme.md),
                    
                    // Mock popular movies
                    ...[
                      'Oppenheimer',
                      'Barbie',
                      'Guardians of the Galaxy Vol. 3',
                      'Spider-Man: Across the Spider-Verse',
                      'The Flash',
                    ].map((title) => ListTile(
                      leading: Container(
                        width: 40,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryText(brightness).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.movie,
                          color: AppTheme.secondaryText(brightness),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        title,
                        style: AppTheme.callout.copyWith(
                          color: AppTheme.primaryText(brightness),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '8.${(5 + title.hashCode % 4)} IMDb',
                        style: AppTheme.caption1.copyWith(
                          color: AppTheme.secondaryText(brightness),
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () => _addToWatchlist(title),
                        icon: Icon(
                          Icons.add_circle,
                          color: Colors.purple,
                        ),
                      ),
                      onTap: () => _addToWatchlist(title),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatScheduledTime(DateTime scheduledTime) {
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);
    
    if (difference.inDays > 0) {
      return 'In ${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return 'In ${difference.inHours} hours';
    } else if (difference.inMinutes > 0) {
      return 'In ${difference.inMinutes} minutes';
    } else {
      return 'Starting soon';
    }
  }

  void _addToWatchlist(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "$title" to watchlist!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop();
  }

  void _startWatchParty(MediaItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateWatchPartyScreen(preselectedMovie: item.title),
      ),
    );
  }

  void _createWatchParty() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateWatchPartyScreen(),
      ),
    );
  }

  void _viewPartyDetails(WatchParty party) {
    // TODO: Navigate to party details
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Party details coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
