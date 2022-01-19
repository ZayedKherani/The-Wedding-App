import 'package:chat_app_server/src/models/receipt.dart';
import 'package:chat_app_server/src/models/user.dart';

abstract class IReceiptService {
  Future<bool> send(Receipt receipt);

  Stream<Receipt> receipts(User user);

  void dispose();
}
