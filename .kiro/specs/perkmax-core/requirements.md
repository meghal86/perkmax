# Requirements Document

## Introduction

PerkMax is an advisory-first mobile co-pilot that delivers instant, single-card recommendations for which credit card to use at merchants. The system provides lock-screen guidance using deterministic recommendations computed from a structured, versioned rules database (Truth_Layer). PerkMax eliminates decision paralysis and reduces choice time from ~60 seconds to ~6 seconds.

PerkMax is designed to be:
- Zero-keypad at the moment of purchase
- Manual-wallet first (no bank linking required)
- Confidence-honest (never claiming HIGH certainty when underlying data is uncertain)

## Glossary

- **PerkMax**: The mobile application and backend services providing card recommendations
- **Truth_Layer**: Versioned, structured rewards rules database that prevents hallucinations
- **Merchant_Resolver**: GPS + POI-based system for identifying merchant locations
- **Recommendation_Engine**: Deterministic engine that selects a single winning card using Truth_Layer rules
- **Autopilot**: Location-based system that triggers recommendations + lock-screen delivery
- **AI_Copilot**: Planning assistant for strategy questions (MUST NOT choose the winning card)
- **Explainability_Contract**: Structured explanation object describing why a card won + what would change the decision

## Non-Negotiables

- **One Answer Contract**: exactly ONE winning card by default
- **Deterministic Truth**: Recommendation winner is computed ONLY from Truth_Layer rules + user wallet + resolver outputs
- **Confidence Honesty**: Final_Confidence MUST be computed and shown honestly (never inflated)
- **Zero-keypad purchase flow**: no typing required to get "use this card" at the store
- **Speed moat**: recommendation compute must meet performance targets

## Phases (Implementation Scope Boundaries)

**Phase 1 (MVP — ship)**
- Manual wallet (catalog search → add → recommend)
- Merchant resolution with confidence bands
- Deterministic Recommendation Engine (one winner)
- Autopilot lock-screen recommendation + deep link
- Zero-keypad explainability
- Offline fallback (best-by-category)
- CI gates: Truth Layer validation + Golden tests
- MVP release gate + repeat merchant memory

**Phase 2 (Expansion — after MVP proves quality)**
- Provenance hardening: source_url + last_verified_at REQUIRED; freshness enforcement
- Linked mode (transactions/MCC via aggregator) if desired
- Offers/credits tracking automation

**Phase 3 (Optional — only if justified)**
- Travel Mode and lounge orchestration (only if it does not dilute core "which card now")

## Confidence Model (Non-Negotiable)

- **Merchant_Confidence**: 0–100 certainty of merchant identity
- **Rules_Confidence**: 0–100 certainty/completeness of applicable reward rules
- **Decision_Confidence**: 0–100 determinism of decision (penalize fallbacks/assumptions/ties)
- **Final_Confidence** (shown to user): Final_Confidence = MIN(Merchant_Confidence, Rules_Confidence, Decision_Confidence)

## Confidence Labels

- **HIGH**: Final_Confidence ≥ 80
- **MED**: 50–79
- **LOW**: < 50

## Requirements

### Requirement 1: Truth Layer Data Foundation (Deterministic Truth) — Phase 1

**User Story:** As a user, I want accurate credit card reward information so PerkMax never "invents" answers.

#### Acceptance Criteria

1. THE Truth_Layer SHALL store structured rule records required for all reward calculations
2. THE Recommendation_Engine SHALL use only Truth_Layer data to select the winning card
3. THE Truth_Layer SHALL support at minimum: earn rates by category, merchant exceptions (where known), foreign transaction fee flag, caps fields (modeled Day 1; enforcement can be partial in Phase 1), and channel applicability where known (in-store vs online)
4. THE Truth_Layer SHALL store rule metadata fields in schema from Day 1: effective_from, effective_to (nullable), source_url (nullable in Phase 1; REQUIRED Phase 2+), last_verified_at (nullable Phase 1; REQUIRED Phase 2+), and rule_confidence (0–100, NOT NULL)
5. THE Truth_Layer SHALL maintain an audit log for all rule changes (who/when/before/after/reason)
6. THE Truth_Layer SHALL provide search for card catalog and rule verification
7. THE System SHALL downgrade Rules_Confidence if rule_confidence is low OR critical fields are missing

### Requirement 2: Merchant Resolution with Confidence Bands — Phase 1

**User Story:** As a user, I want PerkMax to automatically identify where I am shopping without manual input.

#### Acceptance Criteria

1. WHEN a user enters a merchant location, THE Merchant_Resolver SHALL attempt identification using GPS + POI data
2. THE Merchant_Resolver SHALL output merchant_id, display_name, category, country/region, Merchant_Confidence (0–100), and reasons[] (gps_match, poi_match, cached_mapping, user_override, etc.)
3. WHEN Merchant_Confidence ≥ 80 (HIGH), THE System SHALL proceed automatically
4. WHEN Merchant_Confidence 50–79 (MED), THE System SHALL show 2–3 candidates for one-tap confirmation (no typing)
5. WHEN Merchant_Confidence < 50 (LOW), THE System SHALL require manual merchant/category selection OR use category fallback
6. THE System SHALL support user overrides for merchant categorization and apply them deterministically on repeat visits
7. THE System SHALL cache confirmed mappings to improve repeat accuracy
8. AFTER one user confirmation, ≥95% of repeat visits to that same POI SHOULD resolve as HIGH confidence (subject to GPS/POI availability)

### Requirement 3: Manual Wallet Management (Privacy-First) — Phase 1

**User Story:** As a user, I want to add cards manually to get personalized recommendations without linking accounts.

#### Acceptance Criteria

1. THE System SHALL allow adding cards via catalog search by issuer/product/network
2. THE System SHALL store only product identity, optional nickname, optional last4
3. THE System SHALL never store PAN or payment credentials
4. THE System SHALL support user preferences: cashback vs points bias, optional point valuation, and optional Protection Mode default
5. THE System SHALL provide data export and deletion
6. THE System SHALL encrypt sensitive data at rest + in transit; use Keychain/Keystore where applicable

### Requirement 4: Deterministic Single-Card Recommendations (One Answer Contract) — Phase 1

**User Story:** As a user, I want exactly one clear card recommendation so I can act quickly.

#### Acceptance Criteria

1. THE Recommendation_Engine SHALL output exactly ONE winning card by default
2. THE Engine SHALL consider only cards in the user's wallet with applicable Truth_Layer rules
3. THE Engine SHALL apply hard exclusions before scoring: invalid merchant exceptions, FX fees abroad when avoidable (if country/region indicates international context), and exhausted caps where cap tracking exists; otherwise downgrade confidence
4. WHEN critical rule data is missing or uncertain, THE Engine SHALL reduce Rules_Confidence and/or Decision_Confidence
5. WHEN Final_Confidence is MED or LOW, THE Engine SHALL NOT claim HIGH certainty and SHALL trigger correct UX behavior (confirm merchant / fallback)
6. THE Engine compute time SHALL be ≤500ms P95 after merchant resolution completes
7. THE Engine SHALL produce Explainability_Contract for every recommendation
8. LLM output SHALL NOT select the winning card (rules-based only)
9. THE Golden Test Suite SHALL exist and run in CI (see REQ-11)

### Requirement 5: Lock Screen Autopilot (Speed + Retention Moat) — Phase 1

**User Story:** As a user, I want recommendations on my lock screen when I arrive at stores, without opening the app.

#### Acceptance Criteria

1. WHEN user enters a POI geofence, THE System SHALL resolve merchant + compute recommendation + enqueue notification within 500ms P95 (compute + enqueue, excluding OS delivery timing)
2. THE System SHALL record timestamps for latency auditing: geofence_entered_at, merchant_resolved_at, recommendation_ready_at, notification_enqueued_at
3. THE lock-screen payload SHALL display merchant name, recommended card, reward rate OR simple reward rationale (e.g., "Best for Grocery"), and confidence label (HIGH/MED/LOW)
4. WHEN user taps notification, THE System SHALL deep-link to explanation drawer
5. THE Autopilot SHALL implement fatigue controls: max prompts per day, quiet hours, place muting, and suppression window for duplicates
6. THE Autopilot SHALL NOT notify again at same merchant unless at least one is true: winner card changes, Final_Confidence increases meaningfully, or high-value exception (cap reached/reset, new offer, protection-driven event)
7. THE Autopilot SHALL respect location permissions and degrade gracefully if limited/denied

### Requirement 6: Zero-Keypad Explainability (Trust Without Friction) — Phase 1

**User Story:** As a user, I want to understand why a card was recommended without typing anything.

#### Acceptance Criteria

1. THE System SHALL show a short default explanation (1–2 lines), expandable for details
2. THE explanation SHALL include winning reason, reward rate OR rationale, confidence label + top reasons, and "what would change" (1–3 bullets)
3. THE System SHALL never require typing for amount in the core purchase flow
4. WHEN amount could change the winner, THE System SHALL offer one-tap amount chips (Under $50 / $50–$200 / $200–$1k / $1k+) OR "Big purchase?" toggle OR optional voice input
5. THE System SHALL only ask for amount when it could change the winner due to offer thresholds, protection thresholds, or cap windows

### Requirement 7: AI Copilot Planning Assistant (Grounded) — Phase 1

**User Story:** As a user, I want to ask strategic questions to optimize planned spending.

#### Acceptance Criteria

1. THE AI_Copilot SHALL answer planning questions (e.g., Apple Store in-store vs online; $10k next year)
2. THE AI_Copilot SHALL ground responses in user wallet, Truth_Layer rules, and structured outputs from Merchant_Resolver + Recommendation_Engine
3. THE AI_Copilot SHALL output one recommendation/strategy, reasoning, assumptions, and next steps
4. THE AI_Copilot SHALL ask max 1–2 clarifying questions when needed
5. THE AI_Copilot SHALL be advisory-only (no guarantees; no overspending encouragement)
6. THE AI_Copilot SHALL NOT choose the winning card directly; MUST consume Recommendation_Engine outputs for selection

### Requirement 8: Offline Functionality and Degradation

**User Story:** As a user, I want the app to work even when I don't have internet connectivity, so that I can still get card recommendations in any situation.

#### Acceptance Criteria

1. WHEN offline, THE System SHALL return best-by-category recommendations from cached rules
2. WHEN POI lookup fails, THE System SHALL use cached merchant data or manual search
3. THE System SHALL cache wallet data, rules, and recent merchants locally
4. THE System SHALL gracefully degrade functionality while maintaining core recommendation capability
5. THE System SHALL sync updated data when connectivity is restored

### Requirement 9: Privacy and Security

**User Story:** As a user, I want my financial and location data to be secure and private, so that I can use the app without privacy concerns.

#### Acceptance Criteria

1. THE System SHALL log only privacy-safe events without PAN or detailed location data
2. THE System SHALL provide minimal location data retention with user consent
3. THE System SHALL encrypt all sensitive data using platform security standards
4. THE System SHALL support complete data export and deletion
5. THE System SHALL require explicit user consent for location permissions and data usage

### Requirement 10: Performance and Reliability (Measured Outcomes)

**User Story:** As a user, I want fast, reliable recommendations at the moment of purchase.

#### Acceptance Criteria

1. THE Recommendation_Engine SHALL compute recommendations within 500ms P95 after merchant resolution completes
2. ≥95% of repeat visits to a confirmed merchant SHALL resolve as HIGH Merchant_Confidence (≥80), subject to GPS/POI availability
3. THE System SHALL achieve near-zero false HIGH Final_Confidence by enforcing Final_Confidence = MIN(Merchant_Confidence, Rules_Confidence, Decision_Confidence)
4. THE System SHALL handle merchant resolution failures gracefully with fallback options (confirm merchant, manual search, best-by-category)
5. THE System SHALL provide observable logging for debugging and performance monitoring without compromising privacy

### Requirement 11: Truth Layer Audit + Rule Validation (CI/CD Gate) — Phase 1

**User Story:** As a product owner/developer, I want rule changes regression-tested so PerkMax never ships broken recommendations.

#### Acceptance Criteria

1. ON any rule add/change, THE System SHALL validate required fields: card_id, category, earn_rate, channel flags, fx_fee_flag, caps fields valid if cap exists, and merchant_exception structure valid if present
2. THE rule_confidence SHALL be NOT NULL for every rule
3. THE effective_from <= effective_to SHALL be enforced when dates exist
4. THE audit log SHALL store who/when/before_json/after_json/reason for every mutation
5. THE CI SHALL run a Golden Test Suite: ≥50 high-frequency merchant/category pairs, includes edge cases (FX, caps, exceptions), and asserts expected winner == engine output
6. WHEN Golden tests fail, THE CI/CD SHALL block deployment and print failing cases
7. WHEN a rule update changes a historical winner, THE System SHALL flag it as breaking and require product-owner approval

### Requirement 12: Confidence Model Enforcement (No False HIGH) — Phase 1

**User Story:** As a user, I want HIGH confidence only when it's justified.

#### Acceptance Criteria

1. THE Final_Confidence SHALL equal MIN(Merchant_Confidence, Rules_Confidence, Decision_Confidence)
2. THE Rules_Confidence SHALL downgrade when: rule_confidence < 70, required fields missing/null, invalid effective dates, or last_verified_at too old (Phase 2+ enforcement)
3. THE Decision_Confidence SHALL downgrade when: fallback used (best-by-category), tie-break used (two cards within threshold like 5%), any hard exclusion applied (FX fee, cap exhausted, exception), or amount unknown AND amount could flip winner
4. THE HIGH label is allowed only if: Final_Confidence ≥ 80, no fallback, no tie-break, Merchant_Confidence ≥ 80, and Rules_Confidence ≥ 80
5. THE System SHALL never inflate confidence upward
6. THE tests SHALL enforce invariants: Final equals MIN, fallback => Decision_Confidence <= 60, tie-break => Decision_Confidence <= 70, and stale/unverified rules => Rules_Confidence downgraded (Phase 2+)

### Requirement 13: Phase 1 MVP Release Gate (Non-Negotiable) — Phase 1

**User Story:** As a product owner, I want clear release criteria so Phase 1 ships with proven core functionality.

#### Acceptance Criteria

**Release is APPROVED only if ALL pass:**

**Functional Gates:**
1. Manual wallet works end-to-end
2. One Answer Contract enforced
3. Merchant confidence bands work
4. Autopilot triggers + deep link works
5. Explainability drawer works (concise default + expand)
6. AI Copilot is grounded (does not pick winner)
7. Offline fallback works

**Quality Gates:**
1. P95 compute <= 500ms after merchant resolved (load test >=1000 iterations)
2. Repeat merchants >=95% HIGH confidence after one confirmation
3. False HIGH confidence: 0 instances in Golden tests
4. Golden Test Suite >=50 passes
5. Privacy audit passes: no PAN stored/logged; location minimized; encryption enabled
6. Observability reconstructs: geofence → merchant → recommendation → notification

**IF any gate fails: RELEASE IS BLOCKED**

### Requirement 14: Repeat Merchant Memory (Daily Stickiness) — Phase 1

**User Story:** As a user, I want PerkMax to become effortless at my frequent stores after the first confirmation.

#### Acceptance Criteria

1. AFTER user confirms merchant once, THE System SHALL store durable mapping: user_id + poi_id -> merchant_id + optional category_override
2. ON repeat visits, THE resolver SHALL prioritize mapping and target HIGH >=80
3. THE Autopilot SHALL suppress repeat notifications unless: winner changes, confidence increases meaningfully, relevant offer/credit becomes active (Phase 2+), or cap state flips (reached/reset)
4. THE System SHALL record the reason a repeat notification fired (winner_changed, cap_reset, etc.)

## Implementation Notes (Clarifiers, Not Requirements)

- "≤500ms" refers to compute + enqueue after merchant resolution; OS delivery varies
- Confidence honesty is the core product promise: degrade to MED/LOW rather than show false certainty
- Zero-keypad is strict for in-store use; planning flows (AI Copilot) may ask optional questions, max 1–2