import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ThemeData.dart';
import 'eventData.dart';

List<String> _items = [];
List<int> _events = [];

List<EventData> eventData = [];

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: darkTheme,
      title: 'The Wedding App',
      theme: lightTheme,
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
  double _screenWidth, _screenHeight;

  double posx = 100.0;
  double posy = 100.0;

  Future<void> createEvent(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return EventDateDialogBox();
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

  void _removeCurrentIndexFromList(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Delete Event"),
          content:
              Text("Are you sure you want to delete \"${_items[index]}\"?"),
          actions: [
            TextButton(
              child: Text("Delete"),
              onPressed: () {
                setState(() {
                  eventData.removeAt(index);
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

  @override
  Widget build(BuildContext context) {
    setState(() {
      _screenWidth = MediaQuery.of(context).size.width;
      _screenHeight = MediaQuery.of(context).size.height;
    });

    return GestureDetector(
      onTapDown: (details) => onTapDown(context, details),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Weddings" + ": $_screenWidth x $_screenHeight"),
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
              padding: EdgeInsets.fromLTRB(15.0, 7.5, 15.0, 7.5),
              child: ElevatedButton(
                onPressed: () {},
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
                  ).then((value) => {
                        if (value == 0) {_removeCurrentIndexFromList(index)}
                      });
                },
                child: ListTile(
                  title: Text(eventData[index].eventName),
                ),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            createEvent(context);
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class EventDateDialogBox extends StatefulWidget {
  EventDateDialogBox({Key key}) : super(key: key);

  @override
  _EventDateDialogBoxState createState() => _EventDateDialogBoxState();
}

class _EventDateDialogBoxState extends State<EventDateDialogBox> {
  TextEditingController _createEventController = TextEditingController();
  String eventNameText, eventName;

  DateTime selectedDate = DateTime.now();

  void _addToList(String eventName) {
    setState(() {
      _items.add(eventName);

      int eventNumber;

      if (eventData.isEmpty) {
        eventNumber = 1;
      } else {
        eventNumber = eventData.last.eventNumber + 1;
      }

      _events.add(eventNumber);

      EventData currentEventData =
          EventData(eventNumber, eventName, selectedDate);

      eventData.add(currentEventData);
    });
  }

  _selectDate(BuildContext context) async {
    final ThemeData theme = Theme.of(context);
    assert(theme.platform != null);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return buildMaterialDatePicker(context);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return buildCupertinoDatePicker(context);
    }
  }

  buildMaterialDatePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day),
      lastDate: DateTime(
          DateTime.now().year + 5, DateTime.now().month, DateTime.now().day),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Select Event Date',
      errorFormatText: 'Enter Valid Date',
      errorInvalidText: 'Enter Date in Valid Range',
      fieldLabelText: 'Event Date',
      fieldHintText: 'Month/Date/Year',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light(),
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  buildCupertinoDatePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height / 3,
            color: Colors.white,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: (picked) {
                if (picked != null && picked != selectedDate)
                  setState(() {
                    selectedDate = picked;
                  });
              },
              initialDateTime: selectedDate,
              minimumDate: DateTime(DateTime.now().year, DateTime.now().month,
                  DateTime.now().day),
              maximumDate: DateTime(DateTime.now().year + 5,
                  DateTime.now().month, DateTime.now().day),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text("Create A New Event"),
      content: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                eventNameText = value;
              });
            },
            controller: _createEventController,
            decoration: InputDecoration(
              hintText: "Event Name",
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text("${selectedDate.toLocal()}".split(" ")[0]),
          SizedBox(
            height: 20,
          ),
          TextButton(
            // onPressed: () => _selectDate(context),
            onPressed: () => _selectDate(context),
            child: Text('  Select Date  '),
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.grey[400]),
            ),
          ),
        ],
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
  }
}
