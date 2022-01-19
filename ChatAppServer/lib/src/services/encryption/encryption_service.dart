import 'package:chat_app_server/src/services/encryption/encryption_contract.dart';
import 'package:encrypt/encrypt.dart';

class EncryptionService implements IEncryption {
  final Encrypter? _encrypter;
  final IV? _iv = IV.fromLength(16);

  EncryptionService(this._encrypter);

  @override
  String? decrypt(String? encryptedText) {
    final Encrypted? encrypted = Encrypted.from64(encryptedText!);
    return _encrypter!.decrypt(encrypted!, iv: this._iv);
  }

  @override
  String? encrypt(String? text) {
    return _encrypter!.encrypt(text!, iv: this._iv).base64;
  }
}
