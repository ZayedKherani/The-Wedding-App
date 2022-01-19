import 'package:chat_app_server/src/models/message.dart';
import 'package:chat_app_server/src/models/user.dart';
import 'package:flutter/foundation.dart';

abstract class IMessageService {
  Future<bool?>? send(Message message);

  Stream<Message?>? messages({
    @required User activeUser,
  });

  void dispose();
}
