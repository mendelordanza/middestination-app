import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midjourney_app/data/local_db.dart';
import 'package:midjourney_app/model/pending.dart';

import '../data/http_repo.dart';

final pendingImagesProvider =
    StateNotifierProvider<PendingImagesNotifier, AsyncValue<List<Pending>>>(
        (ref) => PendingImagesNotifier(ref));

class PendingImagesNotifier extends StateNotifier<AsyncValue<List<Pending>>> {
  PendingImagesNotifier(this.ref) : super(AsyncLoading()) {
    init();
  }

  final Ref ref;

  init() async {
    final list = await ref.read(localStorageProvider).readAllPending();
    state = AsyncData(list);
  }

  saveToPending({
    String? messageId,
    required String content,
    String? url,
  }) async {
    final localDb = ref.read(localStorageProvider);
    final http = ref.read(httpProvider);
    final regex = RegExp(r'\*\*(.*?)\*\*');
    final match = regex.firstMatch(content);
    localDb.checkIfExistsPending(content).then(
      (value) {
        if (!value) {
          http.getLatestMessage(
            limit: 1,
            onSuccess: (message) {
              localDb
                  .createPending(Pending(
                messageId: messageId,
                content: match?.group(1) ?? content,
                url: url,
                prevMessageId: message.id ?? "",
                createdAt: DateTime.now().toIso8601String(),
              ))
                  .then((value) {
                final currentList = state.value;
                currentList!.add(value);
                state = AsyncData(currentList);
              });
            },
            onError: (message) {
              print(message);
            },
          );
        }
      },
    );
    final list = await ref.read(localStorageProvider).readAllPending();
    state = AsyncData(list);
  }

  deletePending(int id) async {
    final localDb = ref.read(localStorageProvider);
    localDb.deletePending(id);
    final list = await ref.read(localStorageProvider).readAllPending();
    state = AsyncData(list);
  }
}
