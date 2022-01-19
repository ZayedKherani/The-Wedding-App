import 'package:chat_app_server/src/services/message/message_service_contract.dart';
import 'package:chat_app_server/src/services/encryption/encryption_contract.dart';
import 'package:chat_app_server/src/models/message.dart';
import 'package:chat_app_server/src/models/user.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';
import 'dart:async';

class MessageService implements IMessageService {
  final Connection? _connection;
  final RethinkDb? r;

  final IEncryption? _encryption;

  final StreamController<Message>? _controller =
      StreamController<Message>.broadcast();

  StreamSubscription? _changefeed;

  MessageService(this.r, this._connection, this._encryption);

  @override
  void dispose() {
    _changefeed?.cancel();
    _connection?.close();
    _controller?.close();
  }

  @override
  Stream<Message?>? messages({User? activeUser}) {
    _startReceivingMessages(activeUser!);
    return _controller!.stream;
  }

  @override
  Future<bool?>? send(Message? message) async {
    Map<String, dynamic>? data = message!.toJson();

    data!['contents'] = _encryption!.encrypt(message.contents);

    Map record = await r?.table('messages').insert(data).run(_connection!);

    return record['inserted'] == 1;
  }

  void _startReceivingMessages(User user) {
    _changefeed = r!
        .table('messages')
        .filter({
          'to': user.id,
        })
        .changes({
          'include_initial': true,
        })
        .run(_connection!)
        .asStream()
        .cast<Feed>()
        .listen((event) {
          event
              .forEach((feedData) {
                if (feedData['new_val'] == null) return;

                final message = _messageFromFeed(feedData);
                _controller?.sink.add(message!);
                _removeDeliveredMessage(message!);
              })
              .catchError((err) => print(err))
              .onError((error, stackTrace) => print(error));
        });
  }

  Message? _messageFromFeed(feedData) {
    Map<String, dynamic>? data = feedData['new_val'];
    data!['contents'] = _encryption!.decrypt(data['contents']);
    return Message.fromJson(data);
  }

  void _removeDeliveredMessage(Message message) {
    r?.table('messages').get(message.id).delete({
      'return_changes': false,
    }).run(_connection!);
  }
}
