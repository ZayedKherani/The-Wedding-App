import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';

final List<String> monthsAbr = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec"
];

class EventData { 
  List<WeddingEventData>? subEvents;
  List<int>? subEventIDs = [];
  String? eventDescription;
  List<int> personIDs = [];
  DateTime? eventDateTime;
  // List<Admin> admins;
  // List<Guest> guests;
  // File weddingPhoto;
  List<Person>? people;
  String? eventName;
  int? eventNumber;
  // int eventId;

  EventData({
    @required int? eventNumber,
    @required String? eventName,
    @required DateTime? eventDateTime,
    List<WeddingEventData>? subEvents,
    @required String? eventDescription,
    List<Person>? people,
  }) {
    this.eventNumber = eventNumber;
    this.eventName = eventName;
    this.eventDateTime = eventDateTime;
    this.subEvents = subEvents ?? [];
    this.eventDescription = eventDescription;
    this.people = people ?? [];
  }

  void setEventDateTime(DateTime dateTime) {
    this.eventDateTime = dateTime;
  }

  Future<void> addSubEvent(WeddingEventData event) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    subEvents!.add(event);

    if (!subEventIDs!.contains(event.eventNumber))
      subEventIDs!.add(event.eventNumber ?? 0);

    prefs.setString(
        "subEventIDs$eventName$eventNumber", subEventIDs.toString());
  }

  Future<void> addPerson(Person person) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    people!.add(person);

    if (!personIDs.contains(person.personID))
      personIDs.add(person.personID ?? 0);

    prefs.setString("personIDs$eventName$eventNumber", personIDs.toString());
  }

  Future<void> removeSubEventByIndex(int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove(
        "subEvent${subEvents![index].eventNumber}$eventName$eventNumber");

    if (prefs.getInt("numberOfEvents$eventName$eventNumber") != null)
      prefs.setInt("numberOfEvents$eventName$eventNumber",
          prefs.getInt("numberOfEvents$eventName$eventNumber")! - 1);

    subEventIDs!.remove(subEvents![index].eventNumber);

    prefs.setString(
        "subEventIDs$eventName$eventNumber", subEventIDs.toString());

    subEvents!.removeAt(index);
  }

  Future<void> removePersonByIndex(int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove("person${people![index].personID}$eventName$eventNumber");

    if (prefs.getInt("numberOfPeople$eventName$eventNumber") != null)
      prefs.setInt("numberOfPeople$eventName$eventNumber",
          prefs.getInt("numberOfPeople$eventName$eventNumber")! - 1);

    personIDs.remove(people![index].personID);

    prefs.setString("personIDs$eventName$eventNumber", personIDs.toString());

    people!.removeAt(index);
  }

  String nextEventDateTime() {
    return "${(eventDateTime!.day < 10) ? '0' : ''}${eventDateTime!.day} ${monthsAbr[eventDateTime!.month - 1]} ${eventDateTime!.year}";
  }

  Future<Map<String, dynamic>> toMap() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    for (int index = 0; index < people!.length; index++) {
      prefs.setString("person${people![index].personID}$eventName$eventNumber",
          jsonEncode(people![index].toMap()));
    }

    return {
      'eventNumber': eventNumber,
      'eventName': eventName,
      'eventDateTime': eventDateTime.toString(),
      'eventDescription': eventDescription,
    };
  }

  factory EventData.fromMap(Map<String, dynamic> map, SharedPreferences prefs) {
    List<Person> _people = [];

    for (int i = 0; i < 2; i++) {
      _people.add(
        Person.fromMap(
          jsonDecode(
            prefs.getString(
                    "person$i${map['eventName']}${map['eventNumber']}") ??
                "",
          ),
        ),
      );
    }

    return EventData(
      eventNumber: map['eventNumber'],
      eventName: map['eventName'],
      eventDateTime: DateTime.parse(map['eventDateTime']),
      eventDescription: map['eventDescription'],
      people: _people,
    );
  }
}

class WeddingEventData {
  String? eventName, eventDescription;
  DateTime? eventDateTime;
  Duration? timeLeft;
  int? eventNumber;

  WeddingEventData({
    @required int? eventNumber,
    @required String? eventName,
    @required DateTime? eventDateTime,
    @required String? eventDescription,
  }) {
    this.eventNumber = eventNumber;
    this.eventName = eventName;
    this.eventDateTime = eventDateTime;
    this.eventDescription = eventDescription;
    this.timeLeft = eventDateTime!.difference(DateTime.now());
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

  factory WeddingEventData.fromMap(Map<String, dynamic> map) => WeddingEventData(
        eventNumber: map['eventNumber'],
        eventName: map['eventName'],
        eventDateTime: DateTime.parse(map['eventDateTime']),
        eventDescription: map['eventDescription'],
      );
}

class Person {
  String? prefix, firstName, middleName, lastName, suffix;
  // File personPhoto;
  int? personID;

  Person({
    String? prefix = "",
    @required String? firstName,
    String? middleName = "",
    @required String? lastName,
    String? suffix = "",
    @required int? personID,
  }) {
    this.prefix = prefix;
    this.firstName = firstName;
    this.middleName = middleName;
    this.lastName = lastName;
    this.suffix = suffix;
    this.personID = personID;
  }

  Map<String, dynamic> toMap() => {
        'prefix': prefix,
        'firstName': firstName,
        'middleName': middleName,
        'lastName': lastName,
        'suffix': suffix,
        'personID': personID,
      };

  factory Person.fromMap(Map<String, dynamic> map) => Person(
        prefix: map['prefix'],
        firstName: map['firstName'],
        middleName: map['middleName'],
        lastName: map['lastName'],
        suffix: map['suffix'],
        personID: map['personID'],
      );
}
