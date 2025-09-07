import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/app_data_store.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/primary_button.dart';
import '../models/social_models.dart';
import '../models/genre.dart';
import 'create_recommendation_request_screen.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
                // Header
                Padding(
                  padding: const EdgeInsets.all(AppTheme.lg),
                  child: Row(
                    children: [
                      Text(
                        'Recommendations',
                        style: AppTheme.largeTitle.copyWith(
                          color: AppTheme.primaryText(brightness),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _createRecommendationRequest(context),
                        icon: Icon(
                          Icons.add_circle,
                          color: Colors.blue,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Tab Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppTheme.lg),
                  decoration: BoxDecoration(
                    color: AppTheme.minimalSurface(brightness),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.primaryText(brightness),
                    unselectedLabelColor: AppTheme.secondaryText(brightness),
                    indicator: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'My Requests'),
                      Tab(text: 'Friends\' Requests'),
                    ],
                  ),
                ),
                
                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMyRequests(store, brightness),
                      _buildFriendsRequests(store, brightness),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMyRequests(AppDataStore store, Brightness brightness) {
    final myRequests = store.activeRecommendationRequests;
    
    if (myRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.request_page,
        title: 'No Requests Yet',
        subtitle: 'Create a recommendation request to get suggestions from friends!',
        brightness: brightness,
        onAction: () => _createRecommendationRequest(context),
        actionText: 'Create Request',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.lg),
      itemCount: myRequests.length,
      itemBuilder: (context, index) {
        final requestWithDetails = myRequests[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.lg),
          child: _buildRequestCard(requestWithDetails, store, brightness, isMyRequest: true),
        );
      },
    );
  }

  Widget _buildFriendsRequests(AppDataStore store, Brightness brightness) {
    final friendsRequests = store.friendsRecommendationRequestsSimple;
    
    if (friendsRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people_outline,
        title: 'No Friend Requests',
        subtitle: 'Your friends haven\'t made any recommendation requests yet.',
        brightness: brightness,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.lg),
      itemCount: friendsRequests.length,
      itemBuilder: (context, index) {
        final requestWithDetails = friendsRequests[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.lg),
          child: _buildRequestCard(requestWithDetails, store, brightness, isMyRequest: false),
        );
      },
    );
  }

  Widget _buildRequestCard(
    RecommendationRequestWithDetails requestWithDetails,
    AppDataStore store,
    Brightness brightness, {
    required bool isMyRequest,
  }) {
    final request = requestWithDetails.request;
    final recommendations = requestWithDetails.recommendations;
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.purple.withOpacity(0.2),
                child: Text(
                  requestWithDetails.requesterName[0].toUpperCase(),
                  style: AppTheme.callout.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMyRequest ? 'Your Request' : '${requestWithDetails.requesterName}\'s Request',
                      style: AppTheme.callout.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryText(brightness),
                      ),
                    ),
                    Text(
                      '${recommendations.length} recommendations',
                      style: AppTheme.caption1.copyWith(
                        color: AppTheme.secondaryText(brightness),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.xs,
                  vertical: AppTheme.xxxs,
                ),
                decoration: BoxDecoration(
                  color: request.movieIndustry == MovieIndustry.hollywood
                      ? Colors.blue.withOpacity(0.1)
                      : request.movieIndustry == MovieIndustry.bollywood
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                ),
                child: Text(
                  request.movieIndustry.displayName,
                  style: AppTheme.caption2.copyWith(
                    color: request.movieIndustry == MovieIndustry.hollywood
                        ? Colors.blue
                        : request.movieIndustry == MovieIndustry.bollywood
                            ? Colors.orange
                            : Colors.purple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.md),
          
          // Request details
          Wrap(
            spacing: AppTheme.xs,
            runSpacing: AppTheme.xs,
            children: request.genreTags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.xs,
                  vertical: AppTheme.xxxs,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                ),
                child: Text(
                  tag,
                  style: AppTheme.caption2.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
          
          if (request.note != null && request.note!.isNotEmpty) ...[
            const SizedBox(height: AppTheme.sm),
            Text(
              request.note!,
              style: AppTheme.subheadline.copyWith(
                color: AppTheme.primaryText(brightness),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          
          const SizedBox(height: AppTheme.sm),
          Text(
            '${request.yearRange.startYear} - ${request.yearRange.endYear}',
            style: AppTheme.caption1.copyWith(
              color: AppTheme.secondaryText(brightness),
            ),
          ),
          
          // Recommendations
          if (recommendations.isNotEmpty) ...[
            const SizedBox(height: AppTheme.lg),
            Text(
              'Recommendations',
              style: AppTheme.callout.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryText(brightness),
              ),
            ),
            const SizedBox(height: AppTheme.sm),
            ...recommendations.take(3).map((recWithDetails) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.sm),
                child: _buildRecommendationItem(recWithDetails, store, brightness),
              );
            }).toList(),
            
            if (recommendations.length > 3)
              TextButton(
                onPressed: () {
                  // TODO: Show all recommendations
                },
                child: Text(
                  'View ${recommendations.length - 3} more recommendations',
                  style: AppTheme.caption1.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ] else if (!isMyRequest) ...[
            const SizedBox(height: AppTheme.lg),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                title: 'Add Recommendation',
                onPressed: () => _addRecommendation(request),
                backgroundColor: Colors.green,
                height: 36,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(
    RecommendationWithDetails recWithDetails,
    AppDataStore store,
    Brightness brightness,
  ) {
    final recommendation = recWithDetails.recommendation;
    final media = recWithDetails.mediaItem;
    final isLiked = recommendation.likerIds.contains(store.currentUser.id);
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.sm),
      decoration: BoxDecoration(
        color: AppTheme.minimalSurface(brightness),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        children: [
          // Poster thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusXs),
            child: SizedBox(
              width: 40,
              height: 60,
              child: media.posterImage.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: media.posterImage,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppTheme.minimalElevatedSurface(brightness),
                        child: Icon(
                          Icons.movie,
                          color: AppTheme.secondaryText(brightness),
                          size: 16,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppTheme.minimalElevatedSurface(brightness),
                        child: Icon(
                          Icons.movie,
                          color: AppTheme.secondaryText(brightness),
                          size: 16,
                        ),
                      ),
                    )
                  : Container(
                      color: AppTheme.minimalElevatedSurface(brightness),
                      child: Icon(
                        Icons.movie,
                        color: AppTheme.secondaryText(brightness),
                        size: 16,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: AppTheme.sm),
          
          // Media details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  media.title,
                  style: AppTheme.callout.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryText(brightness),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'by ${recWithDetails.recommenderName}',
                  style: AppTheme.caption1.copyWith(
                    color: AppTheme.secondaryText(brightness),
                  ),
                ),
                if (media.imdbRating != null)
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 12,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        media.imdbRating!.toStringAsFixed(1),
                        style: AppTheme.caption2.copyWith(
                          color: AppTheme.secondaryText(brightness),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          // Like button
          GestureDetector(
            onTap: () {
              store.toggleRecommendationLike(recommendation.id);
            },
            child: Container(
              padding: const EdgeInsets.all(AppTheme.xs),
              decoration: BoxDecoration(
                color: isLiked
                    ? Colors.red.withOpacity(0.1)
                    : AppTheme.minimalElevatedSurface(brightness),
                borderRadius: BorderRadius.circular(AppTheme.radiusXs),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: isLiked ? Colors.red : AppTheme.secondaryText(brightness),
                  ),
                  if (recommendation.likeCount > 0) ...[
                    const SizedBox(width: 4),
                    Text(
                      recommendation.likeCount.toString(),
                      style: AppTheme.caption2.copyWith(
                        color: isLiked ? Colors.red : AppTheme.secondaryText(brightness),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
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
            Icon(
              icon,
              size: 60,
              color: AppTheme.secondaryText(brightness),
            ),
            const SizedBox(height: AppTheme.lg),
            Text(
              title,
              style: AppTheme.title2.copyWith(
                fontWeight: FontWeight.bold,
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
              PrimaryButton(
                title: actionText,
                onPressed: onAction,
                icon: Icons.add,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _createRecommendationRequest(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateRecommendationRequestScreen(),
      ),
    );
  }

  void _addRecommendation(RecommendationRequest request) {
    // TODO: Implement add recommendation functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add recommendation feature coming soon!'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
