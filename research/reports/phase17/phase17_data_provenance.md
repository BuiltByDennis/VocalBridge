# Phase 17 Data Provenance

All datasets and models evaluated in Phase 17 have their provenance and licensing verified against their official source repositories.

## Datasets
| Dataset | Language | License Status | Commercial Use | Source |
| --- | --- | --- | --- | --- |
| Mozilla Common Voice | Dagbani, Twi (minor) | LICENSE_CONFIRMED (CC0) | COMMERCIAL_USE_ALLOWED | Mozilla Foundation |
| FLEURS | Akan, Ewe | LICENSE_CONFIRMED (CC-BY 4.0) | COMMERCIAL_USE_ALLOWED | Google Research |
| UGAkan | Akan | LICENSE_UNKNOWN | COMMERCIAL_USE_RESTRICTED | Academic (Requires Review) |

## Models
| Model Family | License Status | Commercial Use | Android Offline Feasible |
| --- | --- | --- | --- |
| Sherpa-ONNX (Engine) | LICENSE_CONFIRMED (Apache 2.0) | COMMERCIAL_USE_ALLOWED | Yes |
| Whisper (Tiny/Base) | LICENSE_CONFIRMED (MIT) | COMMERCIAL_USE_ALLOWED | Yes (But no Twi support) |
| Meta MMS | LICENSE_CONFIRMED (CC-BY-NC 4.0) | COMMERCIAL_USE_RESTRICTED | No (Too heavy) |
| Seamless M4T | LICENSE_CONFIRMED (CC-BY-NC 4.0) | COMMERCIAL_USE_RESTRICTED | No (Too heavy) |

*Recommendation: No models evaluated in this phase may be legally and technically bundled into Kasa Me production without either breaking the offline constraint (MMS) or violating commercial licenses (MMS/UGAkan).*
