import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app/theme.dart';

class RedeemPartner {
  final String id;
  final String name;
  final String value;
  final String type;
  final IconData icon;

  RedeemPartner({
    required this.id,
    required this.name,
    required this.value,
    required this.type,
    required this.icon,
  });
}

class RedeemScreen extends StatelessWidget {
  const RedeemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<RedeemPartner> partners = [
      RedeemPartner(
        id: '1',
        name: 'United Airlines',
        value: '1.4¢/pt',
        type: 'Flight',
        icon: Icons.flight,
      ),
      RedeemPartner(
        id: '2',
        name: 'Hyatt Hotels',
        value: '2.1¢/pt',
        type: 'Hotel',
        icon: Icons.hotel,
      ),
      RedeemPartner(
        id: '3',
        name: 'Delta Air Lines',
        value: '1.2¢/pt',
        type: 'Flight',
        icon: Icons.flight,
      ),
      RedeemPartner(
        id: '4',
        name: 'Apple Store',
        value: '1.0¢/pt',
        type: 'Shopping',
        icon: Icons.shopping_bag,
      ),
    ];

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
              _buildPointsBalanceCard(),
              const SizedBox(height: 40),
              _buildCategoryGrid(),
              const SizedBox(height: 40),
              _buildHighValuePartners(partners),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Redeem',
          style: GoogleFonts.playfairDisplay(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Best value for your points',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildPointsBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Transform.rotate(
              angle: 0.2,
              child: Icon(
                Icons.card_giftcard,
                size: 160,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL POINTS BALANCE',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppTheme.accentGold,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '142,500',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CASH VALUE',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.4),
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$2,992.50',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
                          'POTENTIAL',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.4),
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+\$420.00',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentGold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      {'icon': Icons.flight, 'label': 'Flights'},
      {'icon': Icons.hotel, 'label': 'Hotels'},
      {'icon': Icons.shopping_bag, 'label': 'Retail'},
      {'icon': Icons.card_giftcard, 'label': 'Gift Cards'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: categories.map((cat) {
        return Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF3F4F6)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                cat['icon'] as IconData,
                color: AppTheme.primaryGreen,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              cat['label'] as String,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF64748B),
                letterSpacing: -0.5,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildHighValuePartners(List<RedeemPartner> partners) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'High Value Partners',
              style: GoogleFonts.inter(
                fontSize: 18,
                color: AppTheme.primaryGreen,
              ),
            ),
            Text(
              'SEE ALL',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentGold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Column(
          children: List.generate(
            partners.length,
            (index) => _buildPartnerItem(partners[index], index),
          ),
        ),
      ],
    );
  }

  Widget _buildPartnerItem(RedeemPartner partner, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  partner.icon,
                  size: 20,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partner.name,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    partner.type,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    partner.value,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'YIELD',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.arrow_forward,
                size: 16,
                color: Color(0xFFD1D5DB),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
