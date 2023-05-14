import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:midjourney_app/helper/route_strings.dart';
import 'package:midjourney_app/ui/history_page.dart';
import 'package:midjourney_app/ui/home_page.dart';

class RouteGenerator {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case RouteStrings.landing:
        return _navigate(builder: (_) => HomePage());
      case RouteStrings.history:
        return _navigate(builder: (_) => HistoryPage());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic>? _navigate({required WidgetBuilder builder}) {
    if (Platform.isAndroid) {
      return MaterialPageRoute(builder: builder);
    } else {
      return CupertinoPageRoute(builder: builder);
    }
  }

  static Route<dynamic>? _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text("Navigation Error"),
        ),
        body: Center(
          child: Text("Something went wrong."),
        ),
      ),
    );
  }
}
