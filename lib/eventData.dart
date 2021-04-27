import 'package:shared_preferences/shared_preferences.dart';

class EventData {
  int eventNumber;
  String eventName;
  DateTime eventDateTime;
  // int eventId;
  // List<Admin> admins;
  // List<Guest> guests;
  List<WeddingEvent> subEvents;

  EventData({
    int eventNumber,
    String eventName,
    DateTime eventDateTime,
    List<WeddingEvent> subEvents,
  }) {
    this.eventNumber = eventNumber;
    this.eventName = eventName;
    this.eventDateTime = eventDateTime;
    this.subEvents = (subEvents == null) ? [] : subEvents;
  }

  void setEventDateTime(DateTime dateTime) {
    this.eventDateTime = dateTime;
  }

  void addSubEvent(WeddingEvent event) {
    subEvents.add(event);
  }

  void removeSubEventByIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.remove("${subEvents[index].eventNumber}$eventName$eventNumber");

    prefs.setInt("numberOfEvents$eventName$eventNumber",
        prefs.getInt("numberOfEvents$eventName$eventNumber") - 1);

    subEvents.removeAt(index);
  }

  Map<String, dynamic> toMap() => {
        'eventNumber': eventNumber,
        'eventName': eventName,
        'eventDateTime': eventDateTime.toString(),
      };

  factory EventData.fromMap(Map<String, dynamic> map) => EventData(
        eventNumber: map['eventNumber'],
        eventName: map['eventName'],
        eventDateTime: DateTime.parse(map['eventDateTime']),
      );
}

class WeddingEvent {
  int eventNumber;
  String eventName;
  DateTime eventDateTime;

  WeddingEvent({int eventNumber, String eventName, DateTime eventDateTime}) {
    this.eventNumber = eventNumber;
    this.eventName = eventName;
    this.eventDateTime = eventDateTime;
  }

  Map<String, dynamic> toMap() => {
        'eventNumber': eventNumber,
        'eventName': eventName,
        'eventDateTime': eventDateTime.toString(),
      };

  factory WeddingEvent.fromMap(Map<String, dynamic> map) => WeddingEvent(
        eventNumber: map['eventNumber'],
        eventName: map['eventName'],
        eventDateTime: DateTime.parse(map['eventDateTime']),
      );
}
