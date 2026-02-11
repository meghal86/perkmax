import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../models/credit_card.dart';
import '../widgets/card_edit_drawer.dart';
import '../providers/card_provider.dart';
import 'card_catalog_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isListView = true;

  @override
  void initState() {
    super.initState();
    // Refresh cards when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CardProvider>().loadCards();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _deleteCard(String id) {
    context.read<CardProvider>().removeCard(id);
  }

  void _showCardDrawer(CreditCard card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CardEditDrawer(
        card: card,
        onClose: () => Navigator.pop(context),
        onDelete: () => _deleteCard(card.id),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  String _getBankName(String nickname) {
    if (nickname.contains('Chase')) return 'Chase';
    if (nickname.contains('Amex')) return 'American Express';
    if (nickname.contains('Apple')) return 'Apple Card';
    if (nickname.contains('Capital One')) return 'Capital One';
    return 'Bank';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildSearchBar(),
                  const SizedBox(height: 40),
                  _buildCardsList(),
                  const SizedBox(height: 48),
                  _buildSecurityDisclaimer(),
                ],
              ),
            ),
            _buildAddCardFAB(),
          ],
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
              'My Cards',
              style: GoogleFonts.playfairDisplay(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Consumer<CardProvider>(
                    builder: (context, provider, child) => Text(
                      '${provider.cards.length} ACTIVE',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    Icon(
                      Icons.lock,
                      size: 10,
                      color: Colors.grey.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ENCRYPTED',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        letterSpacing: 1.5,
                        color: Colors.grey.withValues(alpha: 0.4),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            _buildIconButton(
              icon: _isListView ? Icons.grid_view : Icons.view_list,
              onTap: () => setState(() => _isListView = !_isListView),
            ),
            const SizedBox(width: 8),
            _buildIconButton(icon: Icons.file_download_outlined, onTap: () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF3F4F6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
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
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by bank or card name...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
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
              style: GoogleFonts.inter(fontSize: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildIconButton(icon: Icons.filter_list, onTap: () {}),
      ],
    );
  }

  Widget _buildCardsList() {
    return Consumer<CardProvider>(
      builder: (context, provider, child) {
        final cards = provider.cards;

        if (cards.isEmpty) {
          return Center(
            child: Text(
              'No cards in wallet.\nTap + to add cards.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.grey),
            ),
          );
        }

        if (_isListView) {
          return Column(
            children: List.generate(
              cards.length,
              (index) =>
                  _buildCardItem(cards[index], index, totalCount: cards.length),
            ),
          );
        } else {
          return SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: cards.length,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: SizedBox(
                    width: 300,
                    child: _buildCardItem(
                      cards[index],
                      index,
                      isCarousel: true,
                      totalCount: cards.length,
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildCardItem(
    CreditCard card,
    int index, {
    bool isCarousel = false,
    required int totalCount,
  }) {
    final cardColor = _parseColor(card.cardColor);
    final isDark = [
      const Color(0xFF000000),
      const Color(0xFF2C3E50),
      const Color(0xFF004D40),
      const Color(0xFF114499),
    ].any((c) => c.value == cardColor.value);

    final bankName = _getBankName(card.cardNickname);
    final annualFee = _getAnnualFee(card.cardNickname);
    final isHighConfidence = card.id == '1';

    return Container(
      margin: EdgeInsets.only(
        bottom: _isListView ? (index == totalCount - 1 ? 0 : 0) : 0,
        top: index * (_isListView && !isCarousel ? 0 : 0),
      ),
      child: Transform.translate(
        offset: Offset(0, index * (_isListView && !isCarousel ? -80 : 0)),
        child: GestureDetector(
          onTap: () => _showCardDrawer(card),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: _getGradient(cardColor, bankName),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(32),
              ),
              border: isDark
                  ? null
                  : Border.all(color: const Color(0xFFF3F4F6)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -80,
                  left: -80,
                  child: Container(
                    width: 256,
                    height: 256,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bankName.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        (isDark ? Colors.white : Colors.black)
                                            .withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  card.cardNickname,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic,
                                    color: isDark ? Colors.white : Colors.black,
                                    height: 1.1,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              if (annualFee > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentGold.withValues(
                                      alpha: 0.2,
                                    ),
                                    border: Border.all(
                                      color: AppTheme.accentGold.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '\$$annualFee FEE',
                                    style: GoogleFonts.inter(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.accentGold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              if (isHighConfidence) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withValues(alpha: 0.2),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF10B981,
                                      ).withValues(alpha: 0.3),
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.star,
                                    size: 10,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '•••• ${card.lastFourDigits}',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  letterSpacing: 4,
                                  fontWeight: FontWeight.w500,
                                  color: (isDark ? Colors.white : Colors.black)
                                      .withValues(alpha: 0.9),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.lock,
                                    size: 10,
                                    color:
                                        (isDark ? Colors.white : Colors.black)
                                            .withValues(alpha: 0.4),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'NO PAN STORED',
                                    style: GoogleFonts.inter(
                                      fontSize: 9,
                                      letterSpacing: 1.5,
                                      color:
                                          (isDark ? Colors.white : Colors.black)
                                              .withValues(alpha: 0.4),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: (isDark ? Colors.white : Colors.black)
                                      .withValues(alpha: 0.1),
                                  border: Border.all(
                                    color:
                                        (isDark ? Colors.white : Colors.black)
                                            .withValues(alpha: 0.2),
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  card.cardType.name.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    fontStyle: FontStyle.italic,
                                    color: isDark ? Colors.white : Colors.black,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'SINCE 2023',
                                style: GoogleFonts.inter(
                                  fontSize: 8,
                                  color: (isDark ? Colors.white : Colors.black)
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isHighConfidence)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.accentGold.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getAnnualFee(String nickname) {
    if (nickname.contains('Platinum')) return 695;
    if (nickname.contains('Gold')) return 250;
    if (nickname.contains('Venture')) return 95;
    return 0;
  }

  LinearGradient _getGradient(Color cardColor, String bankName) {
    if (bankName == 'Chase') {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [cardColor, const Color(0xFF0a2e6e)],
      );
    } else if (bankName == 'American Express') {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [cardColor, const Color(0xFFb8932d)],
      );
    } else if (bankName == 'Apple Card') {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFf5f5f7), Color(0xFFd2d2d7)],
      );
    }
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [cardColor, Colors.black.withValues(alpha: 0.2)],
    );
  }

  Widget _buildAddCardFAB() {
    return Positioned(
      bottom: 100,
      right: 24,
      child: GestureDetector(
        onTap: () {
          // Navigate to Catalog screen to add cards
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CardCatalogScreen()),
          ).then((_) {
            // Refresh on return
            context.read<CardProvider>().loadCards();
          });
        },
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 0,
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  Widget _buildSecurityDisclaimer() {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                size: 10,
                color: Colors.grey.withValues(alpha: 0.3),
              ),
              const SizedBox(width: 6),
              Text(
                'BANK-GRADE ENCRYPTION',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  letterSpacing: 2,
                  color: Colors.grey.withValues(alpha: 0.3),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'PerkMax never stores your full card number, CVV, or expiration date. All metadata is stored locally and encrypted.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 8,
                color: Colors.grey.withValues(alpha: 0.3),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
