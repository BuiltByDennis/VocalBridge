import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ug_hci_lab/ug_hci_lab_config.dart';

/// Whether a connectivity report means "the internet is reachable
/// enough to try": any live interface counts — Wi-Fi, mobile data,
/// ethernet. `none` (or an empty report) means offline.
bool isOnlineConnectivity(List<ConnectivityResult> results) =>
    results.any((r) => r != ConnectivityResult.none);

/// The provider the speech engines should be built with RIGHT NOW.
///
/// Khaya AI is the app's online mode. When Khaya is the selected
/// provider and a key is configured but the network is gone, the
/// engines fall back to OFFLINE automatically — English keeps working
/// on-device instead of every request failing — and they return to
/// Khaya on their own when the network comes back.
///
/// Khaya only: the UG HCI Lab selection and an explicit Offline
/// selection are never overridden by the network state.
SpeechProvider effectiveSpeechProvider({
  required SpeechProvider selected,
  required bool khayaConfigured,
  required bool online,
}) {
  if (selected == SpeechProvider.khaya && khayaConfigured && !online) {
    return SpeechProvider.offline;
  }
  return selected;
}

/// Live network state: `true` while any connection is available.
/// Emits the current state on listen, then every change.
final networkOnlineProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  yield isOnlineConnectivity(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(isOnlineConnectivity);
});
