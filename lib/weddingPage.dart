import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:the_weddingy_appyyyyy/eventData.dart';

TextEditingController dateTimeController = TextEditingController(text: "");
DateTime selectedDate = DateTime.now().add(Duration(hours: 2));
String eventNameText, eventName;
EventData currentWeddingData;
MediaQueryData deviceInfo;

_readEvents() async {
  final prefs = await SharedPreferences.getInstance();

  int loopLength = (prefs.getInt(
              "numberOfEvents${currentWeddingData.eventName}${currentWeddingData.eventNumber}") ==
          null)
      ? 0
      : prefs.getInt(
          "numberOfEvents${currentWeddingData.eventName}${currentWeddingData.eventNumber}");

  if (loopLength != currentWeddingData.subEvents.length) {
    for (int i = 0; i < loopLength; i++) {
      String jsonCurrentEventDataToRead = prefs.getString(
              "${i.toString()}${currentWeddingData.eventName}${currentWeddingData.eventNumber}") ??
          null;

      if (jsonCurrentEventDataToRead != null) {
        Map<String, dynamic> currentEventDataToRead =
            jsonDecode(jsonCurrentEventDataToRead);
        WeddingEvent currentEventData =
            WeddingEvent.fromMap(currentEventDataToRead);

        currentWeddingData.addSubEvent(currentEventData);
      }
    }
  }
}

_saveEvents() async {
  final prefs = await SharedPreferences.getInstance();

  for (int i = 0; i < currentWeddingData.subEvents.length; i++) {
    Map<String, dynamic> currentEventDataToSave =
        currentWeddingData.subEvents[i].toMap();
    String jsonCurrentEventDataToSave = jsonEncode(currentEventDataToSave);

    prefs.setString(
        "${currentWeddingData.subEvents[i].eventNumber}${currentWeddingData.eventName}${currentWeddingData.eventNumber}",
        jsonCurrentEventDataToSave);
  }

  prefs.setInt(
      "numberOfEvents${currentWeddingData.eventName}${currentWeddingData.eventNumber}",
      currentWeddingData.subEvents.length);
}

void addToList(String eventName) {
  int eventNumber;

  if (currentWeddingData.subEvents.isEmpty) {
    eventNumber = 1;
  } else {
    eventNumber = currentWeddingData.subEvents.last.eventNumber + 1;
  }

  WeddingEvent currentWeddingEventData = WeddingEvent(
    eventNumber: eventNumber,
    eventName: eventName,
    eventDateTime: selectedDate,
  );

  currentWeddingData.addSubEvent(currentWeddingEventData);
}

class CupertinoWeddingPage extends StatefulWidget {
  const CupertinoWeddingPage({Key key, this.currentEventDataToSave})
      : super(key: key);

  final EventData currentEventDataToSave;

  @override
  _CupertinoWeddingPageState createState() => _CupertinoWeddingPageState();
}

class _CupertinoWeddingPageState extends State<CupertinoWeddingPage> {
  Future<void> createEvent(BuildContext context) async {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("Create A New Event"),
          content: Padding(
            padding: EdgeInsets.only(top: 5),
            child: Column(
              children: [
                CupertinoTextField(
                  placeholder: "Event Name",
                  onChanged: (value) {
                    setState(() {
                      eventNameText = value;
                    });
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                CupertinoTextField(
                  controller: dateTimeController,
                  readOnly: true,
                  onTap: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (context) {
                        return Container(
                          height: deviceInfo.size.height / 3,
                          color:
                              (deviceInfo.platformBrightness == Brightness.dark)
                                  ? Colors.white
                                  : Colors.black,
                          child: CupertinoDatePicker(
                            backgroundColor: (deviceInfo.platformBrightness ==
                                    Brightness.dark)
                                ? Colors.black
                                : Colors.white,
                            mode: CupertinoDatePickerMode.dateAndTime,
                            initialDateTime: selectedDate,
                            minimumDate: DateTime.now().add(Duration(hours: 1)),
                            maximumDate:
                                DateTime.now().add(Duration(days: 365 * 5)),
                            onDateTimeChanged: (picked) {
                              if (picked != null && picked != selectedDate) {
                                setState(() {
                                  selectedDate = picked;
                                  dateTimeController.text =
                                      selectedDate.toString().substring(0, 16);
                                });
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: Text("Create"),
              onPressed: () {
                setState(() {
                  eventName = eventNameText;
                });
                Navigator.pop(context);
                addToList(eventName);
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
          title: Text("Delete Event?"),
          content: Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(
                "The Event \"${currentWeddingData.subEvents[index].eventName}\" will be removed from your Wedding."),
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
      currentWeddingData = widget.currentEventDataToSave;

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
        middle: Text(currentWeddingData.eventName),
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
      child: ListView.builder(
        itemCount: currentWeddingData.subEvents.length,
        itemBuilder: (context, index) {
          return CupertinoContextMenu(
            child: Card(
              child: Text(currentWeddingData.subEvents[index].eventName),
              color: (deviceInfo.platformBrightness == Brightness.dark)
                  ? Colors.black
                  : Colors.white,
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
                      currentWeddingData.removeSubEventByIndex(index);
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

class MaterialWeddingPage extends StatefulWidget {
  const MaterialWeddingPage({Key key, this.currentEventDataToSave})
      : super(key: key);

  final EventData currentEventDataToSave;

  @override
  _MaterialWeddingPageState createState() => _MaterialWeddingPageState();
}

class _MaterialWeddingPageState extends State<MaterialWeddingPage> {
  double posx, posy;

  buildDateTimePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365 * 5)),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Select Event Date',
      errorFormatText: 'Enter Valid Date',
      errorInvalidText: 'Enter Date in Valid Range',
      fieldLabelText: 'Event Date',
      fieldHintText: 'Month/Date/Year',
    );

    final TimeOfDay changedTimer = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: selectedDate.hour,
        minute: selectedDate.minute,
      ),
    );

    if (changedTimer != null && picked != null) {
      setState(() {
        selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          changedTimer.hour,
          changedTimer.minute,
        );
        dateTimeController.text = selectedDate.toString().substring(0, 16);
      });
    }
  }

  Future<void> createEvent(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Create A New Event"),
          content: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      eventNameText = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                    ),
                    hintText: "Event Name",
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  textAlign: TextAlign.center,
                  readOnly: true,
                  controller: dateTimeController,
                  decoration: InputDecoration(
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                    ),
                    contentPadding: EdgeInsets.only(top: 0.0),
                  ),
                  onTap: () {
                    buildDateTimePicker(context);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
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
                Navigator.pop(context);
                addToList(eventName);
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
          title: Text("Delete Event?"),
          content: Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(
                "The Event \"${currentWeddingData.subEvents[index].eventName}\" will be removed from your Wedding."),
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
    setState(() {
      currentWeddingData = widget.currentEventDataToSave;

      _readEvents();
    });

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
        title: Text(currentWeddingData.eventName),
      ),
      body: GestureDetector(
        onTapDown: (details) => onTapDown(context, details),
        child: ListView.builder(
          itemCount: currentWeddingData.subEvents.length,
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
                          currentWeddingData.removeSubEventByIndex(index);
                        });
                      }
                    }
                  },
                );
              },
              child: Card(
                child: Text(currentWeddingData.subEvents[index].eventName),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
        ),
        onPressed: () async {
          await createEvent(context);

          await _saveEvents();
        },
      ),
    );
  }
}
