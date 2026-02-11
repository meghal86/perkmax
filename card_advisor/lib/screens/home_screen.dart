import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/theme.dart';

import 'recommendation_detail_screen.dart';
import 'package:provider/provider.dart';
import '../models/merchant_resolution_result.dart';
import '../services/merchant_service.dart';
import '../services/recommendation_service.dart';
import '../providers/card_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  late MerchantService
  _merchantService; // Changed to late and removed direct instantiation
  final RecommendationService _recommendationService = RecommendationService();

  bool _isLoading = false;
  MerchantResolutionResult? _merchantResult;
  CardRecommendation? // Kept original type, removed comment
  _bestCardRecommendation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _merchantService = Provider.of<MerchantService>(context, listen: false);
  }

  Future<void> _onAutoDetect() async {
    setState(() {
      _isLoading = true;
      _merchantResult = null;
      _bestCardRecommendation = null;
      _searchController.text = "Detecting location...";
    });

    try {
      // 1. Resolve Location
      final result = await _merchantService.resolveCurrentLocation();

      if (!mounted) return;

      if (result.confidenceBand == ConfidenceBand.LOW &&
          result.merchant == null) {
        print("HomeScreen: Location resolution failed: ${result.reason}");
        setState(() {
          _isLoading = false;
          _searchController.text = "Location not found";
        });
        return;
      }

      // 2. Update UI with Merchant Info
      final merchantName = result.merchant?.name ?? "Unknown Merchant";
      final merchantCategory = result.merchant?.category ?? "General";

      setState(() {
        _merchantResult = result;
        _searchController.text = merchantName;
      });

      // 3. Get Recommendation
      final cards = Provider.of<CardProvider>(context, listen: false).cards;
      if (cards.isNotEmpty) {
        final category = _recommendationService.matchCategory(merchantCategory);
        final recommendations = _recommendationService.getRecommendations(
          cards: cards,
          category: category,
        );

        if (recommendations.isNotEmpty) {
          setState(() {
            _bestCardRecommendation = recommendations.first;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchController.text = "Error detecting location";
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildHeroSearch(),
              const SizedBox(height: 40),
              _buildRecommendationSection(),
              const SizedBox(height: 40),
              _buildQuickStats(),
              const SizedBox(height: 40),
              _buildRecentWins(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PerkMax',
              style: GoogleFonts.playfairDisplay(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your financial co-pilot',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFF3F4F6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.security,
            color: AppTheme.primaryGreen,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSearch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Where are you shopping?',
              hintStyle: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF94A3B8),
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            style: GoogleFonts.inter(fontSize: 16),
          ),
          Positioned(
            right: 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: InkWell(
                onTap: _isLoading ? null : _onAutoDetect,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _isLoading
                        ? AppTheme.primaryGreen.withOpacity(0.1)
                        : const Color(0xFFF9FAFB),
                    border: Border.all(color: const Color(0xFFF3F4F6)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'AUTO-DETECT',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF9CA3AF),
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recommendation',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_merchantResult != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.05),
                    border: Border.all(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _getConfidenceColor(
                            _merchantResult!.confidenceBand,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_merchantResult!.confidenceBand.name} CONFIDENCE',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox.shrink(), // Hide if no result yet (or keep static logic if preferred)
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildRecommendationCard(),
      ],
    );
  }

  Color _getConfidenceColor(ConfidenceBand band) {
    switch (band) {
      case ConfidenceBand.HIGH:
        return const Color(0xFF10B981);
      case ConfidenceBand.MEDIUM:
        return Colors.orange;
      case ConfidenceBand.LOW:
        return Colors.red;
    }
  }

  Widget _buildRecommendationCard() {
    // If we have a live recommendation, use it
    if (_bestCardRecommendation != null) {
      final card = _bestCardRecommendation!.card;
      final merchantName = _merchantResult?.merchant?.name ?? "this location";
      final rate = _bestCardRecommendation!.cashbackRate;

      return GestureDetector(
        onTap: () {
          // Navigator.push(context, MaterialPageRoute(builder: (context) => RecommendationDetailScreen(recommendation: _bestCardRecommendation)));
          // Assuming detail screen takes optional recommendation or we just push generic for now
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RecommendationDetailScreen(),
            ),
          );
        },
        child: Stack(
          children: [
            // Shadow layer
            Positioned(
              left: 0,
              right: 0,
              top: 16,
              bottom: -16,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.2),
                      blurRadius: 80,
                      spreadRadius: -10,
                    ),
                  ],
                ),
              ),
            ),
            // Main card
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF2C3E50),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(120),
                ),
                gradient: RadialGradient(
                  center: const Alignment(-1, -1),
                  radius: 1.5,
                  colors: [
                    AppTheme.accentGold.withOpacity(0.1),
                    const Color(0xFF2C3E50),
                  ],
                  stops: const [0.0, 0.5],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Use this card at $merchantName',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppTheme.accentGold,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              card.cardNickname,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 24,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${rate.toStringAsFixed(1)}x',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: AppTheme.accentGold,
                              height: 1,
                              letterSpacing: -1,
                            ),
                          ),
                          Text(
                            'POINTS',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.5),
                              letterSpacing: 2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CARD ENDING IN',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: Colors.white.withOpacity(0.4),
                                letterSpacing: 2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    card.cardType.name.toUpperCase(),
                                    style: GoogleFonts.inter(
                                      fontSize: 8,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '•••• ${card.lastFourDigits}',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // ... Optimized badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppTheme.accentGold,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accentGold.withOpacity(0.4),
                                    blurRadius: 8,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.bolt,
                                color: Color(0xFF2C3E50),
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'OPTIMIZED',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Fallback to static if no live recommendation
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RecommendationDetailScreen(),
          ),
        );
      },
      child: Stack(
        children: [
          // Shadow layer
          Positioned(
            left: 0,
            right: 0,
            top: 16,
            bottom: -16,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.2),
                    blurRadius: 80,
                    spreadRadius: -10,
                  ),
                ],
              ),
            ),
          ),
          // Main card
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF2C3E50),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(120),
              ),
              gradient: RadialGradient(
                center: const Alignment(-1, -1),
                radius: 1.5,
                colors: [
                  AppTheme.accentGold.withOpacity(0.1),
                  const Color(0xFF2C3E50),
                ],
                stops: const [0.0, 0.5],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Use this card at Best Buy',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppTheme.accentGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Chase Freedom Unlimited',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 24,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '3.5x',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: AppTheme.accentGold,
                            height: 1,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          'POINTS',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.5),
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CARD ENDING IN',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.4),
                              letterSpacing: 2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'VISA',
                                  style: GoogleFonts.inter(
                                    fontSize: 8,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '•••• 4242',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accentGold.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.bolt,
                              color: Color(0xFF2C3E50),
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'OPTIMIZED',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'Total Saved',
            value: '\$428.12',
            accentColor: AppTheme.accentGold,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            label: 'Active Goals',
            value: '2',
            accentColor: AppTheme.primaryGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentWins() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Wins',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Text(
                    'HISTORY',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentGold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppTheme.accentGold,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildWinItem(
          icon: '☕',
          name: 'Starbucks',
          date: 'Today',
          saved: '\$1.40',
        ),
        const SizedBox(height: 12),
        _buildWinItem(
          icon: '📦',
          name: 'Amazon',
          date: 'Yesterday',
          saved: '\$12.20',
        ),
      ],
    );
  }

  Widget _buildWinItem({
    required String icon,
    required String name,
    required String date,
    required String saved,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+$saved',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }
}
