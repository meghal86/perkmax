import 'dart:math' as math;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:card_advisor/models/merchant.dart';
import 'package:card_advisor/models/merchant_resolution_result.dart';
import 'package:card_advisor/database/daos/merchants_dao.dart';
import 'package:card_advisor/services/gemini_service.dart';
import 'package:card_advisor/services/location_service.dart';

class MerchantService {
  final LocationService _locationService = LocationService();
  final GeminiService _geminiService = GeminiService();
  final MerchantsDao merchantsDao;

  MerchantService({required this.merchantsDao});

  // Search radius in meters
  static const double _searchRadius = 100.0;

  // Distance score coefficient (100 - k * distance)
  static const double _distanceK = 1.0;

  Future<MerchantResolutionResult> resolveCurrentLocation() async {
    try {
      // 1. Get high accuracy location
      final position = await _locationService.getCurrentPosition();
      print(
        "MerchantService: Got position: ${position.latitude}, ${position.longitude}",
      );

      // 2. Fetch candidates from DB
      List<Merchant> candidates = await merchantsDao.getMerchantsInRadius(
        lat: position.latitude,
        lng: position.longitude,
        radiusMeters: _searchRadius,
      );
      print("MerchantService: Found ${candidates.length} candidates in DB");

      if (candidates.isEmpty) {
        print(
          "MerchantService: No candidates found. Attempting reverse geocoding.",
        );

        try {
          print(
            "MerchantService: Calling placemarkFromCoordinates(${position.latitude}, ${position.longitude})",
          );
          List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );
          print(
            "MerchantService: Geocoding returned ${placemarks.length} placemarks",
          );

          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            print("MerchantService: First placemark: $place");
            final name = place.name ?? place.street ?? "Unknown Location";
            final street = place.street ?? "";
            final locality = place.locality ?? "";

            // Construct a temporary merchant for the current location
            // We use 'street_address' as a generic category logic or just pass it through
            return MerchantResolutionResult(
              merchant: Merchant(
                id: 'loc_${position.latitude}_${position.longitude}',
                name:
                    "$name${street.isNotEmpty && name != street ? ', $street' : ''}",
                lat: position.latitude,
                lng: position.longitude,
                mcc: '0000', // Unknown MCC
                category: 'Location',
                distanceMeters: 0,
              ),
              confidenceScore:
                  100, // High confidence in the coordinates/address
              confidenceBand: ConfidenceBand
                  .MEDIUM, // Medium because it's not a verified merchant
              reason: "Resolved address: $street, $locality",
              alternatives: [],
            );
          }
        } catch (e) {
          print("MerchantService: Geocoding error: $e");
          print(
            "MerchantService: Falling back to Gemini for reverse geocoding.",
          );
        }

        // Only try Gemini if we haven't returned yet (which means geocoding failed or was empty)
        try {
          print("MerchantService: Calling Gemini reverseGeocode...");
          final geminiResult = await _geminiService.reverseGeocode(
            lat: position.latitude,
            lng: position.longitude,
          );
          print("MerchantService: Gemini returned: $geminiResult");

          if (geminiResult.isNotEmpty) {
            final name = geminiResult['name'] ?? "Unknown Location";
            final street = geminiResult['street'] ?? "";
            final locality = geminiResult['locality'] ?? "";

            return MerchantResolutionResult(
              merchant: Merchant(
                id: 'loc_${position.latitude}_${position.longitude}',
                name: name,
                lat: position.latitude,
                lng: position.longitude,
                mcc: '0000',
                category: 'Location',
                distanceMeters: 0,
              ),
              confidenceScore: 80,
              confidenceBand: ConfidenceBand.MEDIUM,
              reason: "AI Resolved address: $street ($locality)",
              alternatives: [],
            );
          }
        } catch (e) {
          print("MerchantService: Gemini fallback error: $e");
        }

        // Final fallback
        return MerchantResolutionResult(
          confidenceScore: 0,
          confidenceBand: ConfidenceBand.LOW,
          reason: "No known merchants or address found",
          alternatives: [],
        );
      }

      // 3. Calculate accurate distances
      candidates = candidates.map((m) {
        final dist = _locationService.distanceBetween(
          position.latitude,
          position.longitude,
          m.lat,
          m.lng,
        );
        return m.copyWith(distanceMeters: dist);
      }).toList();

      // Sort by distance
      candidates.sort(
        (a, b) =>
            (a.distanceMeters ?? 9999).compareTo(b.distanceMeters ?? 9999),
      );

      // 4. Calculate Confidence Scores
      // We will look at the top candidate
      final topCandidate = candidates.first;
      final distance = topCandidate.distanceMeters ?? 0;

      final cDistance = math.max(0.0, 100 - (_distanceK * distance));

      // Density penalty: max(0, 100 - (count - 1) * 20)
      // If 2 candidates close by, score drops to 80.
      // If 6 candidates, score drops to 0.
      // We only care about "plausible" candidates for density, say within 50m of the top candidate?
      // For simplicity, let's use all candidates in the search radius.
      final cDensity = math.max(0, 100 - ((candidates.length - 1) * 10));

      // History: For now, assuming neutral (100) if not implemented
      // If we had history, we could boost it.
      // User visit count is on the merchant object.
      double cHistory = 100;
      if (topCandidate.visitCount > 0) {
        // Boost? Or just treat as high confidence cap?
        // Let's say if you visited it, it pushes confidence up.
        // But the formula says min(). logical AND.
        // So history shouldn't drag it down unless we have negative history.
        // Let's keep it 100.
      }

      double finalScore = math.min(cDistance, cDensity.toDouble());
      finalScore = math.min(finalScore, cHistory);

      // 5. Determine Band and if we need AI
      // High confidence: Score >= 80 and clear winner
      bool callAI = false;
      ConfidenceBand band;

      if (finalScore >= 80) {
        band = ConfidenceBand.HIGH;
        // Check if second candidate is too close in score/distance
        if (candidates.length > 1) {
          final second = candidates[1];
          if ((second.distanceMeters ?? 999) - distance < 20) {
            // Second candidate is within 20m of the first
            band = ConfidenceBand.MEDIUM; // Downgrade due to ambiguity
            callAI = true;
          }
        }
      } else if (finalScore >= 50) {
        band = ConfidenceBand.MEDIUM;
        callAI = true;
      } else {
        band = ConfidenceBand.LOW;
        callAI = true;
      }

      // Skip AI if we have no internet or if user disabled it?
      // For now, always call AI if needed and candidates exist.
      if (callAI && candidates.isNotEmpty) {
        return _resolveWithAI(position, candidates);
      }

      return MerchantResolutionResult(
        merchant: topCandidate,
        confidenceScore: finalScore.round(),
        confidenceBand: band,
        reason: "Local resolution: ${distance.toStringAsFixed(1)}m away",
        alternatives: candidates.skip(1).toList(),
      );
    } catch (e) {
      print("MerchantService Error: $e");
      return MerchantResolutionResult(
        confidenceScore: 0,
        confidenceBand: ConfidenceBand.LOW,
        reason: "Error resolving location: $e",
        alternatives: [],
      );
    }
  }

  Future<MerchantResolutionResult> _resolveWithAI(
    Position position,
    List<Merchant> candidates,
  ) async {
    final aiResult = await _geminiService.disambiguateMerchant(
      lat: position.latitude,
      lng: position.longitude,
      accuracy: position.accuracy,
      candidates: candidates,
    );

    final merchantId = aiResult['merchant_id'];
    final score = aiResult['confidence_score'] as int? ?? 0;
    final bandStr = aiResult['confidence_band'] as String? ?? 'LOW';
    final reason = aiResult['reason'] as String? ?? 'AI Decision';

    Merchant? selected;
    if (merchantId != null) {
      selected = candidates.firstWhere(
        (m) => m.id == merchantId,
        orElse: () => candidates.first,
      );
    }

    ConfidenceBand band;
    switch (bandStr) {
      case 'HIGH':
        band = ConfidenceBand.HIGH;
        break;
      case 'MED':
        band = ConfidenceBand.MEDIUM;
        break;
      case 'LOW':
      default:
        band = ConfidenceBand.LOW;
        break;
    }

    return MerchantResolutionResult(
      merchant: selected,
      confidenceScore: score,
      confidenceBand: band,
      reason: "AI: $reason",
      alternatives: candidates.where((m) => m.id != merchantId).toList(),
      usedAI: true,
    );
  }

  // Method to seed data for testing
  Future<void> seedTestMerchants() async {
    // Test data DISABLED.
    // Clean up old test data if it exists.
    print("MerchantService: Cleaning up any test data...");
    await merchantsDao.deleteMerchant('mckinney_coffee');
  }
}
