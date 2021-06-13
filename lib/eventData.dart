import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';

class EventData {
  // File groomPhoto, bridePhoto, weddingPhoto;
  String eventName, eventDescription;
  List<WeddingEvent> subEvents;
  List<int> subEventIDs = [];
  DateTime eventDateTime;
  // List<Admin> admins;
  // List<Guest> guests;
  int eventNumber;
  // int eventId;

  EventData({
    int eventNumber,
    String eventName,
    DateTime eventDateTime,
    List<WeddingEvent> subEvents,
    String eventDescription,
  }) {
    this.eventNumber = eventNumber;
    this.eventName = eventName;
    this.eventDateTime = eventDateTime;
    this.subEvents = (subEvents == null) ? [] : subEvents;
    this.eventDescription = eventDescription;
  }

  void setEventDateTime(DateTime dateTime) {
    this.eventDateTime = dateTime;
  }

  Future<void> addSubEvent(WeddingEvent event) async {
    final prefs = await SharedPreferences.getInstance();

    subEvents.add(event);
    if (!subEventIDs.contains(event.eventNumber))
      subEventIDs.add(event.eventNumber);

    prefs.setString(
        "subEventIDs$eventName$eventNumber", subEventIDs.toString());
  }

  Future<void> removeSubEventByIndex(int index) async {
    subEvents[index].timer.cancel();

    final prefs = await SharedPreferences.getInstance();

    prefs.remove("${subEvents[index].eventNumber}$eventName$eventNumber");

    if (prefs.getInt("numberOfEvents$eventName$eventNumber") != null)
      prefs.setInt("numberOfEvents$eventName$eventNumber",
          prefs.getInt("numberOfEvents$eventName$eventNumber") - 1);

    subEventIDs.remove(subEvents[index].eventNumber);

    prefs.setString(
        "subEventIDs$eventName$eventNumber", subEventIDs.toString());

    subEvents.removeAt(index);
  }

  String nextEventDateTime() {
    return DateTime.now().toString();
  }

  Map<String, dynamic> toMap() => {
        'eventNumber': eventNumber,
        'eventName': eventName,
        'eventDateTime': eventDateTime.toString(),
        'eventDescription': eventDescription,
      };

  factory EventData.fromMap(Map<String, dynamic> map) => EventData(
        eventNumber: map['eventNumber'],
        eventName: map['eventName'],
        eventDateTime: DateTime.parse(map['eventDateTime']),
        eventDescription: map['eventDescription'],
      );
}

class WeddingEvent {
  DateTime eventDateTime;
  Duration timeLeft;
  String eventName, eventDescription;
  int eventNumber;
  Timer timer;

  WeddingEvent({
    int eventNumber,
    String eventName,
    DateTime eventDateTime,
    String eventDescription,
  }) {
    this.eventNumber = eventNumber;
    this.eventName = eventName;
    this.eventDateTime = eventDateTime;
    this.eventDescription = eventDescription;
    this.timeLeft = eventDateTime.difference(DateTime.now());

    timer = Timer.periodic(
      Duration(seconds: 1),
      (timer) {
        this.timeLeft = eventDateTime.difference(DateTime.now());
      },
    );
  }

  String calculateTimeLeft() {
    return timeLeft.toString();
  }

  Map<String, dynamic> toMap() => {
        'eventNumber': eventNumber,
        'eventName': eventName,
        'eventDateTime': eventDateTime.toString(),
        'eventDescription': eventDescription,
      };

  factory WeddingEvent.fromMap(Map<String, dynamic> map) => WeddingEvent(
        eventNumber: map['eventNumber'],
        eventName: map['eventName'],
        eventDateTime: DateTime.parse(map['eventDateTime']),
        eventDescription: map['eventDescription'],
      );
}
