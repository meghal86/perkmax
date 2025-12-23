# Implementation Plan: PerkMax Core

## Tech Stack
- **Mobile**: React Native (Expo) + TypeScript + SQLCipher (encrypted SQLite)
- **Testing**: Jest + fast-check (property-based) + Golden Test Suite
- **Backend**: Node.js + Express + PostgreSQL (Truth_Layer master + sync only)

## Overview

This implementation plan converts the PerkMax design into discrete coding tasks that build incrementally toward a production-ready mobile application. The approach prioritizes on-device computation, deterministic behavior, and confidence-driven UX flows.

## Requirement Mapping Table

| Req # | Title | Key Acceptance Criteria |
|-------|-------|------------------------|
| 1 | Truth Layer Data Foundation | 1.1-1.7: Structured rules, deterministic engine, audit logging |
| 2 | Merchant Resolution | 2.1-2.8: GPS+POI, confidence bands, user overrides |
| 3 | Manual Wallet Management | 3.1-3.6: Catalog search, no PAN, encryption |
| 4 | Deterministic Recommendations | 4.1-4.9: One answer, hard exclusions, ≤500ms P95 |
| 5 | Lock Screen Autopilot | 5.1-5.7: Geofencing, notifications, fatigue controls |
| 6 | Zero-Keypad Explainability | 6.1-6.5: Short explanations, amount chips only when relevant |
| 7 | AI Copilot Planning | 7.1-7.6: Grounded responses, max 2 questions, advisory only |
| 8 | Offline Functionality | 8.1-8.5: Cached rules, graceful degradation |
| 9 | Privacy and Security | 9.1-9.5: No PAN logging, encryption, consent |
| 10 | Performance and Reliability | 10.1-10.5: 500ms P95, fallback handling |
| 11 | Truth Layer Audit | 11.1-11.7: Rule validation, Golden tests, CI gates |
| 12 | Confidence Model Enforcement | 12.1-12.6: MIN formula, no false HIGH |
| 13 | Phase 1 MVP Release Gate | 13.1-13.6: Functional + quality gates |
| 14 | Repeat Merchant Memory | 14.1-14.4: Durable mappings, notification suppression |

## Tasks

- [ ] 0. Platform feasibility lock and tech decisions
  - **Lock**: Expo Managed vs Expo Prebuild vs Bare workflow decision
  - **Verify**: Background location, dynamic geofencing, local notifications, background task scheduling on iOS/Android
  - **Verify**: SQLCipher support in chosen RN workflow
  - **Output**: "Platform Feasibility Decision" document with chosen libraries and constraints
  - **Acceptance**: All background execution features confirmed working on real devices. If dynamic geofencing cannot be made reliable in Expo Managed, we must switch to Expo Prebuild/Bare and document the exact native modules used.
  - _Requirements: 5.1, 5.7, 9.3_

- [ ] 1. Create shared deterministic engine package (prevents backend drift)
  - Create `packages/engine-core` TypeScript package used by mobile + any backend endpoints
  - Implement scoring algorithm, exclusions logic, tie-break configuration, confidence math
  - **Use integer basis points (e.g., earn_rate_bps) and integer math for thresholds/caps with documented deterministic rounding rules**
  - Add Golden test suite that runs against this package in CI
  - **Acceptance**: Engine package compiles, exports all core functions, Golden tests pass, no floating point math in scoring
  - _Requirements: 1.2, 4.1, 4.8_

- [ ] 1.1 Write property test for Truth Layer data integrity
  - **Property 1: Truth Layer Data Integrity**
  - **Validates: Requirements 1.1, 1.3, 1.4, 11.1, 11.2, 11.3**

- [ ] 2. Set up project structure and core interfaces
  - Create React Native project with chosen workflow from Task 0
  - Define core TypeScript interfaces for Truth Layer, Recommendation Engine, Merchant Resolver
  - Set up property-based testing framework (fast-check) with Jest
  - Configure local SQLite database with SQLCipher encryption
  - **Acceptance**: Project builds, all interfaces compile, test framework runs
  - _Requirements: 1.1, 3.6, 9.3_

- [ ] I1. Identity and sync ownership model
  - **Define**: user_id for MVP as local, device-generated UUID (no login required)
  - **Document**: Optional Phase 2 account login maps many devices → one server user
  - **Conflict rule**: For mappings, "latest confirmed_at wins; never overwrite local with lower-confidence server data"
  - **Acceptance**: Export/delete works using this identity model, multi-device sync strategy documented
  - _Requirements: 3.5, 9.4, 14.1_

## Backend Phase (Truth Layer Master + Signing Pipeline)

- [ ] B1. Build Truth Layer Master database schema
  - Create PostgreSQL schema with tables: cards, rules, rule_versions, audit_log, ruleset_manifests, signed_rulesets, keyring
  - Implement rule validation with all required fields including amount_thresholds, protection_tags
  - Add cap metadata fields (modeled Day 1, enforcement partial in Phase 1)
  - **Acceptance**: All schema migrations run, validation catches missing required fields
  - _Requirements: 1.1, 1.4, 1.5_

- [ ] B2. Admin tools for rule entry and verification
  - Build rule validation UI/CLI with required field checking
  - Implement "breaking change" approval workflow for rule updates that change historical winners
  - Add rule confidence scoring and metadata management
  - **Acceptance**: Admin can add/edit rules, breaking changes require approval, audit trail works
  - _Requirements: 1.6, 11.7_

- [ ] B3. Ruleset build and signing pipeline
  - Implement rule_hash computation (SHA-256) and manifest_hash generation
  - Create delta generation between ruleset versions
  - Add Ed25519 signing for manifest with key rotation support
  - Store last 3 "known good" versions for rollback capability
  - **Acceptance**: Pipeline generates signed deltas, signature verification works, rollback tested
  - _Requirements: 1.4, 1.5_

- [ ] B4. Signing key custody and separation
  - **Store**: Public keys only in Postgres (key_id, public_key, created_at, status)
  - **Signing**: Uses KMS/Keychain/secure enclave or equivalent; private key not exportable
  - **Rotation**: Old keys remain valid for verification for 90 days
  - **Acceptance**: No private signing key material in DB backups; rotation verified end-to-end
  - _Requirements: 9.3_

## Core Implementation Phase

- [ ] 3. Define POI source and local indexing strategy
  - **Define**: POI data source (cached frequent places + user confirmations + optional provider)
  - **Implement**: Local geohash/grid bucket index for candidate POI lookup
  - **Normalize**: Chain vs specific store merchant mapping
  - **Privacy**: If any POI enrichment provider is used, requests must not include user identifiers; location must be coarsened (e.g., geohash precision cap) unless user explicitly opts in
  - **Acceptance**: POI lookup returns candidates within 100ms, chain normalization works, privacy boundary enforced
  - _Requirements: 2.1, 2.2, 9.1_

- [ ] 3.1 Implement Truth Layer local mirror with versioning
  - [ ] 3.1.1 Create RewardRule schema with complete field set
    - Implement RewardRule, TruthLayerMeta, AuditLogEntry interfaces
    - Add rule_version, rule_hash, ruleset_version, amount_thresholds, protection_tags fields
    - Include staleness cap behavior: if sync_status !== 'current' OR last_sync > 7 days → Rules_Confidence ≤ 60
    - **Acceptance**: Schema includes all design fields, staleness caps implemented and tested
    - _Requirements: 1.1, 1.4_

  - [ ] 3.1.2 Implement encrypted SQLite Truth Layer storage
    - Create SQLCipher database with backup exclusion and iOS file protection
    - Implement CRUD operations for reward rules with audit logging
    - Add key rotation implementation with Keychain/Keystore storage
    - **Acceptance**: DB encrypted, backup excluded, audit log captures all changes
    - _Requirements: 1.1, 1.5, 3.6, 9.3_

  - [ ] 3.1.3 Write property test for deterministic recommendation source
    - **Property 2: Deterministic Recommendation Source**
    - **Validates: Requirements 1.2, 4.8**

  - [ ] 3.1.4 Implement rule validation and confidence calculation
    - Create rule validation with required field checks and phase flag enforcement
    - Implement Rules_Confidence calculation with staleness caps and penalties
    - Add phase flags for provenance enforcement (Phase 1 vs Phase 2+)
    - **Acceptance**: Validation catches all missing fields, confidence calculation matches design spec
    - _Requirements: 1.7, 11.1, 11.2, 11.3_

- [ ] 4. Implement Merchant Resolver with deterministic POI mapping
  - [ ] 4.1 Create merchant resolution with confidence bands
    - Implement GPS coordinate to POI mapping using local index
    - Add confidence calculation (HIGH/MED/LOW) with exact thresholds
    - Create user override and confirmation system with durable storage
    - **Acceptance**: Resolution returns exact confidence bands, overrides persist and apply
    - _Requirements: 2.1, 2.2, 2.3, 2.5, 2.6_

  - [ ] 4.2 Implement MED-confidence candidate selection
    - Create deterministic ranking algorithm for POI candidates
    - Limit to maximum 3 candidates with stable sort order
    - Implement no-typing confirmation UX contract
    - **Acceptance**: MED confidence always returns 2-3 candidates in stable order
    - _Requirements: 2.4_

  - [ ] 4.3 Implement repeat merchant memory system
    - Create user-specific POI to merchant mappings with visit counting
    - Implement caching for confirmed merchant resolutions
    - Add logic to prioritize repeat mappings for instant HIGH confidence
    - **Acceptance**: Confirmed merchants resolve as HIGH ≥95% of time on repeat visits
    - _Requirements: 2.7, 2.8, 14.1, 14.2_

  - [ ] 4.4 Write property test for merchant resolution output completeness
    - **Property 6: Merchant Resolution Output Completeness**
    - **Validates: Requirements 2.2**

  - [ ] 4.5 Write property test for confidence-driven UX flow
    - **Property 7: Confidence-Driven UX Flow**
    - **Validates: Requirements 2.3, 2.4, 2.5, 4.5**

- [ ] 5. Checkpoint 1 - Truth Layer and Merchant Resolver validation
  - **Acceptance**: CI green, all properties 1-2, 6-7 have passing tests, no TODO stubs, on-device smoke test passes

- [ ] 6. Implement on-device Recommendation Engine using shared package
  - [ ] 6.1 Create deterministic card scoring algorithm
    - Use shared engine package for scoring logic
    - Implement card filtering (wallet cards with applicable rules only)
    - Add hard exclusion logic (FX fees, caps, merchant exceptions) with zero tolerance
    - **Acceptance**: Scoring matches shared package, exclusions never allow excluded cards to win
    - _Requirements: 4.1, 4.2, 4.3_

  - [ ] 6.2 Implement exact confidence calculation formulas
    - Create Final_Confidence = MIN(Merchant, Rules, Decision) with no inflation
    - Implement Decision_Confidence with exact fallback (≤60) and tie-break (≤70) penalties
    - Add confidence label assignment with exact thresholds (HIGH≥80, MED 50-79, LOW<50)
    - **Acceptance**: Confidence calculation matches design spec exactly, no false HIGH possible
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5_

  - [ ] 6.3 Write property test for one answer contract
    - **Property 3: One Answer Contract**
    - **Validates: Requirements 4.1**

  - [ ] 6.4 Write property test for confidence calculation integrity
    - **Property 4: Confidence Calculation Integrity**
    - **For any** recommendation, Final_Confidence must equal MIN(Merchant_Confidence, Rules_Confidence, Decision_Confidence), and HIGH confidence (≥80) must only be assigned when all component confidences are ≥80 and no fallbacks or tie-breaks were used. HIGH implies: usedFallback=false, usedTieBreak=false, and all component confidences ≥80.
    - **Validates: Requirements 12.1, 12.2, 12.3, 12.4, 12.5**

  - [ ] 6.5 Implement explainability contract generation
    - Create explanation with winning reason, confidence breakdown, "what would change"
    - Add short default format with expandable details
    - Implement amount relevance detection (only when thresholds/caps could flip winner)
    - **Acceptance**: All explanations include required fields, amount requests only when decision-relevant
    - _Requirements: 4.7, 6.1, 6.2, 6.4, 6.5_

  - [ ] 6.6 Write property test for hard exclusion enforcement
    - **Property 5: Hard Exclusion Enforcement**
    - **Validates: Requirements 4.3**

- [ ] 7. Implement user wallet management with privacy protection
  - [ ] 7.1 Create manual wallet with catalog search
    - Implement card addition via issuer/product/network search
    - Store only product identity, nickname, optional last4 (never PAN)
    - Add user preferences (cashback vs points, protection mode, notification limits)
    - **Acceptance**: No PAN ever stored, catalog search works, preferences persist
    - _Requirements: 3.1, 3.2, 3.4_

  - [ ] 7.2 Implement data privacy and security measures
    - Add PAN validation that prevents any storage of payment credentials
    - Implement complete data export (all user data) and secure deletion
    - Add encryption for sensitive data using platform Keychain/Keystore
    - **Acceptance**: PAN detection blocks storage, export includes all data, deletion verified complete
    - _Requirements: 3.2, 3.3, 3.5, 3.6, 9.1, 9.3_

  - [ ] 7.3 Write property test for user data privacy protection
    - **Property 8: User Data Privacy Protection**
    - **Validates: Requirements 3.2, 3.3, 9.1, 9.3**

  - [ ] 7.4 Write property test for wallet card filtering
    - **Property 9: Wallet Card Filtering**
    - **Validates: Requirements 4.2**

## UI Phase (User Experience Screens)

- [ ] U1. Implement onboarding and permissions flows
  - **Request**: "When In Use" location permission during onboarding with clear explanation
  - **Request**: "Always" location permission only when user toggles "Autopilot" ON (with clear benefit + settings deep link fallback)
  - Add notification permission setup with benefit explanation
  - Implement graceful degradation messaging for denied permissions
  - **Acceptance**: Autopilot cannot be enabled without Always; app remains usable without it; permissions flow works on real devices
  - _Requirements: 5.7, 9.2, 9.5_

- [ ] U2. Implement merchant confirmation UX (MED confidence)
  - Create 2-3 candidate selection sheet with no typing required
  - Add one-tap confirmation with merchant override option
  - Implement deterministic candidate ordering and display
  - **Acceptance**: MED confidence always shows exactly 2-3 options, no keyboard appears
  - _Requirements: 2.4_

- [ ] U3. Implement manual fallback UX (LOW confidence)
  - Create manual merchant/category picker for LOW confidence scenarios
  - Add best-by-category fallback option with clear explanation
  - **Implement search functionality behind optional tap; default manual flow uses chips/recent merchants without typing**
  - **Acceptance**: LOW confidence provides clear fallback options, search optional and doesn't break zero-keypad core flow
  - _Requirements: 2.5_

- [ ] U4. Implement lock-screen deep link to explanation drawer
  - Create explanation drawer with short default + expandable details
  - Add deep link handling from lock-screen notifications
  - Implement amount input (chips/toggle) only when decision-relevant
  - **Acceptance**: Deep links work from lock screen, amount input appears only when needed
  - _Requirements: 5.4, 6.1, 6.2, 6.3, 6.4, 6.5_

- [ ] U5. Implement autopilot settings (fatigue controls)
  - Create quiet hours, daily limits, and place muting settings
  - Add notification suppression controls with clear explanations
  - Implement settings persistence and real-time application
  - **Acceptance**: All fatigue controls work as configured, settings persist
  - _Requirements: 5.5, 5.6_

- [ ] 8. Implement location-based autopilot system
  - [ ] 8.1 Create location manager with feasible geofencing strategy
    - Implement dynamic geofencing within iOS (20) and Android (100) limits
    - Add significant location change detection with visit events
    - Create fallback mechanisms for permission limitations and battery optimization
    - **Acceptance**: Geofencing works on real devices within OS limits, fallbacks tested
    - _Requirements: 5.1, 5.7, 9.2, 9.5_

  - [ ] 8.2 Implement notification system with fatigue controls
    - Create local notification controller for lock-screen delivery
    - Implement notification decision engine with state machine and suppression logic
    - Add fatigue controls (daily limits, quiet hours, suppression windows) with durable state
    - **Acceptance**: Notifications respect all fatigue controls, state persists across app restarts
    - _Requirements: 5.3, 5.4, 5.5, 5.6, 14.3_

  - [ ] 8.3 Write property test for notification content completeness
    - **Property 15: Notification Content Completeness**
    - **Validates: Requirements 5.3**

  - [ ] 8.4 Write property test for fatigue control enforcement
    - **Property 16: Fatigue Control Enforcement**
    - **Validates: Requirements 5.5, 5.6, 14.3**

- [ ] 9. Checkpoint 2 - Core recommendation flow end-to-end validation
  - **Acceptance**: CI green, all properties 3-5, 8-9, 15-16 have passing tests, no TODO stubs, full user flow works on real device

- [ ] 10. Implement AI Copilot with structured orchestration
  - [ ] 10.1 Create copilot with grounded response pipeline
    - Implement LLM query parsing to structured scenarios
    - Create engine-first orchestration (no direct card selection allowed)
    - Add response validation ensuring all card mentions come from engine outputs
    - **Acceptance**: Copilot never selects cards directly, all recommendations traced to engine
    - _Requirements: 7.1, 7.2, 7.6_

  - [ ] 10.2 Implement copilot response formatting and constraints
    - Create structured response format with reasoning, assumptions, next steps
    - Add clarifying question limits (maximum 2) with enforcement
    - Implement advisory-only language validation (no guarantees, no overspending encouragement)
    - **Acceptance**: Responses always include required fields, never exceed 2 questions, advisory tone
    - _Requirements: 7.3, 7.4, 7.5_

  - [ ] 10.3 Write property test for AI Copilot grounding and constraints
    - **Property 12: AI Copilot Grounding and Constraints**
    - **Validates: Requirements 7.1, 7.2, 7.3, 7.4, 7.5, 7.6**

- [ ] 11. Implement offline functionality and sync protocol
  - [ ] 11.1 Create offline fallback mechanisms
    - Implement best-by-category recommendations using local mirror only
    - Add graceful degradation for POI lookup failures with cached data
    - Create local caching strategy for wallet, rules, merchant data with TTL management
    - **Acceptance**: Offline mode provides recommendations, graceful degradation works, cache TTL respected
    - _Requirements: 8.1, 8.2, 8.3, 8.4_

  - [ ] 11.2 Implement delta-based sync with cryptographic verification
    - Create ruleset signature verification using Ed25519 with public key pinning
    - Implement two-phase apply strategy (download→verify→swap) with atomic transactions
    - Add sync protocol with delta updates, version management, and rollback capability
    - **Acceptance**: Sync only applies verified updates, rollback works, failed verification keeps previous ruleset
    - _Requirements: 1.4, 1.5_

  - [ ] 11.3 Write property test for offline functionality preservation
    - **Property 17: Offline Functionality Preservation**
    - **Validates: Requirements 8.1, 8.2, 8.3, 8.4**

- [ ] 12. Implement zero-keypad explainability system
  - [ ] 12.1 Create explanation interface with conditional amount handling
    - Implement zero-keypad explanation display with short default + expandable details
    - Add conditional amount input (chips/toggle/voice) only when decision-relevant
    - Create explanation completeness validation ensuring all required fields present
    - **Acceptance**: Core flow never requires typing, amount input only when winner could change
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

  - [ ] 12.2 Write property test for explanation completeness
    - **Property 10: Explanation Completeness**
    - **Validates: Requirements 6.1, 6.2, 4.7**

  - [ ] 12.3 Write property test for zero-keypad core flow
    - **Property 11: Zero-Keypad Core Flow**
    - **Validates: Requirements 6.3, 6.4, 6.5**

## Security and Observability Phase

- [ ] SEC0. Threat model and trust boundaries
  - **Threats**: Tampered ruleset, MITM attacks, device compromise, malicious POI poisoning, log leakage
  - **Controls**: Map each threat to specific tasks (signing, pinning, backup exclusion, forbidden data scanner)
  - **Document**: Trust boundaries between mobile app, backend, and external services
  - **Acceptance**: Threat model document exists, top 10 threats have documented mitigations
  - _Requirements: 9.1, 9.3_

- [ ] AS1. App Store compliance and privacy disclosures
  - **iOS**: NSLocationAlwaysAndWhenInUseUsageDescription, background modes, notifications permission copy
  - **Privacy**: Data collection declarations, ensure "no tracking" compliance if applicable
  - **Android**: Permission rationale and foreground service notes if used
  - **Acceptance**: App Store review checklist passes, no blocked permissions, privacy manifest complete
  - _Requirements: 5.7, 9.2, 9.5_

- [ ] S3. Forbidden data scanner and log redaction guard
  - **Build**: Unit test + runtime guard that blocks PAN-like patterns (13–19 digits with Luhn check), precise lat/long pairs, "CVV", "expiry", etc.
  - **Redact**: Any accidental matches in logs before emit
  - **Acceptance**: CI fails on forbidden patterns in logs/DB writes; runtime guard active in prod builds
  - _Requirements: 3.3, 9.1_

- [ ] S1. Implement local DB security hardening
  - Add backup exclusion for encrypted database
  - Implement iOS file protection class and Android equivalent
  - Add device compromise detection signals (optional but recommended)
  - **Acceptance**: DB excluded from backups, file protection active, compromise detection works
  - _Requirements: 9.3_

- [ ] S2. Implement key rotation and public key pinning
  - Create key rotation implementation for Ed25519 signing keys
  - Add public key pinning for ruleset verification with rotation support
  - Implement secure key storage and validation
  - **Acceptance**: Key rotation works without breaking verification, pinning prevents MITM
  - _Requirements: 9.3_

- [ ] 13. Implement observability and performance monitoring
  - [ ] 13.1 Create privacy-safe logging and telemetry
    - Implement performance span tracking for 500ms P95 measurement with exact timer boundaries
    - Add privacy-safe event logging without PAN or precise location coordinates
    - Create timestamp recording (geofence_entered_at, merchant_resolved_at, recommendation_ready_at, notification_enqueued_at)
    - **Acceptance**: All spans tracked, no sensitive data in logs, timestamps captured for latency analysis
    - _Requirements: 5.2, 9.1, 10.5_

  - [ ] 13.2 Build performance harness for on-device testing
    - Create harness that runs on JS runtime (Hermes) and real devices (iPhone + Android)
    - Generate 1000 randomized scenarios with varied wallet configurations
    - Measure merchant_resolved_at → recommendation_ready_at with P50/P95/P99 reporting
    - **Acceptance**: Harness runs on real devices, fails if P95 > 500ms, reports accurate percentiles
    - _Requirements: 4.6, 10.1_

  - [ ] 13.3 Implement data export and deletion system
    - Create complete user data export functionality (wallet, preferences, mappings, logs)
    - Implement secure data deletion with verification and audit trail
    - Add location permission respect and consent management with graceful degradation
    - **Acceptance**: Export includes all user data, deletion verified complete, consent properly managed
    - _Requirements: 3.5, 9.4, 9.2, 9.5_

  - [ ] 13.4 Write property test for timestamp recording for observability
    - **Property 20: Timestamp Recording for Observability**
    - **Validates: Requirements 5.2, 10.5**

  - [ ] 13.5 Write property test for data export and deletion completeness
    - **Property 18: Data Export and Deletion Completeness**
    - **Validates: Requirements 3.5, 9.4**

- [ ] 14. Implement audit trail and rule validation system
  - [ ] 14.1 Create comprehensive audit logging
    - Implement audit trail for all Truth Layer changes with complete metadata
    - Add rule change impact detection and approval workflow for breaking changes
    - Create audit log completeness validation ensuring all required fields captured
    - **Acceptance**: All rule changes logged, breaking changes require approval, audit complete
    - _Requirements: 1.5, 11.4, 11.7_

  - [ ] 14.2 Write property test for audit trail completeness
    - **Property 13: Audit Trail Completeness**
    - **Validates: Requirements 1.5, 11.4**

  - [ ] 14.3 Write property test for user override persistence and application
    - **Property 14: User Override Persistence and Application**
    - **Validates: Requirements 2.6, 14.1, 14.2**

## Final Integration and Release Validation

- [ ] 15. Implement Golden Test Suite for CI/CD
  - [ ] 15.1 Create curated Golden Test Suite
    - Build 50+ high-frequency merchant/category test cases with expected winners
    - Add edge cases (international merchants, cap scenarios, merchant exceptions)
    - Implement CI integration that blocks deployment on Golden test failures
    - **Acceptance**: Golden tests cover major scenarios, CI blocks on failures, expected winners documented
    - _Requirements: 4.9, 11.5, 11.6_

  - [ ] 15.2 Run comprehensive performance validation
    - Execute 1000-iteration performance tests using performance harness
    - Validate 500ms P95 requirement with real device testing
    - Implement latency measurement and monitoring with alerting
    - **Acceptance**: P95 ≤ 500ms validated on real devices, monitoring active, alerts configured
    - _Requirements: 4.6, 10.1_

  - [ ] 15.3 Write property test for location permission respect
    - **Property 19: Location Permission Respect**
    - **Validates: Requirements 5.7, 9.2, 9.5**

  - [ ] 15.4 Write property test for engine determinism
    - **Property 21: Engine Determinism**
    - **For any** identical input (wallet + merchant + preferences), the engine must return identical output including tie-breaks
    - **Validates: Requirements 4.1, 12.5**

  - [ ] 15.5 Write property test for ruleset signature enforcement
    - **Property 22: Ruleset Signature Enforcement**
    - **For any** ruleset update with invalid signature, the system must never apply the update and must retain previous ruleset
    - **Validates: Requirements 1.4, 1.5**

- [ ] 16. Final checkpoint - Release gate validation
  - **Functional Gates**: Manual wallet works end-to-end, One Answer Contract enforced, Merchant confidence bands work, Autopilot triggers + deep link works, Explainability drawer works, AI Copilot grounded, Offline fallback works
  - **Quality Gates**: P95 ≤ 500ms (1000+ iterations), Repeat merchants ≥95% HIGH confidence, Zero false HIGH confidence in Golden tests, Golden Test Suite ≥50 passes, Privacy audit passes (no PAN stored/logged), Observability complete (geofence → recommendation → notification)
  - **Acceptance**: ALL functional and quality gates pass, release approved for App Store submission
  - _Requirements: 13.1-13.6_

## Notes

- All tasks are required for comprehensive implementation from the start
- Each task includes specific acceptance criteria to prevent incomplete implementation
- Checkpoints have hard acceptance criteria (no "ask user if questions arise")
- Property tests validate universal correctness properties using fast-check (100+ iterations)
- **22 total property tests** including engine determinism and signature enforcement
- Performance validation must pass on real devices, not just simulators
- Implementation uses shared engine package to prevent backend drift
- **Integer math only** for all financial calculations (basis points, no floats)
- Local-first architecture ensures sub-100ms performance and offline capability
- All sensitive data encrypted with platform security standards (Keychain/Keystore)
- **Identity model**: Local UUID for MVP, multi-device sync strategy documented for Phase 2