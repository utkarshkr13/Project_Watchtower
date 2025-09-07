import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_data_store.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/primary_button.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataStore>(
      builder: (context, store, child) {
        final brightness = store.brightness;
        
        return Scaffold(
          backgroundColor: AppTheme.appBackground(brightness),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
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
                      'Profile',
                      style: AppTheme.largeTitle.copyWith(
                        color: AppTheme.primaryText(brightness),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(AppTheme.lg),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Profile header
                      GlassCard(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.blue.withOpacity(0.2),
                              child: Text(
                                store.currentUser.name[0].toUpperCase(),
                                style: AppTheme.largeTitle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppTheme.md),
                            Text(
                              store.currentUser.name,
                              style: AppTheme.title2.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryText(brightness),
                              ),
                            ),
                            const SizedBox(height: AppTheme.xs),
                            Text(
                              '${store.friends.length} friends • ${store.activities.where((a) => a.userId == store.currentUser.id).length} activities',
                              style: AppTheme.subheadline.copyWith(
                                color: AppTheme.secondaryText(brightness),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.lg),
                      
                      // Theme settings
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Appearance',
                              style: AppTheme.headline.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryText(brightness),
                              ),
                            ),
                            const SizedBox(height: AppTheme.md),
                            Row(
                              children: [
                                Icon(
                                  brightness == Brightness.dark ? Icons.dark_mode : Icons.light_mode,
                                  color: AppTheme.secondaryText(brightness),
                                ),
                                const SizedBox(width: AppTheme.sm),
                                Text(
                                  'Theme',
                                  style: AppTheme.callout.copyWith(
                                    color: AppTheme.primaryText(brightness),
                                  ),
                                ),
                                const Spacer(),
                                Switch(
                                  value: brightness == Brightness.dark,
                                  onChanged: (_) => store.toggleTheme(),
                                  activeColor: Colors.blue,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.lg),
                      
                      // Favorite genres
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Favorite Genres',
                              style: AppTheme.headline.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryText(brightness),
                              ),
                            ),
                            const SizedBox(height: AppTheme.md),
                            Wrap(
                              spacing: AppTheme.xs,
                              runSpacing: AppTheme.xs,
                              children: store.currentUser.favoriteGenres.map((genre) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppTheme.sm,
                                    vertical: AppTheme.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                    border: Border.all(
                                      color: Colors.blue.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    genre.displayName,
                                    style: AppTheme.caption1.copyWith(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.lg),
                      
                      // Achievements
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Achievements',
                              style: AppTheme.headline.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryText(brightness),
                              ),
                            ),
                            const SizedBox(height: AppTheme.md),
                            ...store.achievements.take(3).map((achievement) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppTheme.sm),
                                child: Row(
                                  children: [
                                    Text(
                                      achievement.type.icon,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(width: AppTheme.sm),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            achievement.type.displayName,
                                            style: AppTheme.callout.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.primaryText(brightness),
                                            ),
                                          ),
                                          Text(
                                            achievement.type.description,
                                            style: AppTheme.caption1.copyWith(
                                              color: AppTheme.secondaryText(brightness),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            if (store.achievements.length > 3)
                              Text(
                                '+${store.achievements.length - 3} more achievements',
                                style: AppTheme.caption1.copyWith(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.xl),
                      
                      // Logout button
                      PrimaryButton(
                        title: 'Sign Out',
                        onPressed: () => _logout(context, store),
                        backgroundColor: Colors.red,
                        icon: Icons.logout,
                      ),
                      const SizedBox(height: AppTheme.xl),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _logout(BuildContext context, AppDataStore store) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      await store.logout();
      
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (route) => false,
      );
    }
  }
}
