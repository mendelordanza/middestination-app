import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config_reader.dart';
import 'helper/route.dart';
import 'helper/route_strings.dart';
import 'helper/shared_prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ConfigReader.initialize();

  await SharedPrefs.init();

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Color(0xFF3F3F3F),
            textStyle: const TextStyle(
              fontSize: 16.0,
              fontFamily: 'HKGrotesk',
              fontWeight: FontWeight.w700,
            ),
            padding: EdgeInsets.symmetric(vertical: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            minimumSize: Size(double.infinity, 50.0),
          ),
        ),
      ),
      onGenerateRoute: RouteGenerator.generateRoute,
      initialRoute: RouteStrings.landing,
    );
  }
}
