import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/app_data_store.dart';
import '../theme/app_theme.dart';
import '../models/media.dart';
import 'create_watch_party_screen.dart';

class WatchPartyScreen extends StatefulWidget {
  const WatchPartyScreen({super.key});

  @override
  State<WatchPartyScreen> createState() => _WatchPartyScreenState();
}

class _WatchPartyScreenState extends State<WatchPartyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          body: SafeArea(
            child: Column(
              children: [
                _buildModernHeader(store, brightness),
                _buildTabBar(brightness),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildUpcomingParties(store, brightness),
                      _buildLiveParties(store, brightness),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: _buildCreatePartyFAB(store, brightness),
        );
      },
    );
  }

  // Modern header with design system styling
  Widget _buildModernHeader(AppDataStore store, Brightness brightness) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _animationController.value)),
          child: Opacity(
            opacity: _animationController.value,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.gridMargin,
                AppTheme.lg,
                AppTheme.gridMargin,
                AppTheme.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Watch Parties',
                          style: AppTheme.heading1.copyWith(
                            color: AppTheme.primaryText(brightness),
                          ),
                        ),
                        const SizedBox(height: AppTheme.xs),
                        Text(
                          'Watch together with friends',
                          style: AppTheme.body.copyWith(
                            color: AppTheme.secondaryText(brightness),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Active parties indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.sm,
                      vertical: AppTheme.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.lightSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.lightSecondary,
                            shape: BoxShape.circle,
                          ),
                        ).animate(onPlay: (controller) => controller.repeat())
                         .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2))
                         .then(delay: const Duration(milliseconds: 500))
                         .scale(begin: const Offset(1.2, 1.2), end: const Offset(0.8, 0.8)),
                        const SizedBox(width: AppTheme.xs),
                        Text(
                          '${store.watchParties.where((p) => p.isLive).length} Live',
                          style: AppTheme.caption.copyWith(
                            color: AppTheme.lightSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  // Modern tab bar
  Widget _buildTabBar(Brightness brightness) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - _animationController.value)),
          child: Opacity(
            opacity: _animationController.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppTheme.gridMargin),
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.appSurface(brightness),
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                boxShadow: const [AppTheme.cardShadow],
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.secondaryText(brightness),
                labelStyle: AppTheme.body.copyWith(fontWeight: FontWeight.w600),
                unselectedLabelStyle: AppTheme.body,
                indicator: BoxDecoration(
                  color: AppTheme.primaryColor(brightness),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicatorPadding: const EdgeInsets.all(4),
                tabs: const [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Live Now'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpcomingParties(AppDataStore store, Brightness brightness) {
    final upcomingParties = store.upcomingWatchParties;
    
    if (upcomingParties.isEmpty) {
      return _buildEmptyState(
        icon: Icons.schedule,
        title: 'No Upcoming Parties',
        subtitle: 'Create a watch party to enjoy content with friends!',
        brightness: brightness,
        onAction: () => _createWatchParty(context, store),
        actionText: 'Create Party',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppTheme.gridMargin),
      itemCount: upcomingParties.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppTheme.md),
      itemBuilder: (context, index) {
        final party = upcomingParties[index];
        return _buildWatchPartyCard(party, store, brightness, index);
      },
    );
  }

  Widget _buildLiveParties(AppDataStore store, Brightness brightness) {
    final liveParties = store.watchParties.where((p) => p.isLive).toList();
    
    if (liveParties.isEmpty) {
      return _buildEmptyState(
        icon: Icons.live_tv,
        title: 'No Live Parties',
        subtitle: 'Join friends who are currently watching together!',
        brightness: brightness,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppTheme.gridMargin),
      itemCount: liveParties.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppTheme.md),
      itemBuilder: (context, index) {
        final party = liveParties[index];
        return _buildLivePartyCard(party, store, brightness, index);
      },
    );
  }

  // Enhanced watch party card
  Widget _buildWatchPartyCard(WatchParty party, AppDataStore store, Brightness brightness, int index) {
    final isHost = party.hostId == store.currentUser.id;
    final isParticipant = party.participants.contains(store.currentUser.id);
    
    return GestureDetector(
      onTap: () => _showPartyDetails(party, store),
      child: Container(
        decoration: AppTheme.cardDecoration(brightness),
        padding: const EdgeInsets.all(AppTheme.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Host info header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppTheme.getTrendingGradient(index),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      party.hostName[0].toUpperCase(),
                      style: AppTheme.body.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        party.name,
                        style: AppTheme.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryText(brightness),
                        ),
                      ),
                      Text(
                        'Hosted by ${party.hostName}',
                        style: AppTheme.caption.copyWith(
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
                    color: AppTheme.primaryColor(brightness).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  child: Text(
                    _formatPartyTime(party.scheduledFor),
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.primaryColor(brightness),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.md),
            
            // Movie content
            Row(
              children: [
                Container(
                  width: 80,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppTheme.getTrendingGradient(index),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.movie,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        party.media.title,
                        style: AppTheme.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryText(brightness),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppTheme.xs),
                      _buildMetadataChip(
                        party.media.genre.displayName,
                        AppTheme.primaryColor(brightness),
                      ),
                      const SizedBox(height: AppTheme.sm),
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 16,
                            color: AppTheme.secondaryText(brightness),
                          ),
                          const SizedBox(width: AppTheme.xs),
                          Text(
                            '${party.participants.length}/${party.maxParticipants} joined',
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.secondaryText(brightness),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.lg),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _joinWatchParty(party, store),
                    icon: Icon(isParticipant ? Icons.check : Icons.person_add),
                    label: Text(
                      isParticipant ? 'Joined' : 'Join Party',
                      style: AppTheme.body.copyWith(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isParticipant 
                          ? Colors.green 
                          : AppTheme.primaryColor(brightness),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                  ),
                ),
                if (isHost) ...[
                  const SizedBox(width: AppTheme.sm),
                  IconButton(
                    onPressed: () => _manageParty(party, store),
                    icon: const Icon(Icons.settings),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.appSurface(brightness),
                      foregroundColor: AppTheme.primaryText(brightness),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * index))
     .fadeIn(duration: const Duration(milliseconds: 400))
     .slideX(begin: 0.3, end: 0, duration: const Duration(milliseconds: 400));
  }

  // Live party card with special styling
  Widget _buildLivePartyCard(WatchParty party, AppDataStore store, Brightness brightness, int index) {
    return GestureDetector(
      onTap: () => _joinLiveParty(party, store),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.lightSecondary.withOpacity(0.1),
              AppTheme.lightSecondary.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: AppTheme.lightSecondary.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: const [AppTheme.cardShadow],
        ),
        padding: const EdgeInsets.all(AppTheme.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.sm,
                    vertical: AppTheme.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.lightSecondary,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ).animate(onPlay: (controller) => controller.repeat())
                       .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2))
                       .then(delay: const Duration(milliseconds: 500))
                       .scale(begin: const Offset(1.2, 1.2), end: const Offset(0.8, 0.8)),
                      const SizedBox(width: AppTheme.xs),
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
                const Spacer(),
                Text(
                  '${party.participants.length} watching',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.secondaryText(brightness),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.md),
            
            // Movie info
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
                        party.media.title,
                        style: AppTheme.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryText(brightness),
                        ),
                      ),
                      const SizedBox(height: AppTheme.xs),
                      Text(
                        'Hosted by ${party.hostName}',
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.secondaryText(brightness),
                        ),
                      ),
                      const SizedBox(height: AppTheme.sm),
                      // Progress bar
                      LinearProgressIndicator(
                        value: party.progress,
                        backgroundColor: AppTheme.appSurface(brightness),
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.lightSecondary),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      const SizedBox(height: AppTheme.xs),
                      Text(
                        '${(party.progress * 100).toInt()}% watched',
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.secondaryText(brightness),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.lg),
            
            // Join live button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _joinLiveParty(party, store),
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  'Join Live Party',
                  style: AppTheme.body.copyWith(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightSecondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * index))
     .fadeIn(duration: const Duration(milliseconds: 400))
     .slideX(begin: 0.3, end: 0, duration: const Duration(milliseconds: 400));
  }

  Widget _buildMetadataChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.sm,
        vertical: AppTheme.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Text(
        label,
        style: AppTheme.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Brightness brightness,
    VoidCallback? onAction,
    String? actionText,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.xl),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor(brightness).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 60,
                color: AppTheme.primaryColor(brightness),
              ),
            ),
            const SizedBox(height: AppTheme.xl),
            Text(
              title,
              style: AppTheme.heading2.copyWith(
                color: AppTheme.primaryText(brightness),
              ),
            ),
            const SizedBox(height: AppTheme.sm),
            Text(
              subtitle,
              style: AppTheme.body.copyWith(
                color: AppTheme.secondaryText(brightness),
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: AppTheme.xl),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(
                  actionText,
                  style: AppTheme.body.copyWith(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor(brightness),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCreatePartyFAB(AppDataStore store, Brightness brightness) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _animationController.value,
          child: FloatingActionButton.extended(
            onPressed: () => _createWatchParty(context, store),
            backgroundColor: AppTheme.primaryColor(brightness),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: Text(
              'Create Party',
              style: AppTheme.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }

  String _formatPartyTime(DateTime scheduledFor) {
    final now = DateTime.now();
    final difference = scheduledFor.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Now';
    }
  }

  // Action methods
  void _createWatchParty(BuildContext context, AppDataStore store) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateWatchPartyScreen(),
      ),
    );
  }

  void _joinWatchParty(WatchParty party, AppDataStore store) {
    if (!party.participants.contains(store.currentUser.id)) {
      store.joinWatchParty(party.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Joined ${party.hostName}\'s watch party!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
        ),
      );
    }
  }

  void _joinLiveParty(WatchParty party, AppDataStore store) {
    // Open live party room
    _showLivePartyRoom(party, store);
  }

  void _showPartyDetails(WatchParty party, AppDataStore store) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PartyDetailsSheet(party: party),
    );
  }

  void _showLivePartyRoom(WatchParty party, AppDataStore store) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _LivePartyRoomScreen(party: party),
        fullscreenDialog: true,
      ),
    );
  }

  void _manageParty(WatchParty party, AppDataStore store) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Party management coming soon!'),
        backgroundColor: AppTheme.primaryColor(Theme.of(context).brightness),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
      ),
    );
  }
}

// Party details bottom sheet
class _PartyDetailsSheet extends StatelessWidget {
  final WatchParty party;

  const _PartyDetailsSheet({required this.party});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataStore>(
      builder: (context, store, child) {
        final brightness = store.brightness;
        
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.appBackground(brightness),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusLg),
            ),
          ),
          padding: const EdgeInsets.all(AppTheme.gridMargin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryText(brightness).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              const SizedBox(height: AppTheme.lg),
              
              Text(
                party.name,
                style: AppTheme.heading2.copyWith(
                  color: AppTheme.primaryText(brightness),
                ),
              ),
              
              const SizedBox(height: AppTheme.lg),
              
              // Party details here
              Text(
                'Party details and controls will be available here.',
                style: AppTheme.body.copyWith(
                  color: AppTheme.secondaryText(brightness),
                ),
              ),
              
              const SizedBox(height: AppTheme.xl),
            ],
          ),
        );
      },
    );
  }
}

// Live party room screen
class _LivePartyRoomScreen extends StatelessWidget {
  final WatchParty party;

  const _LivePartyRoomScreen({required this.party});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataStore>(
      builder: (context, store, child) {
        final brightness = store.brightness;
        
        return Scaffold(
          backgroundColor: AppTheme.primaryText(brightness),
          appBar: AppBar(
            backgroundColor: AppTheme.primaryText(brightness).withOpacity(0.8),
            foregroundColor: Colors.white,
            title: Text(party.media.title),
          ),
          body: Column(
            children: [
              // Video area placeholder
              Expanded(
                flex: 3,
                child: Container(
                  color: AppTheme.primaryText(brightness),
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                ),
              ),
              
              // Chat and reactions area
              Expanded(
                flex: 2,
                child: Container(
                  color: AppTheme.appBackground(brightness),
                  child: const Center(
                    child: Text('Chat and reactions will be here'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}