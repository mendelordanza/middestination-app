import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlatformProgressIndicator extends StatelessWidget {
  Color? color = Colors.white;

  PlatformProgressIndicator({this.color});

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return CircularProgressIndicator();
    } else {
      return CupertinoActivityIndicator(
        color: color,
      );
    }
  }
}
