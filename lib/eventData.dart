class EventData {
  int eventNumber;
  String eventName;
  DateTime eventDateTime;
  // int eventId;
  // List<Admin> admins;
  // List<Guest> guests;

  EventData(int number, String name, DateTime dateTime) {
    this.eventNumber = number;
    this.eventName = name;
    this.eventDateTime = dateTime;
  }
}
