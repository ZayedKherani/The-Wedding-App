import 'package:chat_app_server/src/services/encryption/encryption_service.dart';
import 'package:chat_app_server/src/services/message/message_service_impl.dart';
import 'package:chat_app_server/src/models/message.dart';
import 'package:chat_app_server/src/models/user.dart';
import 'package:encrypt/encrypt.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers.dart';

void main() {
  RethinkDb? r = RethinkDb();
  Connection? connection;
  MessageService? sut;

  setUp(() async {
    connection = await r.connect(host: 'netgearzayed.ddns.net', port: 28015);
    final encryption = EncryptionService(
      Encrypter(
        AES(
          Key.fromLength(32),
        ),
      ),
    );
    await createDb(r, connection!);
    sut = MessageService(r, connection, encryption);
  });

  tearDown(() async {
    // await cleanDb(r, connection);
    sut!.dispose();
  });

  final User? user1 = User.fromJson({
    'id': '1234',
    'active': true,
    'lastSeen': DateTime.now(),
  });

  final User? user2 = User.fromJson({
    'id': '5678',
    'active': true,
    'lastSeen': DateTime.now(),
  });

  test('sent message successfully', () async {
    Message message = Message(
      from: user1!.id,
      to: '3456',
      timestamp: DateTime.now(),
      contents: 'this is a message',
    );

    final res = await sut!.send(message);

    expect(res, true);
  });

  test('successfully subscribe and recieve messages', () async {
    String? contents = 'this is a message';

    sut!
        .messages(
          activeUser: user2,
        )!
        .listen(expectAsync1((message) {
          expect(message!.to, user2!.id);
          expect(message.id, isNotEmpty);
          expect(message.contents, contents);
        }, count: 2));

    Message? message1 = Message(
      from: user1!.id,
      to: user2!.id,
      timestamp: DateTime.now(),
      contents: contents,
    );

    Message? message2 = Message(
      from: user1.id,
      to: user2.id,
      timestamp: DateTime.now(),
      contents: contents,
    );

    await sut!.send(message1);
    await sut!.send(message2);
  });

  test('successfully subscribe and recieve new messages', () async {
    Message message1 = Message(
      from: user1!.id,
      to: user2!.id,
      timestamp: DateTime.now(),
      contents: 'this is a message',
    );

    Message message2 = Message(
      from: user1.id,
      to: user2.id,
      timestamp: DateTime.now(),
      contents: 'this is another message',
    );

    await sut!.send(message1)!;
    await sut!.send(message2)!.whenComplete(
          () => sut!
              .messages(
                activeUser: user2,
              )!
              .listen(
                expectAsync1(
                  (message) {
                    expect(
                      message!.to,
                      user2.id,
                    );
                  },
                  count: 2,
                ),
              ),
        );
  });
}
