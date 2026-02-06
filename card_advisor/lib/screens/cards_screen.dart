import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../providers/card_provider.dart';
import '../models/credit_card.dart';
import 'add_card_screen.dart';

class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildCardsList(context)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddCard(context),
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Card',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Cards',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Consumer<CardProvider>(
                builder: (context, provider, _) => Text(
                  '${provider.cards.length} cards registered',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textDark.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardsList(BuildContext context) {
    return Consumer<CardProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryGreen),
          );
        }

        if (provider.cards.isEmpty) {
          return _buildEmptyState(context);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: provider.cards.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildCardItem(context, provider.cards[index], provider),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.credit_card_off_outlined,
                size: 64,
                color: AppTheme.textDark.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Cards Yet',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add your credit cards to start getting\nsmart recommendations',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppTheme.textDark.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardItem(
    BuildContext context,
    CreditCard card,
    CardProvider provider,
  ) {
    final colorIndex = card.cardColor.isNotEmpty
        ? int.tryParse(card.cardColor) ?? 0
        : 0;
    final cardColor =
        AppTheme.cardGradients[colorIndex % AppTheme.cardGradients.length];

    return Dismissible(
      key: Key(card.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppTheme.error,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 32),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.white,
                title: Text(
                  'Delete Card?',
                  style: GoogleFonts.playfairDisplay(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  'Are you sure you want to remove ${card.cardNickname}?',
                  style: GoogleFonts.inter(),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(color: AppTheme.textDark),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      'Delete',
                      style: GoogleFonts.inter(
                        color: AppTheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (direction) {
        provider.removeCard(card.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${card.cardNickname} removed',
              style: GoogleFonts.inter(),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
            backgroundColor: AppTheme.textDark,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: cardColor.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    card.cardNickname,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildCardTypeIcon(card.cardType),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                '•••• •••• •••• ${card.lastFourDigits}',
                style: GoogleFonts.sourceCodePro(
                  // Monospace for numbers look cool
                  color: Colors.white,
                  fontSize: 22,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CARD HOLDER',
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 10,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card.cardholderName.toUpperCase(),
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'EXPIRES',
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 10,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card.expiryDate,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardTypeIcon(CardType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type.name.toUpperCase(),
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _navigateToAddCard(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddCardScreen()),
    );
  }
}
