import 'package:shared_preferences/shared_preferences.dart';
import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'weddingPage.dart';
import 'eventData.dart';
import 'main.dart';

TextEditingController _createEventController = TextEditingController();
DateTime selectedDate = DateTime.now();
String eventNameText, eventName;
List<EventData> eventData = [];
List<int> eventDataIDs = [];
MediaQueryData deviceInfo;

Future<void> _saveWeddigns() async {
  final prefs = await SharedPreferences.getInstance();

  for (int i = 0; i < eventData.length; i++) {
    prefs.setString(
        eventData[i].eventNumber.toString(), jsonEncode(eventData[i].toMap()));
  }

  prefs.setInt("numberOfEvents", eventData.length);

  prefs.setString("eventDataIDs", eventDataIDs.toString());
}

void _readEvents() async {
  final prefs = await SharedPreferences.getInstance();

  int loopLength = prefs.getInt("numberOfEvents") ?? 0;

  String eventDataIDsString = prefs.getString("eventDataIDs");

  if (eventDataIDsString != null && eventDataIDsString != "[]") {
    eventDataIDs = [];

    var map = json.decode(eventDataIDsString);

    for (int i = 0; i < map.length; i++) eventDataIDs.add(map[i]);

    if (eventData.length < loopLength) {
      for (int i = 0; i < loopLength; i++) {
        String jsonCurrentEventDataToRead =
            prefs.getString(eventDataIDs[i].toString()) ?? null;

        if (jsonCurrentEventDataToRead != null) {
          Map<String, dynamic> currentEventDataToRead =
              jsonDecode(jsonCurrentEventDataToRead);
          EventData currentEventData =
              EventData.fromMap(currentEventDataToRead);

          eventData.add(currentEventData);
        }
      }
    }
  }
}

void _addToList(String eventName) {
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

  eventDataIDs.add(eventNumber);
}

Future<void> delateWedding(int index) async {
  final prefs = await SharedPreferences.getInstance();

  for (int i = 0; i < eventData[index].subEvents.length; i++) {
    await eventData[index].removeSubEventByIndex(i);
  }

  await prefs.remove(
      "subEventIDs${eventData[index].eventName}${eventData[index].eventNumber}");

  eventDataIDs.remove(eventData[index].eventNumber);

  prefs.remove(
      "numberOfEvents${eventData[index].eventName}${eventData[index].eventNumber}");

  prefs.remove(eventData[index].eventNumber.toString());

  prefs.setInt(
      "numberOfEvents",
      (prefs.getInt("numberOfEvents") - 1 > 0)
          ? prefs.getInt("numberOfEvents") - 1
          : 0);

  prefs.setString("eventDataIDs", eventDataIDs.toString());

  eventData.removeAt(index);
}

class MaterialHome extends StatefulWidget {
  @override
  _MaterialHomeState createState() => _MaterialHomeState();
}

class _MaterialHomeState extends State<MaterialHome> {
  double posx, posy;

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
              child: Text("Cancel"),
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
              child: Text("Create"),
              onPressed: () {
                setState(() {
                  eventName = eventNameText;
                });

                _createEventController.clear();

                Navigator.pop(context);

                setState(() {
                  _addToList(eventName);
                });
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

  Future<bool> delateAlort(BuildContext context, int index) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Delete Wedding?"),
          content: Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(
                "The Wedding \"${eventData[index].eventName}\" will be removed from your account and would require a rescan of the QR code."),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context, false);
              },
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () {
                Navigator.pop(context, true);
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
          ],
        );
      },
    );
  }

  void onTapDown(BuildContext context, TapDownDetails details) {
    final RenderBox box = context.findRenderObject();
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    setState(() {
      posx = localOffset.dx;
      posy = localOffset.dy;
    });
  }

  Color generateListTileColor() {
    if (weddingAppTheme.themeMode == 0)
      return Colors.white;
    else if (weddingAppTheme.themeMode == 1)
      return Colors.grey[850];
    else
      return (deviceInfo.platformBrightness == Brightness.dark)
          ? Colors.grey[850]
          : Colors.white;
  }

  @override
  void initState() {
    _readEvents();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      deviceInfo = MediaQuery.of(context);
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.settings,
          ),
          onPressed: () {
            Navigator.pushNamed(context, 'settings');
          },
        ),
        centerTitle: true,
        title: Text("Weddings"),
      ),
      body: GestureDetector(
        onTapDown: (details) => onTapDown(context, details),
        child: Scrollbar(
          child: ListView.builder(
            itemCount: eventData.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onLongPress: () {
                  showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(posx, posy, posx, posy),
                    items: <PopupMenuEntry>[
                      PopupMenuItem(
                        value: 0,
                        child: Text("Delete"),
                      ),
                    ],
                  ).then(
                    (value) async {
                      if (value == 0) {
                        bool shouldDelate = await delateAlort(context, index);

                        if (shouldDelate != null && shouldDelate) {
                          setState(() {
                            delateWedding(index);
                          });
                        }
                      }
                    },
                  );
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(15, 7.5, 15, 7.5),
                  child: OpenContainer(
                    closedBuilder: (context, animation) {
                      return ListTile(
                        title: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(eventData[index].eventName),
                          ],
                        ),
                        subtitle: Text(eventData[index].nextEventDateTime()),
                        tileColor: generateListTileColor(),
                      );
                    },
                    openBuilder: (context, animation) {
                      return MaterialWeddingPage(
                        currentEventDataToSave: eventData[index],
                      );
                    },
                    closedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await createEvent(context);
          await _saveWeddigns();
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
