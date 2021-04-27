import 'package:shared_preferences/shared_preferences.dart';
import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'weddingPage.dart';
import 'eventData.dart';

TextEditingController _createEventController = TextEditingController();
DateTime selectedDate = DateTime.now();
String eventNameText, eventName;
List<EventData> eventData = [];
List<int> eventDataIds = [];
MediaQueryData deviceInfo;

Future<void> _saveEvents() async {
  final prefs = await SharedPreferences.getInstance();

  for (int i = 0; i < eventData.length; i++) {
    prefs.setString(
        eventData[i].eventNumber.toString(), jsonEncode(eventData[i].toMap()));
  }

  prefs.setInt("numberOfEvents", eventData.length);

  prefs.setString("eventDataIDs", eventDataIds.toString());
}

void _readEvents() async {
  final prefs = await SharedPreferences.getInstance();

  int loopLength = prefs.getInt("numberOfEvents") ?? 0;

  String eventDataIdsString = prefs.getString("eventDataIDs");

  if (eventDataIdsString != null && eventDataIdsString != "[]") {
    eventDataIds = [];

    var map = json.decode(eventDataIdsString);

    for (int i = 0; i < map.length; i++) eventDataIds.add(map[i]);

    if (eventData.length < loopLength) {
      for (int i = 0; i < loopLength; i++) {
        String jsonCurrentEventDataToRead =
            prefs.getString(eventDataIds[i].toString()) ?? null;

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

  eventDataIds.add(eventNumber);
}

Future<void> deleteWedding(int index) async {
  final prefs = await SharedPreferences.getInstance();

  for (int i = 0; i < eventData[index].subEvents.length; i++) {
    eventData[index].removeSubEventByIndex(i);
  }

  eventDataIds.remove(eventData[index].eventNumber);

  prefs.remove(
      "numberOfEvents${eventData[index].eventName}${eventData[index].eventNumber}");

  prefs.remove(eventData[index].eventNumber.toString());

  prefs.setInt(
      "numberOfEvents",
      (prefs.getInt("numberOfEvents") - 1 > 0)
          ? prefs.getInt("numberOfEvents") - 1
          : 0);

  prefs.setString("eventDataIDs", eventDataIds.toString());

  eventData.removeAt(index);
}

class CupertinoHome extends StatefulWidget {
  @override
  _CupertinoHomeState createState() => _CupertinoHomeState();
}

class _CupertinoHomeState extends State<CupertinoHome> {
  Future<void> createEvent(BuildContext context) async {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("Create A New Wedding"),
          content: Padding(
            padding: EdgeInsets.only(
              top: 5,
            ),
            child: CupertinoTextField(
              onChanged: (value) {
                setState(() {
                  eventNameText = value;
                });
              },
              controller: _createEventController,
              placeholder: "Event Name",
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: Text("Cancel"),
              isDefaultAction: true,
              isDestructiveAction: false,
              onPressed: () {
                _createEventController.clear();
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: Text("Create"),
              isDefaultAction: true,
              isDestructiveAction: false,
              onPressed: () {
                setState(() {
                  eventName = eventNameText;
                });

                _createEventController.clear();

                Navigator.pop(context);

                setState(() {
                  _addToList(eventName);
                });

                _saveEvents();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> delateAlort(BuildContext context, int index) async {
    return await showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("Delete Wedding?"),
          content: Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(
                "The Wedding \"${eventData[index].eventName}\" will be removed from your account and would require a rescan of the QR code."),
          ),
          actions: [
            CupertinoDialogAction(
              child: Text("Cancel"),
              isDefaultAction: true,
              isDestructiveAction: false,
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            CupertinoDialogAction(
              child: Text("Delete"),
              isDefaultAction: false,
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    setState(() {
      _readEvents();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      deviceInfo = MediaQuery.of(context);
    });

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("The Wedding App"),
        trailing: CupertinoButton(
          child: Icon(
            CupertinoIcons.add,
          ),
          onPressed: () async {
            await createEvent(context);

            await _saveEvents();
          },
        ),
      ),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: deviceInfo.size.width / 2,
          mainAxisExtent: deviceInfo.size.height / 8,
          childAspectRatio: 3 / 2,
        ),
        itemCount: eventData.length,
        itemBuilder: (context, index) {
          return CupertinoContextMenu(
            child: Padding(
              padding: EdgeInsets.fromLTRB(15, 7.5, 15, 7.5),
              child: OpenContainer(
                openBuilder: (context, animation) {
                  return CupertinoWeddingPage(
                    currentEventDataToSave: eventData[index],
                  );
                },
                closedBuilder: (context, animation) {
                  return ListTile(
                    title: Text(
                        "${eventData[index].eventName}: ${deviceInfo.platformBrightness.toString()}"),
                    tileColor:
                        (deviceInfo.platformBrightness == Brightness.dark)
                            ? Colors.black
                            : Colors.white,
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
            actions: [
              CupertinoContextMenuAction(
                child: Text(
                  "Cancel",
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                isDestructiveAction: false,
                isDefaultAction: true,
              ),
              CupertinoContextMenuAction(
                child: Text(
                  "Delete",
                ),
                isDefaultAction: false,
                isDestructiveAction: true,
                trailingIcon: CupertinoIcons.delete,
                onPressed: () async {
                  Navigator.pop(context);

                  bool shouldDelate = await delateAlort(context, index);

                  if (shouldDelate) {
                    setState(() {
                      deleteWedding(index);
                    });
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
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
        centerTitle: true,
        title: Text("Weddings"),
      ),
      body: GestureDetector(
        onTapDown: (details) => onTapDown(context, details),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: deviceInfo.size.width / 2,
            mainAxisExtent: deviceInfo.size.height / 8,
            childAspectRatio: 3 / 2,
          ),
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
                          deleteWedding(index);
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
                      title: Text(eventData[index].eventName),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await createEvent(context);
          await _saveEvents();
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
