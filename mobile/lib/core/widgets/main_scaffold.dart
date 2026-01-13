import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/camera/presentation/camera_screen.dart';
import '../../features/ai/presentation/ai_screen.dart';
import '../../features/my_plants/presentation/my_plants_screen.dart';
import '../../features/more/presentation/more_screen.dart';

/// Main scaffold widget with bottom navigation bar
/// Maintains state when switching tabs using IndexedStack
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final List<Widget> _screens;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize screens - these will maintain their state
    _screens = const [
      HomeScreen(),
      CameraScreen(),
      AIScreen(),
      MyPlantsScreen(),
      MoreScreen(),
    ];
    
    // Setup animation controller for subtle tab switching animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    // Validate index is within bounds
    if (index < 0 || index >= _screens.length) {
      debugPrint('Invalid tab index: $index. Valid range: 0-${_screens.length - 1}');
      return;
    }
    
    if (index != _currentIndex) {
      // Animate tab switch
      _animationController.reset();
      setState(() {
        _currentIndex = index;
      });
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure screens are initialized and currentIndex is within valid range
    if (_screens.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    final safeIndex = _currentIndex.clamp(0, _screens.length - 1);
    
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: IndexedStack(
          index: safeIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: safeIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary.withOpacity(0.6),
          selectedLabelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
          unselectedLabelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary.withOpacity(0.6),
              ),
          elevation: 8,
          items: [
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                isSelected: _currentIndex == 0,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(
                icon: Icons.camera_alt_outlined,
                selectedIcon: Icons.camera_alt,
                isSelected: _currentIndex == 1,
              ),
              label: 'Camera',
            ),
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(
                icon: Icons.psychology_alt_outlined,
                selectedIcon: Icons.psychology,
                isSelected: _currentIndex == 2,
              ),
              label: 'AI',
            ),
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(
                icon: Icons.local_florist_outlined,
                selectedIcon: Icons.local_florist,
                isSelected: _currentIndex == 3,
              ),
              label: 'My Plants',
            ),
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(
                icon: Icons.more_horiz,
                selectedIcon: Icons.more_horiz,
                isSelected: _currentIndex == 4,
              ),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }

  /// Build animated icon with subtle scale animation
  Widget _buildAnimatedIcon({
    required IconData icon,
    required IconData selectedIcon,
    required bool isSelected,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      transform: Matrix4.identity()..scale(isSelected ? 1.1 : 1.0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: animation,
            child: child,
          );
        },
        child: Icon(
          isSelected ? selectedIcon : icon,
          key: ValueKey<bool>(isSelected),
        ),
      ),
    );
  }
}
