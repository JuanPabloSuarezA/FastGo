import 'package:flutter/material.dart';

class MapClient extends StatefulWidget {
  @override
  _MapClientState createState() => _MapClientState();
}

class _MapClientState extends State<MapClient> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Center(
            child: Text("mapa cliente"),
          ),
          ElevatedButton(onPressed: () {}, child: Text("d")),
        ],
      ),
    );
  }
}
