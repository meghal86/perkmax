import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import '../database/daos/cards_dao.dart';
import '../database/daos/user_wallet_dao.dart';
import '../services/recommendation_engine.dart';
import '../services/recommendation_result.dart';
import '../services/background_sync_manager.dart';

class DebugServiceScreen extends StatefulWidget {
  const DebugServiceScreen({super.key});

  @override
  State<DebugServiceScreen> createState() => _DebugServiceScreenState();
}

class _DebugServiceScreenState extends State<DebugServiceScreen> {
  String _selectedCategory = 'dining';
  final TextEditingController _amountController = TextEditingController(
    text: '5000',
  );
  RecommendationResult? _result;
  List<Map<String, dynamic>> _allCards = [];
  Set<String> _walletCardIds = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final cards = await context.read<CardsDao>().getAllCards();
    final walletCards = await context.read<UserWalletDao>().getUserCards();

    if (mounted) {
      setState(() {
        _allCards = cards;
        _walletCardIds = walletCards.map((c) => c['id'] as String).toSet();
      });
    }
  }

  Future<void> _addToWallet(String cardId) async {
    await context.read<UserWalletDao>().addToWallet(cardId, null);
    _loadData(); // Refresh list
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Card added to wallet')));
  }

  Future<void> _getRecommendation() async {
    final double amount = double.tryParse(_amountController.text) ?? 0.0;

    // Check wallet first
    if (_walletCardIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wallet is empty! Add cards to wallet first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await context
        .read<RecommendationEngine>()
        .recommendForCategory(category: _selectedCategory, amount: amount);

    setState(() {
      _result = result;
    });

    if (result == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No recommendation found.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Services')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. Database Verification'),
            Text(
              'Total Cards: ${_allCards.length} | In Wallet: ${_walletCardIds.length}',
            ),
            if (_allCards.isNotEmpty)
              Container(
                height: 200, // Increased height
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: ListView.builder(
                  itemCount: _allCards.length,
                  itemBuilder: (context, index) {
                    final card = _allCards[index];
                    final cardId = card['id'] as String;
                    final isInWallet = _walletCardIds.contains(cardId);

                    return ListTile(
                      title: Text(card['product_name'] ?? 'Unknown'),
                      subtitle: Text(card['issuer'] ?? 'Unknown'),
                      dense: true,
                      trailing: isInWallet
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => _addToWallet(cardId),
                            ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),
            _buildSectionTitle('2. Recommendation Engine'),
            Row(
              children: [
                DropdownButton<String>(
                  value: _selectedCategory,
                  items:
                      ['dining', 'travel', 'groceries', 'gas', 'online_grocery']
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount (cents)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _getRecommendation,
              child: const Text('Get Recommendation'),
            ),
            if (_result != null)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        'Winner: ${_result!.cardName}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Confidence: ${_result!.confidenceBand}'),
                      Text(_result!.explanation),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),
            _buildSectionTitle('3. Background Sync'),
            ElevatedButton(
              onPressed: () {
                // Manually trigger the task (Android/iOS behavior varies, mostly for checking no crashes)
                // In a real app, we might call the service directly to test logic
                BackgroundSyncManager.registerPeriodicTask();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Re-registered periodic task')),
                );
              },
              child: const Text('Register Background Task'),
            ),
            const Text(
              'To test execution, use: \n adb shell cmd jobscheduler run -f <package_name> <taskId>',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
