import 'package:chat_app_server/src/services/user/user_service_impl.dart';
import 'package:chat_app_server/src/models/user.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers.dart';

void main() {
  RethinkDb? r = RethinkDb();
  Connection? connection;
  UserService? sut;

  setUp(() async {
    // try {
    //   connection = await r.connect(host: "192.168.2.56", port: 28015);
    // } catch (e) {
    //   connection = await r.connect(host: "netgearzayed.ddns.net", port: 28015);
    // }

    // connection = await r.connect(host: "192.168.2.56", port: 28015);

    connection = await r.connect(host: "netgearzayed.ddns.net", port: 28015);

    await createDb(r, connection!);
    sut = UserService(r, connection!);
  });

  tearDown(() async {
    await cleanDb(r, connection!);
  });

  test('creates a new user document in database', () async {
    final user = User(
      username: 'test',
      photoUrl: 'url',
      active: true,
      lastSeen: DateTime.now(),
    );

    final userWithId = await sut!.connect(user);

    expect(userWithId!.id, isNotEmpty);
  });

  test('get online users', () async {
    final User? user = User(
      username: 'test',
      photoUrl: 'url',
      active: true,
      lastSeen: DateTime.now(),
    );

    await sut!.connect(user!);

    final List<User?>? users = await sut!.online();

    expect(users!.length, 1);
  });
}
