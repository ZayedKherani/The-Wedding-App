import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'weddingPage.dart';
import 'eventData.dart';
import 'main.dart';

TextEditingController _weddingDescriptionController = TextEditingController();
TextEditingController _weddingNameController = TextEditingController();
TextEditingController _dateTimeController = TextEditingController();

GlobalKey<FormState> _formKey = GlobalKey<FormState>();
DateTime selectedDate = DateTime.now();
List<EventData> eventData = [];
String eventDescription = "";
List<int> eventDataIDs = [];
MediaQueryData? deviceInfo;
String eventName = "";

List<String> middleName = ["", ""];
List<String> firstName = ["", ""];
List<String> fullName = ["", ""];
List<String> lastName = ["", ""];
List<String> prefix = ["", ""];
List<String> suffix = ["", ""];

Future<void> _saveWeddigns() async {
  final prefs = await SharedPreferences.getInstance();

  for (int i = 0; i < eventData.length; i++) {
    prefs.setString(eventData[i].eventNumber.toString(),
        jsonEncode(await eventData[i].toMap()));
  }

  prefs.setInt("numberOfEvents", eventData.length);

  prefs.setString("eventDataIDs", eventDataIDs.toString());
}

void _readEvents() async {
  final prefs = await SharedPreferences.getInstance();

  int loopLength = prefs.getInt("numberOfEvents") ?? 0;

  String? eventDataIDsString = prefs.getString("eventDataIDs");

  if (eventDataIDsString != null && eventDataIDsString != "[]") {
    eventDataIDs = [];

    var map = json.decode(eventDataIDsString);

    for (int i = 0; i < map.length; i++) eventDataIDs.add(map[i]);

    if (eventData.length < loopLength) {
      for (int i = 0; i < loopLength; i++) {
        String? jsonCurrentEventDataToRead =
            prefs.getString(eventDataIDs[i].toString()) ?? null;

        if (jsonCurrentEventDataToRead != null) {
          Map<String, dynamic> currentEventDataToRead =
              jsonDecode(jsonCurrentEventDataToRead);
          EventData currentEventData = EventData.fromMap(
            currentEventDataToRead,
            prefs,
          );

          eventData.add(currentEventData);
        }
      }
    }
  }
}

void _addToList() {
  int eventNumber;

  if (eventData.isEmpty) {
    eventNumber = 1;
  } else {
    eventNumber = eventData.last.eventNumber! + 1;
  }

  for (int i = 0; i < fullName.length; i++) {
    splitName(
      personIndex: i,
      fullNameTextToSplit: fullName[i],
    );
  }

  List<Person> people = [
    Person(
      prefix: prefix[0],
      firstName: firstName[0],
      middleName: middleName[0],
      lastName: lastName[0],
      suffix: suffix[0],
      personID: 0,
    ),
    Person(
      prefix: prefix[1],
      firstName: firstName[1],
      middleName: middleName[1],
      lastName: lastName[1],
      suffix: suffix[1],
      personID: 1,
    )
  ];

  EventData currentEventData = EventData(
    eventNumber: eventNumber,
    eventName: eventName,
    eventDateTime: selectedDate,
    eventDescription: eventDescription,
    people: people,
  );

  eventData.add(currentEventData);

  eventDataIDs.add(eventNumber);
}

Future<void> delateWedding(int index) async {
  final prefs = await SharedPreferences.getInstance();

  for (int i = 0; i < eventData[index].subEvents!.length; i++) {
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
      (prefs.getInt("numberOfEvents")! - 1 > 0)
          ? prefs.getInt("numberOfEvents")! - 1
          : 0);

  prefs.setString("eventDataIDs", eventDataIDs.toString());

  eventData.removeAt(index);
}

Future<void> splitName({
  @required int? personIndex,
  @required String? fullNameTextToSplit,
}) async {
  middleName[personIndex ?? 0] = "";
  lastName[personIndex ?? 0] = "";

  List<String> fullNameSplit = (fullNameTextToSplit ?? "").split(' ');

  if (fullNameSplit.length != 0) {
    if (fullNameSplit[0] == "" && fullNameSplit.length != 1)
      fullNameSplit.removeAt(0);
    firstName[personIndex ?? 0] = fullNameSplit[0];

    if (fullNameSplit.length == 2) {
      lastName[personIndex ?? 0] = fullNameSplit[1];
    } else if (fullNameSplit.length > 2) {
      lastName[personIndex ?? 0] = fullNameSplit.last;

      for (int i = 1; i < fullNameSplit.length - 1; i++) {
        middleName[personIndex ?? 0] +=
            fullNameSplit[i] + ((i == fullNameSplit.length - 2) ? '' : ' ');
      }
    }
  }
}

class WeddingHome extends StatefulWidget {
  @override
  _WeddingHomeState createState() => _WeddingHomeState();
}

class _WeddingHomeState extends State<WeddingHome> {
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

          _dateTimeController.text =
              "${(selectedDate.day < 10) ? '0' : ''}${selectedDate.day} ${monthsAbr[selectedDate.month - 1]} ${selectedDate.year} ${(selectedDate.hour == 0) ? 12 : (selectedDate.hour > 12) ? selectedDate.hour - 12 : selectedDate.hour}:${selectedDate.minute} ${(selectedDate.hour == 0) ? 'am' : (selectedDate.hour > 12) ? 'pm' : 'am'}";
        });
      }
    }
  }

  Future<void> createEvent(BuildContext context) async {
    _weddingNameController.clear();

    _weddingDescriptionController.clear();

    _dateTimeController.clear();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Create A New Wedding"),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    onChanged: (value) {
                      setState(() {
                        eventName = value;
                      });
                    },
                    controller: _weddingNameController,
                    decoration: InputDecoration(
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                      hintText: "Wedding Name",
                    ),
                    validator: (value) {
                      return (value == null || value.isEmpty)
                          ? 'Enter a valid wedding name'
                          : null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    onChanged: (value) {
                      setState(() {
                        eventName = value;
                      });
                    },
                    controller: _weddingDescriptionController,
                    decoration: InputDecoration(
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                      hintText: "Wedding Description",
                    ),
                    validator: (value) {
                      return (value == null || value.isEmpty)
                          ? 'Enter a valid wedding description'
                          : null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    readOnly: true,
                    controller: _dateTimeController,
                    decoration: InputDecoration(
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                      hintText: 'Wedding Time',
                    ),
                    onTap: () {
                      buildDateTimePicker(context);
                    },
                    validator: (value) {
                      //TODO: implemet date time check
                      return (value == null || value.isEmpty)
                          ? 'Enter a valid wedding date'
                          : null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: NameTextFormField(
                      personNumber: 0,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Weds",
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: NameTextFormField(
                      personNumber: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                _weddingNameController.clear();

                _weddingDescriptionController.clear();

                _dateTimeController.clear();

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
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    eventName = _weddingNameController.text;

                    eventDescription = _weddingDescriptionController.text;
                  });

                  _weddingNameController.clear();

                  _weddingDescriptionController.clear();

                  Navigator.pop(context);

                  setState(() {
                    _addToList();
                  });
                }
              },
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      8,
                    ),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.green,
                ),
                foregroundColor: MaterialStateProperty.all<Color>(
                  Colors.white,
                ),
              ),
            ),
          ],
          elevation: 24,
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
    final box = context.findRenderObject() as RenderBox;
    final Offset localOffset = box.globalToLocal(details.globalPosition);

    setState(() {
      posx = localOffset.dx;
      posy = localOffset.dy;
    });
  }

  Color? generateListTileColor() {
    if (weddingAppTheme.themeMode == 0)
      return Colors.white;
    else if (weddingAppTheme.themeMode == 1)
      return Colors.grey[850];
    else
      return (deviceInfo!.platformBrightness == Brightness.dark)
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
                            delateWedding(index);
                          });
                        }
                      }
                    },
                  );
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(15, 7.5, 15, 7.5),
                  child: GestureDetector(
                    child: Card(
                      child: ListTile(
                        title: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              eventData[index].eventName ?? "",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              eventData[index].nextEventDateTime(),
                            ),
                            OverflowText(
                              eventData[index].eventDescription!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                              textField: "WeddingDescription",
                            ),
                            Text(
                              "${eventData[index].people![0].firstName} ${eventData[index].people![0].lastName} Weds ${eventData[index].people![1].firstName} ${eventData[index].people![1].lastName}",
                            ),
                          ],
                        ),
                        tileColor: generateListTileColor(),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          18.0,
                        ),
                        side: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      elevation: 1.0,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (builder) => MaterialWeddingPage(
                            currentEventDataToSave: eventData[index],
                          ),
                        ),
                      );
                    },
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

class NameTextFormField extends StatefulWidget {
  const NameTextFormField({Key? key, @required this.personNumber})
      : super(key: key);

  final int? personNumber;

  @override
  _NameTextFormFieldState createState() => _NameTextFormFieldState();
}

class _NameTextFormFieldState extends State<NameTextFormField> {
  TextEditingController _fullNameController = TextEditingController();

  TextEditingController _prefixController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _middleNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _suffixController = TextEditingController();

  bool nameExpanded = false;

  Future<void> unsplitName() async {
    fullName[widget.personNumber ?? 0] = "";

    for (int i = 0; i < prefix[widget.personNumber ?? 0].length; i++) {
      fullName[widget.personNumber ?? 0] += prefix[widget.personNumber ?? 0] +
          ((i == prefix[widget.personNumber ?? 0].length - 1) ? '' : ' ');
    }

    fullName[widget.personNumber ?? 0] +=
        (firstName[widget.personNumber ?? 0].length != 0) ? ' ' : '';

    for (int i = 0; i < firstName[widget.personNumber ?? 0].length; i++) {
      fullName[widget.personNumber ?? 0] +=
          firstName[widget.personNumber ?? 0] +
              ((i == firstName[widget.personNumber ?? 0].length - 1)
                  ? ''
                  : ' ');
    }

    fullName[widget.personNumber ?? 0] +=
        (middleName[widget.personNumber ?? 0].length != 0) ? ' ' : '';

    for (int i = 0; i < middleName[widget.personNumber ?? 0].length; i++) {
      fullName[widget.personNumber ?? 0] +=
          middleName[widget.personNumber ?? 0] +
              ((i == middleName[widget.personNumber ?? 0].length - 1)
                  ? ''
                  : ' ');
    }

    fullName[widget.personNumber ?? 0] +=
        (lastName[widget.personNumber ?? 0].length != 0) ? ' ' : '';

    for (int i = 0; i < lastName[widget.personNumber ?? 0].length; i++) {
      fullName[widget.personNumber ?? 0] += lastName[widget.personNumber ?? 0] +
          ((i == lastName[widget.personNumber ?? 0].length - 1) ? '' : ' ');
    }

    fullName[widget.personNumber ?? 0] +=
        (suffix[widget.personNumber ?? 0].length != 0) ? ' ' : '';

    for (int i = 0; i < suffix[widget.personNumber ?? 0].length; i++) {
      fullName[widget.personNumber ?? 0] += suffix[widget.personNumber ?? 0] +
          ((i == suffix[widget.personNumber ?? 0].length - 1) ? '' : ' ');
    }

    fullName[widget.personNumber ?? 0] =
        fullName[widget.personNumber ?? 0].trim();

    setState(() {});
  }

  Future<void> assignStringToTextEditingControllerText() async {
    _fullNameController.text = fullName[widget.personNumber ?? 0];

    _prefixController.text = prefix[widget.personNumber ?? 0];
    _firstNameController.text = firstName[widget.personNumber ?? 0];
    _middleNameController.text = middleName[widget.personNumber ?? 0];
    _lastNameController.text = lastName[widget.personNumber ?? 0];
    _suffixController.text = suffix[widget.personNumber ?? 0];

    setState(() {});
  }

  Widget singleTextFormField() {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: Container(
              child: TextFormField(
                onChanged: (value) {
                  setState(() {
                    fullName[widget.personNumber ?? 0] = value;
                  });
                },
                controller: _fullNameController,
                decoration: InputDecoration(
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(10.0),
                    ),
                  ),
                  hintText: "Full Name",
                ),
                validator: (value) {
                  return (value == null || value.isEmpty)
                      ? 'Enter a valid name'
                      : null;
                },
              ),
            ),
          ),
          ElevatedButton(
            child: Icon(
              Icons.keyboard_arrow_down,
            ),
            onPressed: () async {
              setState(() {
                nameExpanded = true;
              });

              await splitName(
                personIndex: widget.personNumber,
                fullNameTextToSplit: _fullNameController.text,
              );
              await assignStringToTextEditingControllerText();

              setState(() {});
            },
            style: ButtonStyle(
              shape: MaterialStateProperty.all<OutlinedBorder>(
                CircleBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget multipleTextFormField() {
    return Container(
      child: Card(
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 20, 12, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 1,
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          prefix[widget.personNumber ?? 0] = value;
                        });
                      },
                      controller: _prefixController,
                      decoration: InputDecoration(
                        hintText: "Name prefix",
                      ),
                    ),
                  ),
                  ElevatedButton(
                    child: Icon(
                      Icons.keyboard_arrow_up,
                    ),
                    onPressed: () async {
                      setState(() {
                        nameExpanded = false;
                      });

                      await unsplitName();
                      await assignStringToTextEditingControllerText();
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        CircleBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    firstName[widget.personNumber ?? 0] = value;
                  });
                },
                controller: _firstNameController,
                decoration: InputDecoration(
                  hintText: "First name",
                ),
                validator: (value) {
                  return (value == null || value.isEmpty)
                      ? 'Enter a valid first name'
                      : null;
                },
              ),
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    middleName[widget.personNumber ?? 0] = value;
                  });
                },
                controller: _middleNameController,
                decoration: InputDecoration(
                  hintText: "Middle name",
                ),
              ),
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    lastName[widget.personNumber ?? 0] = value;
                  });
                },
                controller: _lastNameController,
                decoration: InputDecoration(
                  hintText: "Last name",
                ),
              ),
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    suffix[widget.personNumber ?? 0] = value;
                  });
                },
                controller: _suffixController,
                decoration: InputDecoration(
                  hintText: "Name suffix",
                ),
              ),
            ],
          ),
        ),
        shape: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(10.0),
          ),
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return (nameExpanded) ? multipleTextFormField() : singleTextFormField();
  }
}

class OverflowText extends StatefulWidget {
  const OverflowText(
    this.text, {
    Key? key,
    this.style,
    this.maxLines,
    this.overflow,
    required this.textField,
  }) : super(key: key);

  final String text;
  final int? maxLines;
  final TextStyle? style;
  final TextOverflow? overflow;
  final String textField;

  @override
  _OverflowTextState createState() => _OverflowTextState();
}

class _OverflowTextState extends State<OverflowText> {
  bool? hasTextOverflow(BuildContext context) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: widget.maxLines,
      textDirection: TextDirection.ltr,
    )..layout(
        minWidth: 0,
        maxWidth: MediaQuery.of(context).size.width,
      );

    return textPainter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);

    return TextButton(
      onPressed: hasTextOverflow(context)!
          ? () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(
                      widget.textField,
                    ),
                    content: SingleChildScrollView(
                      child: Text(
                        widget.text,
                      ),
                    ),
                  );
                },
              );
            }
          : null,
      child: Text(
        widget.text,
        style: widget.style,
        maxLines: widget.maxLines ?? defaultTextStyle.maxLines,
        overflow: widget.overflow ?? defaultTextStyle.overflow,
      ),
    );
  }
}
