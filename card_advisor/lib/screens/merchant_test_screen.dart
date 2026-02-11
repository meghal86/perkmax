import 'package:flutter/material.dart';
import 'package:card_advisor/models/merchant_resolution_result.dart';
import 'package:card_advisor/services/merchant_service.dart';

class MerchantTestScreen extends StatefulWidget {
  const MerchantTestScreen({super.key});

  @override
  State<MerchantTestScreen> createState() => _MerchantTestScreenState();
}

class _MerchantTestScreenState extends State<MerchantTestScreen> {
  final MerchantService _merchantService = MerchantService();
  bool _isLoading = false;
  String _status = '';
  MerchantResolutionResult? _result;

  Future<void> _seedData() async {
    setState(() {
      _isLoading = true;
      _status = 'Seeding test data...';
    });
    try {
      await _merchantService.seedTestMerchants();
      setState(() {
        _status = 'Data seeded successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Error seeding data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resolveLocation() async {
    setState(() {
      _isLoading = true;
      _status = 'Resolving location...';
      _result = null;
    });
    try {
      final result = await _merchantService.resolveCurrentLocation();
      setState(() {
        _result = result;
        _status = 'Resolution complete';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Merchant Resolution Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _seedData,
              child: const Text('Seed Test Data (SF Union Square)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _resolveLocation,
              child: const Text('Resolve Current Location'),
            ),
            const SizedBox(height: 24),
            Text('Status: $_status'),
            const Divider(),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_result != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_buildResultCard(_result!)],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(MerchantResolutionResult result) {
    Color bandColor;
    switch (result.confidenceBand) {
      case ConfidenceBand.HIGH:
        bandColor = Colors.green;
        break;
      case ConfidenceBand.MEDIUM:
        bandColor = Colors.orange;
        break;
      case ConfidenceBand.LOW:
        bandColor = Colors.red;
        break;
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Confidence: ${result.confidenceBand.name}',
                  style: TextStyle(
                    color: bandColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                Text('Score: ${result.confidenceScore}'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Selected Merchant: ${result.merchant?.name ?? "None"}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (result.merchant != null)
              Text(
                'Distance: ${result.merchant?.distanceMeters?.toStringAsFixed(1)}m',
              ),
            const SizedBox(height: 8),
            Text('Reason: ${result.reason}'),
            const SizedBox(height: 8),
            if (result.usedAI)
              const Chip(
                label: Text('Resolved by Gemini AI'),
                backgroundColor: Colors.purple,
                labelStyle: TextStyle(color: Colors.white),
              ),

            const SizedBox(height: 16),
            const Text(
              'Alternatives:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...result.alternatives
                .map(
                  (m) => ListTile(
                    title: Text(m.name),
                    subtitle: Text(
                      '${m.distanceMeters?.toStringAsFixed(1)}m - ${m.category}',
                    ),
                    dense: true,
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }
}
