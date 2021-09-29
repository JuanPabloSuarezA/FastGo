import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpText extends StatefulWidget {
  TextEditingController con1;
  TextEditingController con2;
  TextEditingController con3;
  TextEditingController con4;
  TextEditingController con5;
  TextEditingController con6;

  OtpText({
    Key key,
    this.con1,
    this.con2,
    this.con3,
    this.con4,
    this.con5,
    this.con6,
  }) : super(key: key);

  @override
  _OtpTextState createState() => _OtpTextState();
}

class _OtpTextState extends State<OtpText> {
  FocusNode con1Fn;
  FocusNode con2Fn;
  FocusNode con3Fn;
  FocusNode con4Fn;
  FocusNode con5Fn;
  FocusNode con6Fn;
  TextInputType number = TextInputType.number;
  TextInputType noNumber = TextInputType.text;

  @override
  void initState() {
    super.initState();
    con1Fn = FocusNode();
    con2Fn = FocusNode();
    con3Fn = FocusNode();
    con4Fn = FocusNode();
    con5Fn = FocusNode();
    con6Fn = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    con1Fn?.dispose();
    con2Fn?.dispose();
    con3Fn?.dispose();
    con4Fn?.dispose();
    con5Fn?.dispose();
    con6Fn?.dispose();
  }

  void nextField(String value, FocusNode focusNode) {
    if (value.length == 1) {
      focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _createBox(widget.con1, con1Fn, false, con2Fn, noNumber),
              _createBox(widget.con2, con2Fn, false, con3Fn, noNumber),
              _createBox(widget.con3, con3Fn, false, con4Fn, noNumber),
              _createBox(widget.con4, con4Fn, false, con5Fn, number),
              _createBox(widget.con5, con5Fn, false, con6Fn, number),
              _createBox(widget.con6, con6Fn, true, con1Fn, number),
            ],
          ),
        ],
      ),
    );
  }

  SizedBox _createBox(
    TextEditingController txtCon,
    FocusNode fn,
    bool lastBox,
    FocusNode fn2,
    TextInputType type,
  ) {
    return SizedBox(
      width: 45,
      height: 45,
      child: TextFormField(
        controller: txtCon,
        focusNode: fn,
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        keyboardType: type,
        textAlign: TextAlign.center,
        onChanged: (value) {
          if (!lastBox) {
            nextField(value, fn2);
          } else if (value.length == 1) {
            fn.unfocus();
          }
        },
      ),
    );
  }
}
