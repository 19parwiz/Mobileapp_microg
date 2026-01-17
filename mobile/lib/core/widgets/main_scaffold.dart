import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/camera/presentation/camera_screen.dart';
import '../../features/ai/presentation/ai_screen.dart';
import '../../features/my_plants/presentation/my_plants_screen.dart';
import '../../features/more/presentation/more_screen.dart';
import '../../app/router/app_router.dart';
import 'package:go_router/go_router.dart';

/// Main scaffold widget with bottom navigation bar
/// Maintains state when switching tabs using IndexedStack
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  final Map<int, Widget?> _screenCache = {};
  static const int _screenCount = 5;

  // Build screen lazily on first access to prevent blocking
  Widget _buildScreen(int index) {
    if (_screenCache[index] != null) {
      return _screenCache[index]!;
    }

    late final Widget screen;
    switch (index) {
      case 0:
        screen = HomeScreen();
        break;
      case 1:
        screen = CameraScreen();
        break;
      case 2:
        screen = AIScreen();
        break;
      case 3:
        screen = MyPlantsScreen();
        break;
      case 4:
        screen = MoreScreen();
        break;
      default:
        screen = HomeScreen();
    }

    _screenCache[index] = screen;
    return screen;
  }

  @override
  void dispose() {
    _screenCache.clear();
    super.dispose();
  }

  void _onTabTapped(int index) {
    // Validate index is within bounds
    if (index < 0 || index >= _screenCount) {
      debugPrint('Invalid tab index: $index. Valid range: 0-${_screenCount - 1}');
      return;
    }
    debugPrint('MainScaffold: tab tapped $index (current=$_currentIndex)');
    if (index != _currentIndex) {
      // Switch internal tabs
      debugPrint('MainScaffold: about to setState for index $index');
      setState(() {
        debugPrint('MainScaffold: switching internal tab from $_currentIndex to $index');
        _currentIndex = index;
      });
      debugPrint('MainScaffold: setState done, _currentIndex now $_currentIndex');
    } else {
      debugPrint('MainScaffold: tapped same tab $index, doing nothing');
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeIndex = _currentIndex.clamp(0, _screenCount - 1);
    debugPrint('MainScaffold build: _currentIndex=$_currentIndex, safeIndex=$safeIndex');
    
    return Scaffold(
      body: _buildScreen(safeIndex),
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
