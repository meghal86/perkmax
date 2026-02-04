import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../providers/card_provider.dart';
import '../models/credit_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildQuickStats(context),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildRecentCards(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryGold, Color(0xFFFFD700)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGold.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.credit_card,
            color: AppTheme.darkBackground,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Card Advisor',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Smart card recommendations',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white60),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Consumer<CardProvider>(
      builder: (context, provider, _) {
        final cardCount = provider.cards.length;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.glassDecoration,
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.credit_card,
                  label: 'Total Cards',
                  value: cardCount.toString(),
                  color: AppTheme.accentBlue,
                ),
              ),
              Container(width: 1, height: 60, color: Colors.white24),
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.category,
                  label: 'Categories',
                  value: '8',
                  color: AppTheme.accentPurple,
                ),
              ),
              Container(width: 1, height: 60, color: Colors.white24),
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.trending_up,
                  label: 'Max Cashback',
                  value: _getMaxCashback(provider.cards),
                  color: AppTheme.successGreen,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getMaxCashback(List<CreditCard> cards) {
    if (cards.isEmpty) return '0%';
    double max = 0;
    for (final card in cards) {
      for (final rate in card.rewardRates.values) {
        if (rate > max) max = rate;
      }
    }
    return '${max.toStringAsFixed(0)}%';
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.white60),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.add_card,
                label: 'Add Card',
                gradient: const [Color(0xFF667eea), Color(0xFF764ba2)],
                onTap: () {
                  // Navigate to add card - handled by parent
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.recommend,
                label: 'Get Advice',
                gradient: const [Color(0xFFf093fb), Color(0xFFf5576c)],
                onTap: () {
                  // Navigate to recommendations - handled by parent
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCards(BuildContext context) {
    return Consumer<CardProvider>(
      builder: (context, provider, _) {
        if (provider.cards.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: AppTheme.glassDecoration,
            child: Column(
              children: [
                Icon(
                  Icons.credit_card_off,
                  size: 64,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No cards added yet',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white60),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first card to get started',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white38),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Cards',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...provider.cards
                .take(2)
                .map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildCardPreview(context, card),
                  ),
                ),
          ],
        );
      },
    );
  }

  Widget _buildCardPreview(BuildContext context, CreditCard card) {
    final colorIndex = card.cardColor.isNotEmpty
        ? int.tryParse(card.cardColor) ?? 0
        : 0;
    final gradientColor =
        AppTheme.cardGradients[colorIndex % AppTheme.cardGradients.length];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientColor, gradientColor.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.credit_card, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.cardNickname,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '•••• ${card.lastFourDigits}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            card.cardType.name.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
