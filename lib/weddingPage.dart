import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'eventData.dart';
import 'main.dart';

TextEditingController dateTimeController = TextEditingController(text: "");
String? eventNameText, eventName, eventDescriptionText, eventDescription;
DateTime selectedDate = DateTime.now().add(Duration(hours: 2));
EventData? currentWeddingData;
MediaQueryData? deviceInfo;

_readEvents() async {
  final prefs = await SharedPreferences.getInstance();

  int? loopLength = (prefs.getInt(
              "numberOfEvents${currentWeddingData!.eventName}${currentWeddingData!.eventNumber}") ==
          null)
      ? 0
      : prefs.getInt(
          "numberOfEvents${currentWeddingData!.eventName}${currentWeddingData!.eventNumber}");

  String? subEventIDsStrins = prefs.getString(
      "subEventIDs${currentWeddingData!.eventName}${currentWeddingData!.eventNumber}");

  if (subEventIDsStrins != null && subEventIDsStrins != "[]") {
    currentWeddingData!.subEventIDs = [];

    var map = json.decode(subEventIDsStrins);

    for (int i = 0; i < map.length; i++)
      currentWeddingData!.subEventIDs!.add(map[i]);

    if (loopLength != currentWeddingData!.subEvents!.length) {
      for (int i = 0; i < loopLength!; i++) {
        String? jsonCurrentEventDataToRead = prefs.getString(
                "${currentWeddingData!.subEventIDs![i]}${currentWeddingData!.eventName}${currentWeddingData!.eventNumber}") ??
            null;

        if (jsonCurrentEventDataToRead != null) {
          Map<String, dynamic> currentEventDataToRead =
              jsonDecode(jsonCurrentEventDataToRead);
          WeddingEvent currentEventData =
              WeddingEvent.fromMap(currentEventDataToRead);

          currentWeddingData!.addSubEvent(currentEventData);
        }
      }
    }
  }
}

_saveEvents() async {
  final prefs = await SharedPreferences.getInstance();

  for (int i = 0; i < currentWeddingData!.subEvents!.length; i++) {
    Map<String, dynamic> currentEventDataToSave =
        currentWeddingData!.subEvents![i].toMap();
    String jsonCurrentEventDataToSave = jsonEncode(currentEventDataToSave);

    prefs.setString(
        "${currentWeddingData!.subEvents![i].eventNumber}${currentWeddingData!.eventName}${currentWeddingData!.eventNumber}",
        jsonCurrentEventDataToSave);
  }

  prefs.setInt(
      "numberOfEvents${currentWeddingData!.eventName}${currentWeddingData!.eventNumber}",
      currentWeddingData!.subEvents!.length);
}

void addToList(String eventName, String eventDescription) {
  int eventNumber;

  if (currentWeddingData!.subEvents!.isEmpty) {
    eventNumber = 1;
  } else {
    eventNumber = currentWeddingData!.subEvents!.last.eventNumber! + 1;
  }

  WeddingEvent currentWeddingEventData = WeddingEvent(
    eventNumber: eventNumber,
    eventName: eventName,
    eventDateTime: selectedDate,
    eventDescription: eventDescription,
  );

  currentWeddingData!.addSubEvent(currentWeddingEventData);
}

class MaterialWeddingPage extends StatefulWidget {
  const MaterialWeddingPage({Key? key, this.currentEventDataToSave})
      : super(key: key);

  final EventData? currentEventDataToSave;

  @override
  _MaterialWeddingPageState createState() => _MaterialWeddingPageState();
}

class _MaterialWeddingPageState extends State<MaterialWeddingPage> {
  double? posx, posy;

  buildDateTimePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
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

    if (picked != null) {
      final TimeOfDay? changedTimer = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
          hour: selectedDate.hour,
          minute: selectedDate.minute,
        ),
      );

      if (changedTimer != null) {
        setState(() {
          selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            changedTimer.hour,
            changedTimer.minute,
          );

          dateTimeController.text =
              "${(selectedDate.day < 10) ? '0' : ''}${selectedDate.day} ${monthsAbr[selectedDate.month - 1]} ${selectedDate.year} ${(selectedDate.hour == 0) ? 12 : (selectedDate.hour > 12) ? selectedDate.hour - 12 : selectedDate.hour}:${selectedDate.minute} ${(selectedDate.hour == 0) ? 'am' : (selectedDate.hour > 12) ? 'pm' : 'am'}";
        });
      }
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
                  eventName ?? "",
                  eventDescription ?? "",
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
                "The Event \"${currentWeddingData!.subEvents![index].eventName}\" will be removed from your Wedding."),
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
    final box = context.findRenderObject() as RenderBox;
    final Offset localOffset = box.globalToLocal(details.globalPosition);

    setState(() {
      posx = localOffset.dx;
      posy = localOffset.dy;
    });
  }

  Color? generateCardColor() {
    if (weddingAppTheme.themeMode == 0)
      return Colors.white;
    else if (weddingAppTheme.themeMode == 1)
      return Colors.grey[850];
    else
      return (deviceInfo!.platformBrightness == Brightness.dark)
          ? Colors.grey[850]
          : Colors.white;
  }

  Color? generateCardShadowColor() {
    if (weddingAppTheme.themeMode == 0)
      return Colors.black;
    else if (weddingAppTheme.themeMode == 1)
      return Colors.white;
    else
      return (deviceInfo!.platformBrightness == Brightness.dark)
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
        title: Text(currentWeddingData!.eventName ?? ""),
      ),
      body: GestureDetector(
        onTapDown: (details) => onTapDown(context, details),
        child: Scrollbar(
          child: ListView.builder(
            itemCount: currentWeddingData!.subEvents!.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onLongPress: () {
                  showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(posx!, posy!, posx!, posy!),
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

                        if (shouldDelate) {
                          setState(() {
                            currentWeddingData!.removeSubEventByIndex(index);
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
                                  monthsAbr[currentWeddingData!
                                          .subEvents![index]
                                          .eventDateTime!
                                          .month -
                                      1],
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  currentWeddingData!
                                      .subEvents![index].eventDateTime!.day
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  softWrap: true,
                                ),
                                Text(
                                  currentWeddingData!
                                      .subEvents![index].eventDateTime!.year
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
                              currentWeddingData!.subEvents![index].eventName ??
                                  "",
                              style: TextStyle(
                                fontSize: 18,
                                color: (deviceInfo!.platformBrightness ==
                                        Brightness.dark)
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            Text(
                              currentWeddingData!
                                      .subEvents![index].eventDescription ??
                                  "",
                              style: TextStyle(
                                fontSize: 9,
                                color: (deviceInfo!.platformBrightness ==
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
