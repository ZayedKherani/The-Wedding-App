import 'package:flutter/material.dart';

import 'eventData.dart';

class EventHome extends StatefulWidget {
  EventHome({
    Key key,
    this.currentWeddingEventData,
  }) : super(key: key);

  final WeddingEvent currentWeddingEventData;
  @override
  _EventHomeState createState() => _EventHomeState();
}

class _EventHomeState extends State<EventHome> {
  double _screenWidth, _screenHeight;

  @override
  Widget build(BuildContext context) {
    setState(() {
      _screenWidth = MediaQuery.of(context).size.width;
      _screenHeight = MediaQuery.of(context).size.height;
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.currentWeddingEventData.eventName),
      ),
      body: Center(
        child: Text("${_screenWidth}x$_screenHeight"),
      ),
    );
  }
}
