import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'eventData.dart';
import 'main.dart';

TextEditingController dateTimeController = TextEditingController(text: "");
String eventNameText, eventName, eventDescriptionText, eventDescription;
DateTime selectedDate = DateTime.now().add(Duration(hours: 2));
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

  String subEventIDsStrins = prefs.getString(
      "subEventIDs${currentWeddingData.eventName}${currentWeddingData.eventNumber}");

  if (subEventIDsStrins != null && subEventIDsStrins != "[]") {
    currentWeddingData.subEventIDs = [];

    var map = json.decode(subEventIDsStrins);

    for (int i = 0; i < map.length; i++)
      currentWeddingData.subEventIDs.add(map[i]);

    if (loopLength != currentWeddingData.subEvents.length) {
      for (int i = 0; i < loopLength; i++) {
        String jsonCurrentEventDataToRead = prefs.getString(
                "${currentWeddingData.subEventIDs[i]}${currentWeddingData.eventName}${currentWeddingData.eventNumber}") ??
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

void addToList(String eventName, String eventDescription) {
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
      eventDescription: eventDescription);

  currentWeddingData.addSubEvent(currentWeddingEventData);
}

List<String> monthsAbr = [
  "JAN",
  "FEB",
  "MAR",
  "APR",
  "MAY",
  "JUN",
  "JUL",
  "AUG",
  "SEP",
  "OCT",
  "NOV",
  "DEC"
];

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
                  placeholder: "Event Description",
                  onChanged: (value) {
                    setState(() {
                      eventDescriptionText = value;
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
                          // color:
                          //     (deviceInfo.platformBrightness == Brightness.dark)
                          //         ? Colors.white
                          //         : Colors.black,
                          child: CupertinoDatePicker(
                            backgroundColor: CupertinoDynamicColor.resolve(
                              CupertinoColors.secondarySystemGroupedBackground,
                              context,
                            ),
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
                  eventDescription = eventDescriptionText;
                });
                Navigator.pop(context);
                addToList(
                  eventName,
                  eventDescription,
                );
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
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            CupertinoSliverNavigationBar(
              largeTitle: Text(
                currentWeddingData.eventName,
              ),
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
          ];
        },
        body: CupertinoScrollbar(
          child: ListView.builder(
            itemCount: currentWeddingData.subEvents.length,
            itemBuilder: (context, index) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoContextMenu(
                    child: EventCard(
                      index: index,
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

                          if (shouldDelate != null && shouldDelate) {
                            setState(() {
                              currentWeddingData.removeSubEventByIndex(index);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  if (index + 1 != currentWeddingData.subEvents.length)
                    Divider(height: 2),
                ],
              );
            },
          ),
        ),
      ),
    );

    // return CupertinoPageScaffold(
    //   navigationBar: CupertinoNavigationBar(
    //     middle: Text(currentWeddingData.eventName),
    //     trailing: CupertinoButton(
    //       child: Icon(
    //         CupertinoIcons.add,
    //       ),
    //       onPressed: () async {
    //         await createEvent(context);

    //         await _saveEvents();
    //       },
    //     ),
    //   ),
    //   child: CupertinoScrollbar(
    //     child: ListView.builder(
    //       itemCount: currentWeddingData.subEvents.length,
    //       itemBuilder: (context, index) {
    //         return CupertinoContextMenu(
    //           child: EventCard(
    //             index: index,
    //           ),
    //           actions: [
    //             CupertinoContextMenuAction(
    //               child: Text(
    //                 "Cancel",
    //               ),
    //               onPressed: () {
    //                 Navigator.pop(context);
    //               },
    //               isDestructiveAction: false,
    //               isDefaultAction: true,
    //             ),
    //             CupertinoContextMenuAction(
    //               child: Text(
    //                 "Delete",
    //               ),
    //               isDefaultAction: false,
    //               isDestructiveAction: true,
    //               trailingIcon: CupertinoIcons.delete,
    //               onPressed: () async {
    //                 Navigator.pop(context);

    //                 bool shouldDelate = await delateAlort(context, index);

    //                 if (shouldDelate != null && shouldDelate) {
    //                   setState(() {
    //                     currentWeddingData.removeSubEventByIndex(index);
    //                   });
    //                 }
    //               },
    //             ),
    //           ],
    //         );
    //       },
    //     ),
    //   ),
    // );
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
                TextField(
                  onChanged: (value) {
                    setState(() {
                      eventDescriptionText = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                    ),
                    hintText: "Event Description",
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
                  eventDescription = eventDescriptionText;
                });
                Navigator.pop(context);
                addToList(
                  eventName,
                  eventDescription,
                );
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

  Color generateCardColor() {
    if (weddingAppTheme.themeMode == 0)
      return Colors.white;
    else if (weddingAppTheme.themeMode == 1)
      return Colors.grey[850];
    else
      return (deviceInfo.platformBrightness == Brightness.dark)
          ? Colors.grey[850]
          : Colors.white;
  }

  Color generateCardShadowColor() {
    if (weddingAppTheme.themeMode == 0)
      return Colors.black;
    else if (weddingAppTheme.themeMode == 1)
      return Colors.white;
    else
      return (deviceInfo.platformBrightness == Brightness.dark)
          ? Colors.white
          : Colors.black;
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
        child: Scrollbar(
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
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        ClipOval(
                          child: Container(
                            color: Colors.blue,
                            width: 64,
                            height: 64,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  monthsAbr[currentWeddingData.subEvents[index]
                                          .eventDateTime.month -
                                      1],
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  currentWeddingData
                                      .subEvents[index].eventDateTime.day
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  softWrap: true,
                                ),
                                Text(
                                  currentWeddingData
                                      .subEvents[index].eventDateTime.year
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currentWeddingData.subEvents[index].eventName,
                              style: TextStyle(
                                fontSize: 18,
                                color: (deviceInfo.platformBrightness ==
                                        Brightness.dark)
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            Text(
                              currentWeddingData
                                  .subEvents[index].eventDescription,
                              style: TextStyle(
                                fontSize: 9,
                                color: (deviceInfo.platformBrightness ==
                                        Brightness.dark)
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  color: generateCardColor(),
                  shadowColor: generateCardShadowColor(),
                ),
              );
            },
          ),
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

class EventCard extends StatefulWidget {
  const EventCard({Key key, this.index}) : super(key: key);

  final int index;

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  Color generateCardColor() {
    if (weddingAppTheme.themeMode == 0)
      return Colors.white;
    else if (weddingAppTheme.themeMode == 1)
      return Colors.grey[850];
    else
      return (deviceInfo.platformBrightness == Brightness.dark)
          ? Colors.grey[850]
          : Colors.white;
  }

  Color generateCardShadowColor() {
    if (weddingAppTheme.themeMode == 0)
      return Colors.black;
    else if (weddingAppTheme.themeMode == 1)
      return Colors.white;
    else
      return (deviceInfo.platformBrightness == Brightness.dark)
          ? Colors.white
          : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            ClipOval(
              child: Container(
                color: Colors.blue,
                width: 64,
                height: 64,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      monthsAbr[currentWeddingData
                              .subEvents[widget.index].eventDateTime.month -
                          1],
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currentWeddingData
                          .subEvents[widget.index].eventDateTime.day
                          .toString(),
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                    ),
                    Text(
                      currentWeddingData
                          .subEvents[widget.index].eventDateTime.year
                          .toString(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentWeddingData.subEvents[widget.index].eventName,
                  style: TextStyle(
                    fontSize: 18,
                    color: (deviceInfo.platformBrightness == Brightness.dark)
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                Text(
                  currentWeddingData.subEvents[widget.index].eventDescription,
                  style: TextStyle(
                    fontSize: 9,
                    color: (deviceInfo.platformBrightness == Brightness.dark)
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      color: generateCardColor(),
      shadowColor: generateCardShadowColor(),
    );
  }
}
