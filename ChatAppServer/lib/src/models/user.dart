import 'package:flutter/foundation.dart';

class User {
  String? get id => _id;
  DateTime? lastSeen;
  String? photoUrl;
  String? username;
  String? _id;
  bool? active;

  User({
    @required this.username,
    @required this.photoUrl,
    @required this.active,
    @required this.lastSeen,
  });

  toJson() => {
        'username': username,
        'photoUrl': photoUrl,
        'active': active,
        'lastSeen': lastSeen,
      };

  factory User.fromJson(Map<String, dynamic> json) {
    final user = User(
      username: json['username'],
      photoUrl: json['photoUrl'],
      active: json['active'],
      lastSeen: json['lastSeen'],
    );

    user._id = json['id'];

    return user;
  }
}
