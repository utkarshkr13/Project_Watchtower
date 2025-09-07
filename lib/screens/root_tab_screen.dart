import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/app_data_store.dart';
import '../theme/app_theme.dart';
import 'enhanced_home_screen.dart';
import 'ask_screen.dart';
import 'watchlist_screen.dart';
import 'connect_screen.dart';
import 'profile_screen.dart';

enum MainTab { home, ask, watchlist, friends, profile }

class RootTabScreen extends StatefulWidget {
  const RootTabScreen({super.key});

  @override
  State<RootTabScreen> createState() => _RootTabScreenState();
}

class _RootTabScreenState extends State<RootTabScreen>
    with TickerProviderStateMixin {
  MainTab _selectedTab = MainTab.home;
  final PageController _pageController = PageController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onTabSelected(MainTab tab) {
    if (_selectedTab == tab) return;
    
    setState(() {
      _selectedTab = tab;
    });
    
    _animationController.reset();
    _animationController.forward();
    
    _pageController.animateToPage(
      tab.index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<AppDataStore>(context);
    final brightness = store.brightness;
    
    return Scaffold(
      backgroundColor: AppTheme.appBackground(brightness),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedTab = MainTab.values[index];
          });
          _animationController.reset();
          _animationController.forward();
        },
        children: const [
          EnhancedHomeScreen(),
          AskScreen(),
          WatchlistScreen(),
          ConnectScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildModernBottomNavigationBar(brightness),
    );
  }

  Widget _buildModernBottomNavigationBar(Brightness brightness) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.appBackground(brightness),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryText(brightness).withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: AppTheme.navHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.gridMargin,
            vertical: AppTheme.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildModernTabItem(
                tab: MainTab.home,
                title: 'Home',
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                brightness: brightness,
              ),
              _buildModernTabItem(
                tab: MainTab.ask,
                title: 'Ask',
                icon: Icons.help_outline,
                selectedIcon: Icons.help,
                brightness: brightness,
              ),
              _buildModernTabItem(
                tab: MainTab.watchlist,
                title: 'Watchlist',
                icon: Icons.bookmark_outline,
                selectedIcon: Icons.bookmark,
                brightness: brightness,
              ),
              _buildModernTabItem(
                tab: MainTab.friends,
                title: 'Friends',
                icon: Icons.people_outline,
                selectedIcon: Icons.people,
                brightness: brightness,
              ),
              _buildModernTabItem(
                tab: MainTab.profile,
                title: 'Profile',
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                brightness: brightness,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTabItem({
    required MainTab tab,
    required String title,
    required IconData icon,
    required IconData selectedIcon,
    required Brightness brightness,
  }) {
    final isSelected = _selectedTab == tab;
    
    return GestureDetector(
      onTap: () => _onTabSelected(tab),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container with animated background
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(AppTheme.sm),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppTheme.primaryColor(brightness).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSelected ? selectedIcon : icon,
                size: 24,
                color: isSelected 
                    ? AppTheme.primaryColor(brightness)
                    : AppTheme.secondaryText(brightness),
              ),
            ).animate(target: isSelected ? 1 : 0)
             .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0)),
            
            const SizedBox(height: 4),
            
            // Label with animated color
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTheme.caption.copyWith(
                color: isSelected 
                    ? AppTheme.primaryColor(brightness)
                    : AppTheme.secondaryText(brightness),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                height: 1.2,
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            const SizedBox(height: 2),
            
            // Active indicator underline
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              height: 2,
              width: isSelected ? 20 : 0,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor(brightness),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension MainTabExtension on MainTab {
  int get index {
    switch (this) {
      case MainTab.home:
        return 0;
      case MainTab.ask:
        return 1;
      case MainTab.watchlist:
        return 2;
      case MainTab.friends:
        return 3;
      case MainTab.profile:
        return 4;
    }
  }
}