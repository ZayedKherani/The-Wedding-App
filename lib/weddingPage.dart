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
  TextEditingController _createEventController = TextEditingController();
  TextEditingController _dateTimeController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  Duration initialtimer = new Duration();

  double _screenWidth, _screenHeight;

  String eventNameText, eventName;

  double posx = 100.0;
  double posy = 100.0;

  int selectedEventy = 0;

  Duration timeLeftToEvent;

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
            height: _screenHeight / 6,
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

    calculateTimeToEvent();

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
                width: _screenWidth,
                child: Column(
                  children: [
                    Text("Time Left To Event"),
                    Text(timeLeftToEvent.inSeconds.toString()),
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
