import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/credit_card.dart';
import '../providers/card_provider.dart';
import '../app/theme.dart';

class CardCatalogScreen extends StatefulWidget {
  const CardCatalogScreen({super.key});

  @override
  State<CardCatalogScreen> createState() => _CardCatalogScreenState();
}

class _CardCatalogScreenState extends State<CardCatalogScreen> {
  List<CreditCard> _allCards = [];
  List<CreditCard> _filteredCards = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCards();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCards = _allCards.where((card) {
        return card.cardNickname.toLowerCase().contains(query) ||
            card.issuer.toLowerCase().contains(
              query,
            ); // Issuer is roughly in color/name logic
      }).toList();
    });
  }

  Future<void> _loadCards() async {
    final provider = context.read<CardProvider>();
    final cards = await provider.getAvailableCards();

    // Sort slightly by nickname
    cards.sort((a, b) => a.cardNickname.compareTo(b.cardNickname));

    if (mounted) {
      setState(() {
        _allCards = cards;
        _filteredCards = cards;
        _isLoading = false;
      });
    }
  }

  Future<void> _addCard(CreditCard card) async {
    final provider = context.read<CardProvider>();
    // Check if already in wallet
    final alreadyAdded = provider.cards.any((c) => c.id == card.id);

    if (alreadyAdded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${card.cardNickname} is already in your wallet'),
        ),
      );
      return;
    }

    await provider.addCardToWallet(card.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${card.cardNickname} to wallet')),
    );
    Navigator.pop(context); // Optional: close after adding
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
    if (nickname.contains('Citi')) return 'Citi';
    return 'Bank';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CardProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Add Card',
          style: GoogleFonts.playfairDisplay(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search cards...',
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredCards.length,
                    itemBuilder: (context, index) {
                      final card = _filteredCards[index];
                      final isAdded = provider.cards.any(
                        (c) => c.id == card.id,
                      );
                      final cardColor = _parseColor(card.cardColor);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Container(
                            width: 50,
                            height: 32,
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          title: Text(
                            card.cardNickname,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            _getBankName(card.cardNickname),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          trailing: isAdded
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              : IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  color: AppTheme.primaryGreen,
                                  onPressed: () => _addCard(card),
                                ),
                          onTap: isAdded ? null : () => _addCard(card),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
