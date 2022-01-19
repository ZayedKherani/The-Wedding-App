import 'package:chat_app_server/src/services/encryption/encryption_contract.dart';
import 'package:chat_app_server/src/services/encryption/encryption_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:encrypt/encrypt.dart';

main() {
  IEncryption? sut;

  setUp(() {
    final Encrypter? encrypter = Encrypter(
      AES(
        Key.fromLength(
          32,
        ),
      ),
    );

    sut = EncryptionService(encrypter);
  });

  test('it encrypts plain text', () {
    final String? text = 'this is a message';
    final RegExp? base64 = RegExp(
      r'^(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{4})$',
    );

    final String? encrypted = sut!.encrypt(text!);

    expect(base64!.hasMatch(encrypted!), true);
  });

  test('it decrypts the encrypted text', () {
    final String? text = 'this is a message';

    final String? encrypted = sut!.encrypt(text);
    final String? decrypted = sut!.decrypt(encrypted);

    expect(decrypted!, text!);
  });
}
