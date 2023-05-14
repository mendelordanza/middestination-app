import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midjourney_app/data/local_db.dart';
import 'package:midjourney_app/model/pending.dart';

import '../data/http_repo.dart';
import '../model/history.dart';

final completeImagesProvider =
    StateNotifierProvider<CompleteImagesNotifier, AsyncValue<List<History>>>(
        (ref) => CompleteImagesNotifier(ref));

class CompleteImagesNotifier extends StateNotifier<AsyncValue<List<History>>> {
  CompleteImagesNotifier(this.ref) : super(AsyncLoading()) {
    init();
  }

  final Ref ref;

  init() async {
    final list = await ref.read(localStorageProvider).readAllHistories();
    state = AsyncData(list);
  }

  saveToComplete({
    String? messageId,
    String? content,
    String? url,
  }) async {
    final localDb = ref.read(localStorageProvider);
    if (messageId != null && content != null) {
      final regex = RegExp(r'\*\*(.*?)\*\*');
      final match = regex.firstMatch(content);
      localDb
          .create(
        History(
          messageId: messageId,
          content: match?.group(1) ?? content,
          url: url,
          createdAt: DateTime.now().toIso8601String(),
        ),
      )
          .then((value) {
        final currentList = state.value;
        currentList!.insert(0, value);
        state = AsyncData(currentList);
      });
    }
  }
}
