import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'app/theme.dart';
import 'providers/card_provider.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/history_screen.dart';
import 'screens/redeem_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/debug_service_screen.dart';

import 'services/background_sync_manager.dart';
import 'database/app_database.dart';
import 'database/daos/cards_dao.dart';
import 'database/daos/user_wallet_dao.dart';
import 'database/daos/merchants_dao.dart';
import 'database/daos/spend_dao.dart';
import 'services/card_seed_loader.dart';
import 'services/recommendation_engine.dart';
import 'services/merchant_service.dart';

void main() async {
  print('DEBUG: Starting main()');
  WidgetsFlutterBinding.ensureInitialized();
  print('DEBUG: EnsureInitialized done');

  // Initialize Background Sync
  try {
    print('DEBUG: Initializing BackgroundSyncManager');
    await BackgroundSyncManager.initialize();
    print('DEBUG: BackgroundSyncManager initialized');
    await BackgroundSyncManager.registerPeriodicTask();
    print('DEBUG: Periodic task registered');
  } catch (e) {
    print('DEBUG: BackgroundSyncManager error: $e');
  }

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.windows)) {
    print('DEBUG: Configuring WindowManager');
    await windowManager.ensureInitialized();
    // ...
    WindowOptions windowOptions = const WindowOptions(
      size: Size(393, 852), // iPhone 16 Pro dimensions
      minimumSize: Size(393, 852),
      center: true,
      backgroundColor:
          Colors.black, // Changed from transparent to visible color
      skipTaskbar: false,
      title: 'PerkMax',
    );
    // ...
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
    print('DEBUG: WindowManager configured');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  try {
    print('DEBUG: Initializing Database');
    // Initialize Database & Seed
    final dbHelper = DatabaseHelper.instance;
    final cardsDao = CardsDao(dbHelper: dbHelper);
    final seedLoader = CardSeedLoader(cardsDao: cardsDao);

    print('DEBUG: Loading Seed Data');
    // Load initial seed data (fast check)
    await seedLoader.loadSeedData();
    print('DEBUG: Seed Data Loaded');

    // Initialize other DAOs
    final userWalletDao = UserWalletDao(dbHelper: dbHelper);
    final merchantsDao = MerchantsDao(dbHelper: dbHelper);
    final spendDao = SpendDao(dbHelper: dbHelper);

    // Initialize Engine
    final recommendationEngine = RecommendationEngine(
      cardsDao: cardsDao,
      userWalletDao: userWalletDao,
      merchantsDao: merchantsDao,
      spendDao: spendDao,
    );

    // Initialize MerchantService
    final merchantService = MerchantService(merchantsDao: merchantsDao);

    // Seed test merchants for debugging
    print('DEBUG: Seeding Test Merchants');
    await merchantService.seedTestMerchants();

    print('DEBUG: Running App');
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CardProvider()),
          Provider<RecommendationEngine>.value(value: recommendationEngine),
          Provider<MerchantService>.value(value: merchantService),
          Provider<CardsDao>.value(value: cardsDao),
          Provider<UserWalletDao>.value(value: userWalletDao),
          Provider<MerchantsDao>.value(value: merchantsDao),
          Provider<SpendDao>.value(value: spendDao),
        ],
        child: const CardAdvisorApp(),
      ),
    );
  } catch (e, stack) {
    print('DEBUG: Error in main: $e');
    print(stack);
    // Attempt to run app anyway so error can be seen if possible, or at least it doesn't stay blank black
    runApp(
      MaterialApp(
        home: Scaffold(body: Center(child: Text('Error: $e'))),
      ),
    );
  }
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
    return MaterialApp(
      title: 'PerkMax',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _showSplash
          ? SplashScreen(onComplete: _completeSplash)
          : const MainNavigationScreen(),
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

  final List<Widget> _screens = const [
    HomeScreen(),
    WalletScreen(),
    ChatbotScreen(), // Center AI tab
    HistoryScreen(),
    DebugServiceScreen(), // Replaces PlannerScreen for testing
    RedeemScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: const Color(0xFFF3F4F6), width: 1),
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.account_balance_wallet_outlined,
                  activeIcon: Icons.account_balance_wallet,
                  label: 'Wallet',
                ),
                // Center AI button opens Chatbot
                _buildCenterAIButton(),
                _buildNavItem(
                  index: 3,
                  icon: Icons.history,
                  activeIcon: Icons.history,
                  label: 'History',
                ),
                _buildNavItem(
                  index: 4,
                  icon: Icons.flag_outlined,
                  activeIcon: Icons.flag,
                  label: 'Planner',
                ),
                _buildNavItem(
                  index: 5,
                  icon: Icons.card_giftcard_outlined,
                  activeIcon: Icons.card_giftcard,
                  label: 'Redeem',
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppTheme.primaryGreen : const Color(0xFF9CA3AF),
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          if (isActive)
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppTheme.primaryGreen,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCenterAIButton() {
    final isActive = _currentIndex == 2;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryGreen : AppTheme.accentGold,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isActive ? AppTheme.primaryGreen : AppTheme.accentGold)
                  .withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Icon(
          Icons.auto_awesome,
          color: isActive ? Colors.white : AppTheme.primaryGreen,
          size: 24,
        ),
      ),
    );
  }
}
