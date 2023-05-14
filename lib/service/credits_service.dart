import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midjourney_app/helper/constant.dart';

import '../helper/shared_prefs.dart';

final creditsCheckerProvider =
    StateNotifierProvider<CreditsCheckerNotifier, int>(
        (ref) => CreditsCheckerNotifier(ref));

class CreditsCheckerNotifier extends StateNotifier<int> {
  CreditsCheckerNotifier(this.ref) : super(0) {
    init();
  }

  final Ref ref;

  init() {
    state = ref.read(sharedPrefsProvider).getFreeCreditsCount() ??
        initialFreeCredits;
  }

  decrement() async {
    if (state == 0) {
      return;
    }
    var currentCount = state - 1;
    ref.read(sharedPrefsProvider).setFreeCreditsCount(currentCount);
    state = currentCount;
  }
}
