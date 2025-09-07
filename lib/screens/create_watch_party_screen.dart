import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_data_store.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/primary_button.dart';
import '../models/media.dart';
import '../models/genre.dart';

class CreateWatchPartyScreen extends StatefulWidget {
  final String? preselectedMovie;
  
  const CreateWatchPartyScreen({
    super.key,
    this.preselectedMovie,
  });

  @override
  State<CreateWatchPartyScreen> createState() => _CreateWatchPartyScreenState();
}

class _CreateWatchPartyScreenState extends State<CreateWatchPartyScreen> {
  final _titleController = TextEditingController();
  final _platformController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  MediaType _selectedType = MediaType.movie;
  Genre _selectedGenre = Genre.action;
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));
  int _maxParticipants = 10;

  @override
  void initState() {
    super.initState();
    if (widget.preselectedMovie != null) {
      _titleController.text = widget.preselectedMovie!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _platformController.dispose();
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
              'Create Watch Party',
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
                    // Movie/Show details
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What are you watching?',
                            style: AppTheme.headline.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryText(brightness),
                            ),
                          ),
                          const SizedBox(height: AppTheme.lg),
                          
                          // Title field
                          TextFormField(
                            controller: _titleController,
                            style: AppTheme.body.copyWith(
                              color: AppTheme.primaryText(brightness),
                            ),
                            decoration: InputDecoration(
                              labelText: 'Title',
                              labelStyle: AppTheme.body.copyWith(
                                color: AppTheme.secondaryText(brightness),
                              ),
                              hintText: 'Enter movie or show title',
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a title';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppTheme.lg),
                          
                          // Type selection
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Type',
                                      style: AppTheme.callout.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryText(brightness),
                                      ),
                                    ),
                                    const SizedBox(height: AppTheme.xs),
                                    DropdownButtonFormField<MediaType>(
                                      value: _selectedType,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedType = value!;
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
                                      items: MediaType.values.map((type) {
                                        return DropdownMenuItem(
                                          value: type,
                                          child: Text(type.displayName),
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
                                      'Genre',
                                      style: AppTheme.callout.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryText(brightness),
                                      ),
                                    ),
                                    const SizedBox(height: AppTheme.xs),
                                    DropdownButtonFormField<Genre>(
                                      value: _selectedGenre,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedGenre = value!;
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
                                      items: Genre.values.map((genre) {
                                        return DropdownMenuItem(
                                          value: genre,
                                          child: Text(genre.displayName),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.lg),
                          
                          // Platform field
                          TextFormField(
                            controller: _platformController,
                            style: AppTheme.body.copyWith(
                              color: AppTheme.primaryText(brightness),
                            ),
                            decoration: InputDecoration(
                              labelText: 'Platform',
                              labelStyle: AppTheme.body.copyWith(
                                color: AppTheme.secondaryText(brightness),
                              ),
                              hintText: 'Netflix, Hulu, Disney+, etc.',
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a platform';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.lg),
                    
                    // Party settings
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Party Settings',
                            style: AppTheme.headline.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryText(brightness),
                            ),
                          ),
                          const SizedBox(height: AppTheme.lg),
                          
                          // Schedule date/time
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                color: AppTheme.secondaryText(brightness),
                              ),
                              const SizedBox(width: AppTheme.sm),
                              Text(
                                'Scheduled for:',
                                style: AppTheme.callout.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryText(brightness),
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: _selectDateTime,
                                child: Text(
                                  '${_selectedDate.day}/${_selectedDate.month} at ${_selectedDate.hour}:${_selectedDate.minute.toString().padLeft(2, '0')}',
                                  style: AppTheme.callout.copyWith(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.lg),
                          
                          // Max participants
                          Row(
                            children: [
                              Icon(
                                Icons.people,
                                color: AppTheme.secondaryText(brightness),
                              ),
                              const SizedBox(width: AppTheme.sm),
                              Text(
                                'Max participants:',
                                style: AppTheme.callout.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryText(brightness),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.minimalSurface(brightness),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: _maxParticipants > 2
                                          ? () {
                                              setState(() {
                                                _maxParticipants--;
                                              });
                                            }
                                          : null,
                                      icon: const Icon(Icons.remove, size: 18),
                                      color: AppTheme.primaryText(brightness),
                                    ),
                                    Text(
                                      _maxParticipants.toString(),
                                      style: AppTheme.callout.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryText(brightness),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _maxParticipants < 20
                                          ? () {
                                              setState(() {
                                                _maxParticipants++;
                                              });
                                            }
                                          : null,
                                      icon: const Icon(Icons.add, size: 18),
                                      color: AppTheme.primaryText(brightness),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.xl),
                    
                    // Create button
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        title: 'Create Watch Party',
                        onPressed: () => _createWatchParty(store),
                        icon: Icons.party_mode,
                        height: AppTheme.buttonHeightLarge,
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

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _createWatchParty(AppDataStore store) {
    if (!_formKey.currentState!.validate()) return;

    final media = MediaItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      type: _selectedType,
      genre: _selectedGenre,
      platform: _platformController.text.trim(),
    );

    store.createWatchParty(media, _selectedDate);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Watch party created successfully!'),
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
