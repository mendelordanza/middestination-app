import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midjourney_app/data/http_repo.dart';
import 'package:midjourney_app/data/local_db.dart';
import 'package:midjourney_app/service/complete_service.dart';
import 'package:midjourney_app/service/pending_service.dart';
import 'package:midjourney_app/ui/common/platform_progress_indicator.dart';

import '../model/history.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black87,
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          bottom: const TabBar(
            tabs: [
              Tab(
                text: "Pending",
              ),
              Tab(text: "Complete"),
            ],
            indicatorColor: Colors.black,
            labelColor: Colors.black87,
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              PendingPage(),
              CompletePage(),
            ],
          ),
        ),
      ),
    );
  }
}

class PendingPage extends ConsumerStatefulWidget {
  const PendingPage({Key? key}) : super(key: key);

  @override
  ConsumerState<PendingPage> createState() => _PendingPageState();
}

class _PendingPageState extends ConsumerState<PendingPage> {
  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // saveToDb(
  //   String? messageId,
  //   String? content,
  //   String? url,
  // ) {
  //   final localDb = ref.read(localStorageProvider);
  //   if (messageId != null && content != null) {
  //     final regex = RegExp(r'\*\*(.*?)\*\*');
  //     final match = regex.firstMatch(content);
  //     print("TITLE: ${match?.group(1)}");
  //     localDb.create(History(
  //       messageId: messageId,
  //       content: match?.group(1) ?? content,
  //       url: url,
  //       createdAt: DateTime.now().toIso8601String(),
  //     ));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final localDb = ref.read(localStorageProvider);
    final http = ref.read(httpProvider);

    return Consumer(builder: (context, ref, _) {
      return ref.watch(pendingImagesProvider).when(data: (value) {
        if (value.isNotEmpty) {
          return ListView.builder(
            itemCount: value.length,
            itemBuilder: (context, index) {
              final item = value[index];
              return GestureDetector(
                onTap: () {
                  print(item.prevMessageId);
                  http.getPendingMessage(
                      content: item.content,
                      limit: 5,
                      after: item.prevMessageId,
                      onSuccess: (messageData) {
                        if (messageData.attachments != null &&
                            messageData.attachments!.isNotEmpty &&
                            messageData.attachments![0].url.contains(".png")) {
                          if (item.id != null) {
                            ref
                                .read(pendingImagesProvider.notifier)
                                .deletePending(item.id!);
                          }
                          ref
                              .read(completeImagesProvider.notifier)
                              .saveToComplete(
                                messageId: messageData.id,
                                url: messageData.attachments![0].url,
                                content: messageData.content,
                              );
                          showSnackBar(
                              "Congrats! You can now check the image in complete tab");
                        } else {
                          showSnackBar("Still processing. Come back later!");
                        }
                      },
                      onError: (errorMessage) {});
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Prompt: ${item.content}",
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                              color: Colors.amber,
                            ),
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Click here to check status",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          return Center(child: Text("Add your prompt to generate an image!"));
        }
      }, error: (error, stacktrace) {
        return Center(child: Text("Something went wrong."));
      }, loading: () {
        return PlatformProgressIndicator();
      });
    });
  }
}

class CompletePage extends ConsumerStatefulWidget {
  const CompletePage({Key? key}) : super(key: key);

  @override
  ConsumerState<CompletePage> createState() => _CompletePageState();
}

class _CompletePageState extends ConsumerState<CompletePage> {
  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localDb = ref.read(localStorageProvider);
    final http = ref.read(httpProvider);

    return Consumer(builder: (context, ref, _) {
      return ref.watch(completeImagesProvider).when(data: (value) {
        if (value.isNotEmpty) {
          return ListView.builder(
              itemCount: value.length,
              itemBuilder: (context, index) {
                final item = value[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (item.url != null)
                        Stack(
                          alignment: AlignmentDirectional.bottomStart,
                          children: [
                            Image.network(item.url ?? ""),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Colors.black26.withOpacity(0.5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    item.content,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (item.url != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                http.downloadFile(
                                  url: item.url!,
                                  name: DateTime.now().toIso8601String(),
                                  callback: (message) {
                                    showSnackBar(message);
                                  },
                                );
                              },
                              icon: Icon(Icons.save_alt),
                            ),
                            Text("Save Image")
                          ],
                        ),
                    ],
                  ),
                );
              });
        } else {
          return Center(
            child: Text("Successful image generations will show here"),
          );
        }
      }, error: (error, stacktrace) {
        return Center(child: Text("Something went wrong."));
      }, loading: () {
        return PlatformProgressIndicator();
      });
    });
  }
}
