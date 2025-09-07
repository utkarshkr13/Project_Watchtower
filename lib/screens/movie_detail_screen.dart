import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/app_data_store.dart';
import '../theme/app_theme.dart';
import '../models/media.dart';
import '../models/user_models.dart';

class MovieDetailScreen extends StatefulWidget {
  final MediaItem media;
  final String? heroTag;

  const MovieDetailScreen({
    super.key,
    required this.media,
    this.heroTag,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderExpanded = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scrollController.addListener(_onScroll);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final isExpanded = offset < 200;
    if (isExpanded != _isHeaderExpanded) {
      setState(() {
        _isHeaderExpanded = isExpanded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataStore>(
      builder: (context, store, child) {
        final brightness = store.brightness;
        
        return Scaffold(
          backgroundColor: AppTheme.appBackground(brightness),
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildHeroPoster(brightness),
              _buildMovieInfo(store, brightness),
              _buildWhereToWatch(brightness),
              _buildFriendComments(store, brightness),
              _buildActionButtons(store, brightness),
            ],
          ),
        );
      },
    );
  }

  // Hero poster section
  Widget _buildHeroPoster(Brightness brightness) {
    return SliverAppBar(
      expandedHeight: 400,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.appBackground(brightness),
      leading: Container(
        margin: const EdgeInsets.all(AppTheme.sm),
        decoration: BoxDecoration(
          color: AppTheme.primaryText(brightness).withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(AppTheme.sm),
          decoration: BoxDecoration(
            color: AppTheme.primaryText(brightness).withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareMovie,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: widget.heroTag ?? 'movie-${widget.media.id}',
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Poster image placeholder with gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.trendingGradients[0],
                      AppTheme.trendingGradients[1],
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.movie,
                    size: 80,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
              
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppTheme.primaryText(brightness).withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              
              // Play button
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: const [AppTheme.cardShadow],
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    size: 40,
                    color: AppTheme.lightPrimary,
                  ),
                ),
              ).animate()
               .scale(delay: const Duration(milliseconds: 400))
               .fadeIn(),
            ],
          ),
        ),
      ),
    );
  }

  // Movie information section
  Widget _buildMovieInfo(AppDataStore store, Brightness brightness) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 30 * (1 - _animationController.value)),
            child: Opacity(
              opacity: _animationController.value,
              child: Container(
                padding: const EdgeInsets.all(AppTheme.gridMargin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and rating
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.media.title,
                                style: AppTheme.heading1.copyWith(
                                  color: AppTheme.primaryText(brightness),
                                ),
                              ),
                              const SizedBox(height: AppTheme.xs),
                              if (widget.media.year != null)
                                Text(
                                  widget.media.year.toString(),
                                  style: AppTheme.body.copyWith(
                                    color: AppTheme.secondaryText(brightness),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (widget.media.imdbRating != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.md,
                              vertical: AppTheme.sm,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                                const SizedBox(width: AppTheme.xs),
                                Text(
                                  widget.media.imdbRating!.toStringAsFixed(1),
                                  style: AppTheme.body.copyWith(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: AppTheme.lg),
                    
                    // Genres and metadata
                    Wrap(
                      spacing: AppTheme.sm,
                      runSpacing: AppTheme.sm,
                      children: [
                        _buildMetadataChip(
                          widget.media.genre.displayName,
                          AppTheme.primaryColor(brightness),
                        ),
                        _buildMetadataChip(
                          widget.media.type.displayName,
                          AppTheme.secondaryColor(brightness),
                        ),
                        if (widget.media.director != null)
                          _buildMetadataChip(
                            'Dir: ${widget.media.director}',
                            Colors.purple,
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: AppTheme.lg),
                    
                    // Description
                    if (widget.media.description != null) ...[
                      Text(
                        'Description',
                        style: AppTheme.heading2.copyWith(
                          color: AppTheme.primaryText(brightness),
                        ),
                      ),
                      const SizedBox(height: AppTheme.sm),
                      Text(
                        widget.media.description!,
                        style: AppTheme.body.copyWith(
                          color: AppTheme.secondaryText(brightness),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: AppTheme.lg),
                    ],
                    
                    // Cast
                    if (widget.media.cast != null && widget.media.cast!.isNotEmpty) ...[
                      Text(
                        'Cast',
                        style: AppTheme.heading2.copyWith(
                          color: AppTheme.primaryText(brightness),
                        ),
                      ),
                      const SizedBox(height: AppTheme.sm),
                      Text(
                        widget.media.cast!.join(', '),
                        style: AppTheme.body.copyWith(
                          color: AppTheme.secondaryText(brightness),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Where to watch section
  Widget _buildWhereToWatch(Brightness brightness) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 40 * (1 - _animationController.value)),
            child: Opacity(
              opacity: _animationController.value,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: AppTheme.gridMargin),
                padding: const EdgeInsets.all(AppTheme.lg),
                decoration: AppTheme.cardDecoration(brightness),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.sm),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor(brightness).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: Icon(
                            Icons.tv,
                            color: AppTheme.primaryColor(brightness),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppTheme.sm),
                        Text(
                          'Where to Watch',
                          style: AppTheme.heading2.copyWith(
                            color: AppTheme.primaryText(brightness),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppTheme.lg),
                    
                    Container(
                      padding: const EdgeInsets.all(AppTheme.md),
                      decoration: BoxDecoration(
                        color: AppTheme.appSurface(brightness),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor(brightness),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            ),
                            child: Center(
                              child: Text(
                                widget.media.platform[0].toUpperCase(),
                                style: AppTheme.body.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.media.platform,
                                  style: AppTheme.body.copyWith(
                                    color: AppTheme.primaryText(brightness),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Available to stream',
                                  style: AppTheme.caption.copyWith(
                                    color: AppTheme.secondaryText(brightness),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.open_in_new,
                            color: AppTheme.primaryColor(brightness),
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
      ),
    );
  }

  // Friend comments section
  Widget _buildFriendComments(AppDataStore store, Brightness brightness) {
    final mockComments = _getMockComments(store);
    
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - _animationController.value)),
            child: Opacity(
              opacity: _animationController.value,
              child: Container(
                margin: const EdgeInsets.all(AppTheme.gridMargin),
                padding: const EdgeInsets.all(AppTheme.lg),
                decoration: AppTheme.cardDecoration(brightness),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.sm),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor(brightness).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: Icon(
                            Icons.people,
                            color: AppTheme.secondaryColor(brightness),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppTheme.sm),
                        Text(
                          'What Friends Say',
                          style: AppTheme.heading2.copyWith(
                            color: AppTheme.primaryText(brightness),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppTheme.lg),
                    
                    ...mockComments.map((comment) => Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.md),
                      child: _buildCommentItem(comment, brightness),
                    )),
                    
                    const SizedBox(height: AppTheme.sm),
                    
                    // Add comment button
                    GestureDetector(
                      onTap: _showAddComment,
                      child: Container(
                        padding: const EdgeInsets.all(AppTheme.md),
                        decoration: BoxDecoration(
                          color: AppTheme.appSurface(brightness),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(
                            color: AppTheme.primaryColor(brightness).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppTheme.primaryColor(brightness).withOpacity(0.1),
                              child: Icon(
                                Icons.add,
                                color: AppTheme.primaryColor(brightness),
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: AppTheme.sm),
                            Text(
                              'Add your thoughts...',
                              style: AppTheme.body.copyWith(
                                color: AppTheme.secondaryText(brightness),
                              ),
                            ),
                          ],
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

  // Action buttons section
  Widget _buildActionButtons(AppDataStore store, Brightness brightness) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 60 * (1 - _animationController.value)),
            child: Opacity(
              opacity: _animationController.value,
              child: Container(
                padding: const EdgeInsets.all(AppTheme.gridMargin),
                child: Column(
                  children: [
                    // Primary actions
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _addToWatchlist(store),
                            icon: const Icon(Icons.add),
                            label: Text(
                              'Add to Watchlist',
                              style: AppTheme.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
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
                        ),
                        const SizedBox(width: AppTheme.md),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _createWatchParty(store),
                            icon: const Icon(Icons.group),
                            label: Text(
                              'Watch Party',
                              style: AppTheme.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.secondaryColor(brightness),
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
                    
                    const SizedBox(height: AppTheme.md),
                    
                    // Secondary actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          Icons.favorite_border,
                          'Like',
                          () => _likeMovie(store),
                          brightness,
                        ),
                        _buildActionButton(
                          Icons.share,
                          'Share',
                          _shareMovie,
                          brightness,
                        ),
                        _buildActionButton(
                          Icons.bookmark_border,
                          'Save',
                          () => _saveMovie(store),
                          brightness,
                        ),
                        _buildActionButton(
                          Icons.flag_outlined,
                          'Report',
                          _reportMovie,
                          brightness,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppTheme.xl),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
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

  Widget _buildCommentItem(Map<String, dynamic> comment, Brightness brightness) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppTheme.primaryColor(brightness).withOpacity(0.1),
          child: Text(
            comment['name'][0].toUpperCase(),
            style: AppTheme.caption.copyWith(
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
              Row(
                children: [
                  Text(
                    comment['name'],
                    style: AppTheme.body.copyWith(
                      color: AppTheme.primaryText(brightness),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  ...List.generate(comment['rating'], (index) => const Icon(
                    Icons.star,
                    color: Colors.orange,
                    size: 12,
                  )),
                ],
              ),
              const SizedBox(height: AppTheme.xs),
              Text(
                comment['comment'],
                style: AppTheme.body.copyWith(
                  color: AppTheme.secondaryText(brightness),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback onTap,
    Brightness brightness,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.md),
            decoration: BoxDecoration(
              color: AppTheme.appSurface(brightness),
              shape: BoxShape.circle,
              boxShadow: const [AppTheme.cardShadow],
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryText(brightness),
            ),
          ),
          const SizedBox(height: AppTheme.xs),
          Text(
            label,
            style: AppTheme.caption.copyWith(
              color: AppTheme.secondaryText(brightness),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockComments(AppDataStore store) {
    return [
      {
        'name': store.friends.isNotEmpty ? store.friends.first.name : 'Sarah',
        'rating': 5,
        'comment': 'Absolutely loved this! The cinematography was stunning and the story kept me engaged throughout.',
      },
      {
        'name': store.friends.length > 1 ? store.friends[1].name : 'Mike',
        'rating': 4,
        'comment': 'Great watch! Perfect for a weekend movie night. Highly recommended.',
      },
    ];
  }

  // Action methods
  void _addToWatchlist(AppDataStore store) {
    store.addToWatchlist(widget.media);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Added to watchlist!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
      ),
    );
  }

  void _createWatchParty(AppDataStore store) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Creating watch party...'),
        backgroundColor: AppTheme.lightSecondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
      ),
    );
  }

  void _likeMovie(AppDataStore store) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Movie liked!'),
        backgroundColor: AppTheme.lightSecondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
      ),
    );
  }

  void _shareMovie() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${widget.media.title}...'),
        backgroundColor: AppTheme.lightPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
      ),
    );
  }

  void _saveMovie(AppDataStore store) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Movie saved!'),
        backgroundColor: Colors.purple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
      ),
    );
  }

  void _reportMovie() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Movie reported. Thank you for your feedback.'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
      ),
    );
  }

  void _showAddComment() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddCommentSheet(media: widget.media),
    );
  }
}

// Add comment bottom sheet
class _AddCommentSheet extends StatefulWidget {
  final MediaItem media;

  const _AddCommentSheet({required this.media});

  @override
  State<_AddCommentSheet> createState() => _AddCommentSheetState();
}

class _AddCommentSheetState extends State<_AddCommentSheet> {
  final _commentController = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataStore>(
      builder: (context, store, child) {
        final brightness = store.brightness;
        
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.appBackground(brightness),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppTheme.radiusLg),
              ),
            ),
            padding: const EdgeInsets.all(AppTheme.gridMargin),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryText(brightness).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                const SizedBox(height: AppTheme.lg),
                
                Text(
                  'Add Your Review',
                  style: AppTheme.heading2.copyWith(
                    color: AppTheme.primaryText(brightness),
                  ),
                ),
                
                const SizedBox(height: AppTheme.lg),
                
                // Rating
                Text(
                  'Your Rating',
                  style: AppTheme.body.copyWith(
                    color: AppTheme.primaryText(brightness),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: AppTheme.sm),
                
                Row(
                  children: List.generate(5, (index) => GestureDetector(
                    onTap: () => setState(() => _rating = index + 1),
                    child: Icon(
                      Icons.star,
                      color: index < _rating ? Colors.orange : AppTheme.secondaryText(brightness),
                      size: 32,
                    ),
                  )),
                ),
                
                const SizedBox(height: AppTheme.lg),
                
                // Comment
                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  style: AppTheme.body.copyWith(
                    color: AppTheme.primaryText(brightness),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Share your thoughts about ${widget.media.title}...',
                    hintStyle: AppTheme.body.copyWith(
                      color: AppTheme.secondaryText(brightness),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      borderSide: BorderSide(
                        color: AppTheme.secondaryText(brightness).withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      borderSide: BorderSide(
                        color: AppTheme.primaryColor(brightness),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: AppTheme.lg),
                
                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitComment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor(brightness),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                    child: Text(
                      'Post Review',
                      style: AppTheme.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: AppTheme.lg),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitComment() {
    if (_commentController.text.trim().isEmpty) return;
    
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Review posted!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
      ),
    );
  }
}
