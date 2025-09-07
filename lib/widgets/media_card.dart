import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import '../models/media.dart';
import '../models/genre.dart';
import '../services/app_data_store.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class MediaCard extends StatelessWidget {
  final String friendName;
  final WatchingActivity activity;
  final VoidCallback? onTap;

  const MediaCard({
    super.key,
    required this.friendName,
    required this.activity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    
    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info and time
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue.withOpacity(0.2),
                child: Text(
                  friendName[0].toUpperCase(),
                  style: AppTheme.callout.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
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
                      style: AppTheme.callout.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryText(brightness),
                      ),
                    ),
                    Text(
                      timeago.format(activity.createdAt),
                      style: AppTheme.caption1.copyWith(
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
                    vertical: AppTheme.xxxs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
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
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: AppTheme.caption2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.md),
          
          // Media content
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster image
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                child: SizedBox(
                  width: 80,
                  height: 120,
                  child: activity.media.posterImage.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: activity.media.posterImage,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppTheme.minimalSurface(brightness),
                            child: Icon(
                              Icons.movie,
                              color: AppTheme.secondaryText(brightness),
                              size: 32,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppTheme.minimalSurface(brightness),
                            child: Icon(
                              Icons.movie,
                              color: AppTheme.secondaryText(brightness),
                              size: 32,
                            ),
                          ),
                        )
                      : Container(
                          color: AppTheme.minimalSurface(brightness),
                          child: Icon(
                            Icons.movie,
                            color: AppTheme.secondaryText(brightness),
                            size: 32,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: AppTheme.md),
              
              // Media details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.media.title,
                      style: AppTheme.headline.copyWith(
                        color: AppTheme.primaryText(brightness),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.xxs),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.xs,
                            vertical: AppTheme.xxxs,
                          ),
                          decoration: BoxDecoration(
                            color: _getGenreColor(activity.media.genre, brightness).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                          ),
                          child: Text(
                            activity.media.genre.displayName,
                            style: AppTheme.caption2.copyWith(
                              color: _getGenreColor(activity.media.genre, brightness),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.xs),
                        Text(
                          activity.media.type.displayName,
                          style: AppTheme.caption1.copyWith(
                            color: AppTheme.secondaryText(brightness),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.tv,
                          size: 14,
                          color: AppTheme.secondaryText(brightness),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          activity.media.platform,
                          style: AppTheme.caption1.copyWith(
                            color: AppTheme.secondaryText(brightness),
                          ),
                        ),
                        if (activity.media.imdbRating != null) ...[
                          const SizedBox(width: AppTheme.sm),
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            activity.media.imdbRating!.toStringAsFixed(1),
                            style: AppTheme.caption1.copyWith(
                              color: AppTheme.secondaryText(brightness),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (activity.progress != null) ...[
                      const SizedBox(height: AppTheme.xs),
                      LinearProgressIndicator(
                        value: activity.progress!,
                        backgroundColor: AppTheme.minimalSurface(brightness),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(activity.progress! * 100).toInt()}% watched',
                        style: AppTheme.caption2.copyWith(
                          color: AppTheme.secondaryText(brightness),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          // Reactions and comments
          if (activity.reactions.isNotEmpty || activity.comments.isNotEmpty) ...[
            const SizedBox(height: AppTheme.md),
            _buildInteractions(context, activity),
          ],
        ],
      ),
    );
  }

  Widget _buildInteractions(BuildContext context, WatchingActivity activity) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reactions
        if (activity.reactions.isNotEmpty) ...[
          Wrap(
            spacing: AppTheme.xs,
            children: ReactionType.values
                .where((type) => activity.reactions.any((r) => r.type == type))
                .map((type) {
                  final count = activity.reactions.where((r) => r.type == type).length;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.xs,
                      vertical: AppTheme.xxxs,
                    ),
                    decoration: BoxDecoration(
                      color: type.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          type.icon,
                          size: 12,
                          color: type.color,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          count.toString(),
                          style: AppTheme.caption2.copyWith(
                            color: type.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                })
                .toList(),
          ),
          const SizedBox(height: AppTheme.xs),
        ],
        
        // Comments
        if (activity.comments.isNotEmpty) ...[
          ...activity.comments.take(2).map((comment) {
            final store = Provider.of<AppDataStore>(context, listen: false);
            final commenterName = store.friends
                .where((f) => f.id == comment.userId)
                .firstOrNull?.name ?? 'Unknown';
            
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.xs),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$commenterName: ',
                      style: AppTheme.caption1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    TextSpan(
                      text: comment.text,
                      style: AppTheme.caption1.copyWith(
                        color: AppTheme.primaryText(brightness),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          
          if (activity.comments.length > 2)
            Text(
              'View ${activity.comments.length - 2} more comment${activity.comments.length - 2 == 1 ? '' : 's'}',
              style: AppTheme.caption1.copyWith(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ],
    );
  }

  Color _getGenreColor(Genre genre, Brightness brightness) {
    switch (genre) {
      case Genre.action:
        return Colors.red;
      case Genre.comedy:
        return Colors.orange;
      case Genre.drama:
        return Colors.purple;
      case Genre.horror:
        return Colors.deepPurple;
      case Genre.sciFi:
        return Colors.blue;
      case Genre.thriller:
        return Colors.teal;
      case Genre.romance:
        return Colors.pink;
      case Genre.documentary:
        return Colors.green;
      default:
        return AppTheme.secondaryText(brightness);
    }
  }
}
