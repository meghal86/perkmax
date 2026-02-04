import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../providers/card_provider.dart';
import '../models/credit_card.dart';
import '../services/recommendation_service.dart';

class RecommendScreen extends StatefulWidget {
  const RecommendScreen({super.key});

  @override
  State<RecommendScreen> createState() => _RecommendScreenState();
}

class _RecommendScreenState extends State<RecommendScreen> {
  final RecommendationService _recommendationService = RecommendationService();
  RewardCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategorySection(context),
                    const SizedBox(height: 24),
                    if (_selectedCategory != null)
                      _buildRecommendations(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Card Recommendations',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Select a category to find the best card',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vendor Categories',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: RewardCategory.values.map((category) {
            return _buildCategoryItem(context, category);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(BuildContext context, RewardCategory category) {
    final isSelected = _selectedCategory == category;
    final categoryName =
        category.name[0].toUpperCase() + category.name.substring(1);

    IconData icon;
    List<Color> gradient;
    switch (category) {
      case RewardCategory.dining:
        icon = Icons.restaurant;
        gradient = [const Color(0xFFFF6B6B), const Color(0xFFFF8E8E)];
        break;
      case RewardCategory.travel:
        icon = Icons.flight;
        gradient = [const Color(0xFF4FACFE), const Color(0xFF00F2FE)];
        break;
      case RewardCategory.gas:
        icon = Icons.local_gas_station;
        gradient = [const Color(0xFFFFA726), const Color(0xFFFFCC02)];
        break;
      case RewardCategory.groceries:
        icon = Icons.shopping_cart;
        gradient = [const Color(0xFF43E97B), const Color(0xFF38F9D7)];
        break;
      case RewardCategory.streaming:
        icon = Icons.play_circle_filled;
        gradient = [const Color(0xFF667EEA), const Color(0xFF764BA2)];
        break;
      case RewardCategory.online:
        icon = Icons.shopping_bag;
        gradient = [const Color(0xFFF093FB), const Color(0xFFF5576C)];
        break;
      case RewardCategory.utilities:
        icon = Icons.bolt;
        gradient = [const Color(0xFF00D9FF), const Color(0xFF00A3CC)];
        break;
      case RewardCategory.general:
        icon = Icons.credit_card;
        gradient = [const Color(0xFFD4AF37), const Color(0xFFFFD700)];
        break;
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(colors: gradient) : null,
          color: isSelected ? null : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gradient.first.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white60,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              categoryName,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context) {
    return Consumer<CardProvider>(
      builder: (context, provider, _) {
        if (provider.cards.isEmpty) {
          return _buildEmptyState(context);
        }

        final recommendations = _recommendationService.getRecommendations(
          cards: provider.cards,
          category: _selectedCategory!,
        );

        final categoryName =
            _selectedCategory!.name[0].toUpperCase() +
            _selectedCategory!.name.substring(1);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.recommend, color: AppTheme.primaryGold),
                const SizedBox(width: 8),
                Text(
                  'Best Cards for $categoryName',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recommendations.asMap().entries.map((entry) {
              final index = entry.key;
              final rec = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildRecommendationCard(context, rec, index),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: AppTheme.glassDecoration,
      child: Column(
        children: [
          Icon(
            Icons.credit_card_off,
            size: 48,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Cards Added',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your credit cards to get personalized recommendations',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    CardRecommendation rec,
    int index,
  ) {
    String medal;
    switch (index) {
      case 0:
        medal = '🥇';
        break;
      case 1:
        medal = '🥈';
        break;
      case 2:
        medal = '🥉';
        break;
      default:
        medal = '${index + 1}';
    }

    final colorIndex = rec.card.cardColor.isNotEmpty
        ? int.tryParse(rec.card.cardColor) ?? 0
        : 0;
    final gradientColor =
        AppTheme.cardGradients[colorIndex % AppTheme.cardGradients.length];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: index == 0
            ? Border.all(
                color: AppTheme.primaryGold.withValues(alpha: 0.5),
                width: 2,
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [gradientColor, gradientColor.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(medal, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec.card.cardNickname,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rec.reason,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: index == 0 ? AppTheme.primaryGold : AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${rec.cashbackRate.toStringAsFixed(1)}%',
              style: TextStyle(
                color: index == 0 ? AppTheme.darkBackground : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
