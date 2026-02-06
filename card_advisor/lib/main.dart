import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'app/theme.dart';
import 'providers/card_provider.dart';
import 'screens/home_screen.dart';
import 'screens/cards_screen.dart';
import 'screens/recommend_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.windows)) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(393, 852), // iPhone 16 Pro dimensions
      minimumSize: Size(393, 852),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      title: 'PerkMax',
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const CardAdvisorApp());
}

class CardAdvisorApp extends StatefulWidget {
  const CardAdvisorApp({super.key});

  @override
  State<CardAdvisorApp> createState() => _CardAdvisorAppState();
}

class _CardAdvisorAppState extends State<CardAdvisorApp> {
  bool _showSplash = true;

  void _completeSplash() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CardProvider())],
      child: MaterialApp(
        title: 'PerkMax',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: _showSplash
            ? SplashScreen(onComplete: _completeSplash)
            : const MainNavigationScreen(),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CardsScreen(),
    const RecommendScreen(),
    const ChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.credit_card_outlined,
                  activeIcon: Icons.credit_card,
                  label: 'Cards',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.recommend_outlined,
                  activeIcon: Icons.recommend,
                  label: 'Suggest',
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.chat_bubble_outline,
                  activeIcon: Icons.chat_bubble,
                  label: 'AI Chat',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryGreen.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppTheme.primaryGreen : Colors.grey,
              size: 24,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
