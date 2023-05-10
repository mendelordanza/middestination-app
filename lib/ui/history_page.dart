import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midjourney_app/data/http_repo.dart';
import 'package:midjourney_app/data/local_db.dart';

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
    final localDb = ref.read(localStorageProvider);
    final http = ref.read(httpProvider);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black87,
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Text("Only successful image generations will show here"),
            Expanded(
              child: FutureBuilder(
                  future: localDb.readAllHistories(),
                  builder: (context, snapshot) {
                    print("SNAPSHOT: ${snapshot.data}");
                    if (snapshot.hasData) {
                      return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final item = snapshot.data![index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (item.url != null)
                                    Stack(
                                      alignment:
                                          AlignmentDirectional.bottomStart,
                                      children: [
                                        Image.network(item.url ?? ""),
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              color: Colors.black26
                                                  .withOpacity(0.5),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
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
                                              name: DateTime.now()
                                                  .toIso8601String(),
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
                    }
                    return Container();
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
