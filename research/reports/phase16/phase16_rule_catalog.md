# Phase 16 Rule Catalog

The following rule matchers execute within `GhanaianEnglishEnhancer` in sequential order:

### 1. `CurrencyMatcher`
- **Pattern**: `\b(\d+(?:\.\d+)?)\s+(?:ghana\s+)?cedis\b`
- **Output**: `GH₵$1`
- **Constraint**: Only matches if preceded by a numeric value to prevent false positives when users speak about the currency conceptually without amounts.

### 2. `InstitutionMatcher`
- **Pattern**: `\b{escaped_token}\b`
- **Source Dictionaries**: `institutions`, `places`, `expressions`.
- **Constraint**: Exact boundary match required.

### 3. `PhoneNumberMatcher`
- **Pattern**: Native 10-digit streams matching common MSISDN prefixes (024, 055, etc.).
- **Constraint**: Evaluated passively. If raw digits are present without spacing, they are preserved as-is. Pre-existing number normalization logic resolves spoken numbers into digit streams before this stage.
