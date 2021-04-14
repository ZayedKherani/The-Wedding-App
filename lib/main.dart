import 'package:shared_preferences/shared_preferences.dart';
import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'weddingPage.dart';
import 'eventData.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'The Wedding App',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _createEventController = TextEditingController();

  String eventNameText, eventName;

  double _screenWidth, _screenHeight;

  DateTime selectedDate = DateTime.now();

  List<EventData> eventData = [];

  void _addToList(String eventName) {
    setState(() {
      int eventNumber;

      if (eventData.isEmpty) {
        eventNumber = 1;
      } else {
        eventNumber = eventData.last.eventNumber + 1;
      }

      EventData currentEventData = EventData(
          eventNumber: eventNumber,
          eventName: eventName,
          eventDateTime: selectedDate);

      eventData.add(currentEventData);
    });
  }

  Future<void> createEvent(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Create A New Event"),
          content: TextField(
            onChanged: (value) {
              setState(() {
                eventNameText = value;
              });
            },
            controller: _createEventController,
            decoration: InputDecoration(
              border: new OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(10.0),
                ),
              ),
              hintText: "Event Name",
            ),
          ),
          actions: [
            TextButton(
              child: Text("  CANCEL  "),
              onPressed: () {
                _createEventController.clear();
                Navigator.pop(context);
              },
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
            ),
            TextButton(
              child: Text("OK"),
              onPressed: () {
                setState(() {
                  eventName = eventNameText;
                });
                _createEventController.clear();
                Navigator.pop(context);
                _addToList(eventName);
              },
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  _readEvents() async {
    final prefs = await SharedPreferences.getInstance();

    int loopLength = prefs.getInt("numberOfEvents") ?? 0;

    for (int i = 0; i < loopLength; i++) {
      String jsonCurrentEventDataToRead = prefs.getString(i.toString()) ?? null;

      if (jsonCurrentEventDataToRead != null) {
        Map<String, dynamic> currentEventDataToRead =
            jsonDecode(jsonCurrentEventDataToRead);
        EventData currentEventData = EventData.fromMap(currentEventDataToRead);

        setState(() {
          eventData.add(currentEventData);
        });
      }
    }
  }

  _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();

    for (int i = 0; i < eventData.length; i++) {
      Map<String, dynamic> currentEventDataToSave = eventData[i].toMap();
      String jsonCurrentEventDataToSave = jsonEncode(currentEventDataToSave);

      prefs.setString(i.toString(), jsonCurrentEventDataToSave);
    }

    prefs.setInt("numberOfEvents", eventData.length);
  }

  @override
  void initState() {
    _readEvents();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _screenWidth = MediaQuery.of(context).size.width;
      _screenHeight = MediaQuery.of(context).size.height;
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Weddings"),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: _screenWidth / 2,
          mainAxisExtent: _screenHeight / 8,
          childAspectRatio: 3 / 2,
        ),
        itemCount: eventData.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.fromLTRB(15, 7.5, 15, 7.5),
            child: OpenContainer(
              closedBuilder: (context, animation) {
                return ListTile(
                  title: Text(eventData[index].eventName),
                );
              },
              openBuilder: (context, animation) {
                return WeddingHome(
                  currentWeddingData: eventData[index],
                );
              },
              closedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(
                  color: Colors.grey,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await createEvent(context);
          await _saveEvents();
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
      // body: WeddingHome(
      //   currentWeddingData: EventData(
      //     eventDateTime: DateTime.now().add(
      //       Duration(days: 5),
      //     ),
      //     eventName: "Cono",
      //     eventNumber: 1,
      //   ),
      // ),
    );
  }
}
