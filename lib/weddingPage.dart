import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';

import 'eventData.dart';

class WeddingHome extends StatefulWidget {
  WeddingHome({
    Key key,
    this.currentWeddingData,
  }) : super(key: key);

  final EventData currentWeddingData;

  @override
  _WeddingHomeState createState() => _WeddingHomeState();
}

class _WeddingHomeState extends State<WeddingHome> {
  TextEditingController _createEventController,
      _dateTimeController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  Duration initialtimer = new Duration();

  double _screenWidth, _screenHeight;

  String eventNameText, eventName;

  Duration timeLeftToEvent;

  double posx, posy;

  int selectedEventy = 0;

  List<String> months = [
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

  void _addToList(String eventName) {
    setState(() {
      int eventNumber;

      if (widget.currentWeddingData.subEvents.isEmpty) {
        eventNumber = 1;
      } else {
        eventNumber = widget.currentWeddingData.subEvents.last.eventNumber + 1;
      }

      WeddingEvent currentWeddingEventData = WeddingEvent(
        eventNumber: eventNumber,
        eventName: eventName,
        eventDateTime: selectedDate,
      );

      widget.currentWeddingData.addSubEvent(currentWeddingEventData);
    });
  }

  _readEvents() async {
    final prefs = await SharedPreferences.getInstance();

    int loopLength = (prefs.getInt(
                "numberOfEvents${widget.currentWeddingData.eventName}${widget.currentWeddingData.eventNumber}") ==
            null)
        ? 0
        : prefs.getInt(
            "numberOfEvents${widget.currentWeddingData.eventName}${widget.currentWeddingData.eventNumber}");

    if (loopLength != this.widget.currentWeddingData.subEvents.length) {
      for (int i = 0; i < loopLength; i++) {
        String jsonCurrentEventDataToRead = prefs.getString(
                "${i.toString()}${widget.currentWeddingData.eventName}${widget.currentWeddingData.eventNumber}") ??
            null;

        if (jsonCurrentEventDataToRead != null) {
          Map<String, dynamic> currentEventDataToRead =
              jsonDecode(jsonCurrentEventDataToRead);
          WeddingEvent currentEventData =
              WeddingEvent.fromMap(currentEventDataToRead);

          setState(() {
            widget.currentWeddingData.addSubEvent(currentEventData);
          });
        }
      }
    }
  }

  _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();

    for (int i = 0; i < widget.currentWeddingData.subEvents.length; i++) {
      Map<String, dynamic> currentEventDataToSave =
          widget.currentWeddingData.subEvents[i].toMap();
      String jsonCurrentEventDataToSave = jsonEncode(currentEventDataToSave);

      prefs.setString(
          "${i.toString()}${widget.currentWeddingData.eventName}${widget.currentWeddingData.eventNumber}",
          jsonCurrentEventDataToSave);
    }

    prefs.setInt(
        "numberOfEvents${widget.currentWeddingData.eventName}${widget.currentWeddingData.eventNumber}",
        widget.currentWeddingData.subEvents.length);
  }

  _selectDate(BuildContext context) async {
    final ThemeData theme = Theme.of(context);
    assert(theme.platform != null);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return buildMaterialDateTimePicker(context);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return buildCupertinoDateTimePicker(context);
    }
  }

  buildCupertinoDateTimePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          color: Colors.white,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.dateAndTime,
            onDateTimeChanged: (picked) {
              if (picked != null && picked != selectedDate)
                setState(() {
                  selectedDate = picked;
                  _dateTimeController.text =
                      selectedDate.toString().substring(0, 16);
                });
            },
            initialDateTime: selectedDate,
            minimumDate: DateTime.now(),
            maximumDate: DateTime.now().add(Duration(days: 365 * 5)),
          ),
        );
      },
    );
  }

  buildMaterialDateTimePicker(BuildContext context) async {
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
        _dateTimeController.text = selectedDate.toString().substring(0, 16);
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
            height: _screenHeight / 5,
            child: Column(
              children: [
                TextField(
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
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    _selectDate(context);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.grey[200]),
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      enabled: false,
                      controller: _dateTimeController,
                      decoration: InputDecoration(
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(10.0),
                          ),
                        ),
                        contentPadding: EdgeInsets.only(top: 0.0),
                      ),
                    ),
                  ),
                ),
              ],
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

  void _removeCurrentIndexFromList(int index) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Delete Event"),
          content: Text(
              "Are you sure you want to delete \"${widget.currentWeddingData.subEvents[index].eventName}\"?"),
          actions: [
            TextButton(
              child: Text("Delete"),
              onPressed: () {
                setState(() {
                  widget.currentWeddingData.removeSubEventByIndex(index);
                  _saveEvents();
                });
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
              autofocus: true,
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
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
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

  void calculateDefaultSelectedEventy() async {
    DateTime currentTime = DateTime.now();

    for (int i = 0; i < widget.currentWeddingData.subEvents.length; i++) {
      if (currentTime
              .compareTo(widget.currentWeddingData.subEvents[i].eventDateTime) <
          0) {
        continue;
      } else if (currentTime.compareTo(
              widget.currentWeddingData.subEvents[i].eventDateTime) >=
          0) {
        selectedEventy = i;
        break;
      }
    }
  }

  Color calculateCardColor(int index) {
    if (index == selectedEventy) {
      return Colors.blue;
    } else if (index < selectedEventy || index > selectedEventy) {
      return Colors.white;
    } else {
      return Colors.red;
    }
  }

  void calculateTimeToEvent() {
    setState(() {
      timeLeftToEvent = DateTime.now().difference(
          widget.currentWeddingData.subEvents[selectedEventy].eventDateTime);
    });

    Timer.periodic(
      Duration(seconds: 1),
      (Timer timer) {
        if (timeLeftToEvent.compareTo(Duration(seconds: 0)) == 0) {
          timer.cancel();
        } else {
          setState(() {
            timeLeftToEvent = DateTime.now().difference(widget
                .currentWeddingData.subEvents[selectedEventy].eventDateTime);
          });
        }
      },
    );
  }

  String generateTimeLeftString() {
    int seconds = timeLeftToEvent.inSeconds;

    int days = seconds ~/ Duration.secondsPerDay;
    seconds -= days * Duration.secondsPerDay;

    int hours = seconds ~/ Duration.secondsPerHour;
    seconds -= hours * Duration.secondsPerHour;

    int minutes = seconds ~/ Duration.secondsPerMinute;
    seconds -= minutes * Duration.secondsPerMinute;

    final List<String> timeLeft = [];

    if (days != 0) timeLeft.add('${days}d');

    if (timeLeft.isNotEmpty || hours != 0) timeLeft.add('${hours}h');

    if (timeLeft.isNotEmpty || minutes != 0) timeLeft.add('${minutes}m');

    timeLeft.add('${seconds}s');

    return timeLeft.join(' ').replaceAll("-", "");
  }

  @override
  void initState() {
    _readEvents();

    calculateDefaultSelectedEventy();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _screenWidth = MediaQuery.of(context).size.width;
      _screenHeight = MediaQuery.of(context).size.height;
    });

    if (widget.currentWeddingData.subEvents.isNotEmpty) calculateTimeToEvent();

    return GestureDetector(
      onTapDown: (details) => onTapDown(context, details),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Events"),
        ),
        body: Column(
          children: [
            Container(
              height: 100,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: _screenWidth,
                  mainAxisExtent: _screenHeight / 8,
                  crossAxisSpacing: 0,
                ),
                itemCount: widget.currentWeddingData.subEvents.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(0, 7.5, 0, 7.5),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedEventy = index;
                        });
                      },
                      onLongPress: () async {
                        showMenu(
                          context: context,
                          position:
                              RelativeRect.fromLTRB(posx, posy, posx, posy),
                          items: <PopupMenuEntry>[
                            PopupMenuItem(
                              value: 0,
                              child: Text("Delete"),
                            ),
                          ],
                        ).then((value) => {
                              if (value == 0)
                                {_removeCurrentIndexFromList(index)}
                            });
                      },
                      child: Card(
                        child: ListTile(
                          tileColor: calculateCardColor(index),
                          title: Text(widget
                              .currentWeddingData.subEvents[index].eventName),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                title: Text(
                  widget.currentWeddingData.subEvents[selectedEventy].eventName,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Card(
              child: Container(
                padding: EdgeInsets.all(_screenHeight / 136.2),
                width: _screenWidth,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      generateTimeLeftString() +
                          ((timeLeftToEvent.inMilliseconds < 0)
                              ? " Left To Event"
                              : " Passed Since Event"),
                    ),
                    SizedBox(
                      width: _screenWidth / 63.2,
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      radius: 40,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(months[widget
                                  .currentWeddingData
                                  .subEvents[selectedEventy]
                                  .eventDateTime
                                  .month -
                              1]),
                          Text(widget.currentWeddingData
                              .subEvents[selectedEventy].eventDateTime.day
                              .toString()),
                          Text(widget.currentWeddingData
                              .subEvents[selectedEventy].eventDateTime.year
                              .toString()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await createEvent(context);

            await _saveEvents();
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
