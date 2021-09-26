import 'package:flutter/material.dart';
import 'package:fast_go/src/utils/colors.dart' as util;

class ButtonApp extends StatelessWidget {
  String text;
  Color color;
  Color textColor;
  IconData icon;
  Function onPressed;

  ButtonApp(
      {this.color = util.Colors.fgcolor,
      @required this.text,
      this.textColor = Colors.black,
      this.icon = Icons.arrow_forward_ios,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          onPressed();
        },
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 40,
                alignment: Alignment.center,
                child: Text(
                  text,
                  style: TextStyle(color: textColor, fontSize: 16),
                ),
              ),
            ),
            Align(
              child: Container(
                height: 40,
                child: CircleAvatar(
                  child: Icon(
                    icon,
                    color: util.Colors.fgcolor,
                  ),
                  backgroundColor: Colors.white,
                  radius: 15,
                ),
              ),
              alignment: Alignment.centerRight,
            )
          ],
        ),
        style: ElevatedButton.styleFrom(
          primary: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ));
  }
}
