import 'package:flutter/material.dart';
import 'package:fast_go/src/utils/colors.dart' as util;

class Snackb {
  static void showSnackb(BuildContext context, String text) {
    if (context == null) return;

    FocusScope.of(context).requestFocus(new FocusNode());
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
      backgroundColor: util.Colors.fgcolor,
      duration: Duration(seconds: 3),
    ));
  }
}
