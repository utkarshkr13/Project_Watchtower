import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../services/app_data_store.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/primary_button.dart';
import '../models/social_models.dart';

class CreateRecommendationRequestScreen extends StatefulWidget {
  const CreateRecommendationRequestScreen({super.key});

  @override
  State<CreateRecommendationRequestScreen> createState() => _CreateRecommendationRequestScreenState();
}

class _CreateRecommendationRequestScreenState extends State<CreateRecommendationRequestScreen> {
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  final List<String> _selectedGenres = [];
  MovieIndustry _selectedIndustry = MovieIndustry.both;
  int _startYear = 2020;
  int _endYear = 2024;

  final List<String> _availableGenres = [
    'Action', 'Adventure', 'Animation', 'Comedy', 'Crime',
    'Documentary', 'Drama', 'Family', 'Fantasy', 'History',
    'Horror', 'Music', 'Mystery', 'Romance', 'Sci-Fi',
    'Thriller', 'War', 'Western'
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataStore>(
      builder: (context, store, child) {
        final brightness = store.brightness;
        
        return Scaffold(
          backgroundColor: AppTheme.appBackground(brightness),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: AppTheme.primaryText(brightness),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Request Recommendations',
              style: AppTheme.headline.copyWith(
                color: AppTheme.primaryText(brightness),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Genres selection
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What genres are you interested in?',
                            style: AppTheme.headline.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryText(brightness),
                            ),
                          ),
                          const SizedBox(height: AppTheme.sm),
                          Text(
                            'Select at least one genre',
                            style: AppTheme.caption1.copyWith(
                              color: AppTheme.secondaryText(brightness),
                            ),
                          ),
                          const SizedBox(height: AppTheme.lg),
                          
                          Wrap(
                            spacing: AppTheme.xs,
                            runSpacing: AppTheme.xs,
                            children: _availableGenres.map((genre) {
                              final isSelected = _selectedGenres.contains(genre);
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedGenres.remove(genre);
                                    } else {
                                      _selectedGenres.add(genre);
                                    }
                                  });
                                },
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
                                  child: Text(
                                    genre,
                                    style: AppTheme.caption1.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.primaryText(brightness),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.lg),
                    
                    // Industry preference
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Movie Industry Preference',
                            style: AppTheme.headline.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryText(brightness),
                            ),
                          ),
                          const SizedBox(height: AppTheme.lg),
                          
                          ...MovieIndustry.values.map((industry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppTheme.xs),
                              child: RadioListTile<MovieIndustry>(
                                value: industry,
                                groupValue: _selectedIndustry,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedIndustry = value!;
                                  });
                                },
                                title: Text(
                                  industry.displayName,
                                  style: AppTheme.callout.copyWith(
                                    color: AppTheme.primaryText(brightness),
                                  ),
                                ),
                                activeColor: Colors.blue,
                                contentPadding: EdgeInsets.zero,
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.lg),
                    
                    // Year range
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Year Range',
                            style: AppTheme.headline.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryText(brightness),
                            ),
                          ),
                          const SizedBox(height: AppTheme.lg),
                          
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'From',
                                      style: AppTheme.callout.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryText(brightness),
                                      ),
                                    ),
                                    const SizedBox(height: AppTheme.xs),
                                    DropdownButtonFormField<int>(
                                      value: _startYear,
                                      onChanged: (value) {
                                        setState(() {
                                          _startYear = value!;
                                          if (_endYear < _startYear) {
                                            _endYear = _startYear;
                                          }
                                        });
                                      },
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                          borderSide: BorderSide(
                                            color: AppTheme.minimalStroke(brightness),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                          borderSide: BorderSide(
                                            color: AppTheme.minimalStroke(brightness),
                                          ),
                                        ),
                                      ),
                                      dropdownColor: AppTheme.appBackground(brightness),
                                      style: AppTheme.body.copyWith(
                                        color: AppTheme.primaryText(brightness),
                                      ),
                                      items: List.generate(25, (index) => 2000 + index)
                                          .map((year) {
                                        return DropdownMenuItem(
                                          value: year,
                                          child: Text(year.toString()),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppTheme.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'To',
                                      style: AppTheme.callout.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryText(brightness),
                                      ),
                                    ),
                                    const SizedBox(height: AppTheme.xs),
                                    DropdownButtonFormField<int>(
                                      value: _endYear,
                                      onChanged: (value) {
                                        setState(() {
                                          _endYear = value!;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                          borderSide: BorderSide(
                                            color: AppTheme.minimalStroke(brightness),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                          borderSide: BorderSide(
                                            color: AppTheme.minimalStroke(brightness),
                                          ),
                                        ),
                                      ),
                                      dropdownColor: AppTheme.appBackground(brightness),
                                      style: AppTheme.body.copyWith(
                                        color: AppTheme.primaryText(brightness),
                                      ),
                                      items: List.generate(25, (index) => 2000 + index)
                                          .where((year) => year >= _startYear)
                                          .map((year) {
                                        return DropdownMenuItem(
                                          value: year,
                                          child: Text(year.toString()),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.lg),
                    
                    // Note
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Additional Note (Optional)',
                            style: AppTheme.headline.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryText(brightness),
                            ),
                          ),
                          const SizedBox(height: AppTheme.lg),
                          
                          TextFormField(
                            controller: _noteController,
                            maxLines: 3,
                            style: AppTheme.body.copyWith(
                              color: AppTheme.primaryText(brightness),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Tell your friends what you\'re looking for...',
                              hintStyle: AppTheme.body.copyWith(
                                color: AppTheme.secondaryText(brightness).withOpacity(0.7),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                borderSide: BorderSide(
                                  color: AppTheme.minimalStroke(brightness),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                borderSide: BorderSide(
                                  color: AppTheme.minimalStroke(brightness),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.xl),
                    
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        title: 'Send Request',
                        onPressed: _selectedGenres.isNotEmpty ? () => _createRequest(store) : null,
                        icon: Icons.send,
                        height: AppTheme.buttonHeightLarge,
                        isDisabled: _selectedGenres.isEmpty,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _createRequest(AppDataStore store) {
    const uuid = Uuid();
    
    final request = RecommendationRequest(
      id: uuid.v4(),
      userId: store.currentUser.id,
      genreTags: _selectedGenres,
      yearRange: YearRange(startYear: _startYear, endYear: _endYear),
      movieIndustry: _selectedIndustry,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    store.addRecommendationRequest(request);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Recommendation request sent to friends!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
      ),
    );

    Navigator.of(context).pop();
  }
}
