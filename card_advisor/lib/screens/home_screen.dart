import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../providers/card_provider.dart';
import '../models/credit_card.dart';
import 'recommendation_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildSearchField(context),
              const SizedBox(height: 24),
              _buildRecommendationSection(context),
              const SizedBox(height: 24),
              _buildStatsRow(context),
              const SizedBox(height: 32),
              _buildRecentWins(context),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFD4AF37),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              _showChatModal(context);
            },
            child: const Icon(Icons.chat_bubble, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  void _showChatModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const Center(child: Text("Chat Bot Placeholder")),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PerkMax',
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppTheme.primaryGreen,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your financial co-pilot',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textDark.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.verified_user_outlined,
            color: AppTheme.primaryGreen,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        // REMOVED BORDER HERE
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Where are you shopping?',
                hintStyle: GoogleFonts.inter(
                  color: Colors.grey.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'AUTO-DETECT',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recommendation',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryGreen,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFC8E6C9)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 6),
                  Text(
                    'HIGH CONFIDENCE',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF263238),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF263238).withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                Positioned(
                  right: -80,
                  bottom: -80,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  right: -60,
                  bottom: -60,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  // REDUCED PADDING 28 -> 22 to reduce height
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Use this card at Best Buy',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFD4AF37),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Chase Freedom\nUnlimited',
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w500,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '3.5x',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFD4AF37),
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'POINTS',
                              style: GoogleFonts.inter(
                                color: const Color(
                                  0xFFD4AF37,
                                ).withValues(alpha: 0.8),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16), // Reduced space 24 -> 16
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'VISA',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '•••• 4242',
                                style: GoogleFonts.inter(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 14,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RecommendationDetailScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ), // Adjusted padding
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.bolt,
                                    color: Color(0xFFD4AF37),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'OPTIMIZED',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatsCard(
            title: 'TOTAL SAVED',
            value: '\$428.12',
            valueColor: AppTheme.primaryGreen,
            decorationColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatsCard(
            title: 'ACTIVE GOALS',
            value: '2',
            valueColor: AppTheme.textDark,
            decorationColor: AppTheme.textDark.withValues(alpha: 0.05),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard({
    required String title,
    required String value,
    required Color valueColor,
    required Color decorationColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: decorationColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: decorationColor.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500],
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: valueColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentWins(BuildContext context) {
    final wins = [
      {
        'store': 'Starbucks',
        'subtitle': 'Today',
        'amount': '+\$1.40',
        'color': 0xFF795548,
      },
      {
        'store': 'Amazon',
        'subtitle': 'Yesterday',
        'amount': '+\$12.20',
        'color': 0xFFE65100,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Wins',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
            Row(
              children: [
                Text(
                  'HISTORY',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFD4AF37),
                  size: 16,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...wins
            .map(
              (win) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
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
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          win['store'] == 'Starbucks'
                              ? Icons.coffee
                              : Icons.local_shipping,
                          color: Color(win['color'] as int),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              win['store'] as String,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              win['subtitle'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        win['amount'] as String,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2E7D32),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ],
    );
  }
}
