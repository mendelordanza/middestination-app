import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midjourney_app/data/local_db.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localDb = ref.read(localStorageProvider);
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
            Text("Showing last 10 generations"),
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
                            return Column(
                              children: [
                                Text(item.content),
                                Image.network(item.url),
                              ],
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
