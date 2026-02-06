import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../app/theme.dart';

class RecommendationDetailScreen extends StatelessWidget {
  const RecommendationDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildHeroCard(context),
                    const SizedBox(height: 32),
                    _buildConfidenceSection(context),
                    const SizedBox(height: 24),
                    _buildBenefitsList(context),
                    const SizedBox(height: 32),
                    _buildActionButtons(context),
                    const SizedBox(height: 16),
                    Text(
                      'ADVISORY ONLY • NO PAN STORED • ENCRYPTED BY PERKMAX',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFF5F5F7),
            radius: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.grey, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Text(
            'Card Advisory',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(width: 40), // Balance spacing
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF004D40), // Deep Green matching design
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        children: [
          // Shield Watermark
          Positioned(
            right: -20,
            top: 20,
            child: Opacity(
              opacity: 0.1,
              child: Icon(
                Icons.security, // Replaced LucideIcons.shieldCheck
                size: 180,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Optimized for Best Buy',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFD4AF37),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Chase Freedom Unlimited',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 28,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REWARDS',
                            style: GoogleFonts.inter(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '3.5x',
                            style: GoogleFonts.playfairDisplay(
                              color: const Color(0xFFD4AF37),
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EST. VALUE',
                            style: GoogleFonts.inter(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$52.50',
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
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

  Widget _buildConfidenceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Why this recommendation?',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.info_outline, size: 18, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Confidence Level',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    'HIGH',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // ARC CHART - Fixed size to prevent overflow
              Center(
                child: SizedBox(
                  width: 200,
                  height: 120,
                  child: CustomPaint(
                    painter: ArcChartPainter(percentage: 0.85),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '85%',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                          Text(
                            'MATCH RATE',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '"Based on your last 3 visits to Best Buy and current Chase quarterly offers, this card maximizes your 5% electronics category."',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsList(BuildContext context) {
    return Column(
      children: [
        _buildBenefitCard(
          icon: Icons.trending_up,
          iconColor: const Color(0xFFD4AF37),
          bgColor: const Color(0xFFFFF8E1),
          title: 'Category Bonus',
          subtitle: '3% base on all electronic retailers',
        ),
        const SizedBox(height: 16),
        _buildBenefitCard(
          icon: Icons.shield_outlined,
          iconColor: const Color(0xFF2E7D32),
          bgColor: const Color(0xFFE8F5E9),
          title: 'Purchase Protection',
          subtitle: 'Includes 1-year extended warranty',
        ),
      ],
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.playfairDisplay(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: Colors.grey[500],
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Confirm Using This Card',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () {}, // Add functionality later
            icon: const Icon(
              Icons.help_outline,
              size: 18,
            ), // Replaced LucideIcons.helpCircle
            label: Text(
              'Override Recommendation',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[400],
              side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ArcChartPainter extends CustomPainter {
  final double percentage;

  ArcChartPainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    const strokeWidth = 12.0;

    // Background Arc
    final bgPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi, // Start from left (180 deg)
      math.pi, // Sweep 180 deg
      false,
      bgPaint,
    );

    // Foreground Arc (Progress)
    final fgPaint = Paint()
      ..color = const Color(0xFF004D40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = math.pi * percentage;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi, // Start from left
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
