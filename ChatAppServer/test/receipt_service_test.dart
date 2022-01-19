import 'package:chat_app_server/src/models/receipt.dart';
import 'package:chat_app_server/src/services/receipt/receipt_service_impl.dart';
import 'package:chat_app_server/src/models/user.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers.dart';

void main() async {
  RethinkDb? r = RethinkDb();
  Connection? connection;
  ReceiptService sut;

  // setUp(() async {
  connection = await r.connect(host: "netgearzayed.ddns.net", port: 28015);
  await createDb(r, connection);
  sut = ReceiptService(r, connection);
  // });

  setUp(() async {});

  tearDown(() async {
    // await cleanDb(r, connection!);
    sut.dispose();
  });

  final User? user = User(
    username: 'test',
    photoUrl: 'url',
    active: true,
    lastSeen: DateTime.now(),
  );

  test('sent receipt successfullt', () async {
    Receipt? receipt = Receipt(
      recipient: '444',
      messageId: '1234',
      status: ReceiptStatus.delivered,
      timestamp: DateTime.now(),
    );

    final bool? res = await sut.send(receipt);

    expect(res!, true);
  });

  test('successfully subscribe and receive receipts', () async {
    sut.receipts(user)!.listen(expectAsync1((receipt) {
          expect(receipt!.recipient, user!.id);
        }, count: 2));

    Receipt? receipt1 = Receipt(
      recipient: user!.id,
      messageId: '1234',
      status: ReceiptStatus.delivered,
      timestamp: DateTime.now(),
    );

    Receipt? receipt2 = Receipt(
      recipient: user.id,
      messageId: '1234',
      status: ReceiptStatus.read,
      timestamp: DateTime.now(),
    );

    await sut.send(receipt1);
    await sut.send(receipt2);
  });
}
