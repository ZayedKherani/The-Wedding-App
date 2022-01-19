import 'package:chat_app_server/src/services/receipt/receipt_service_contract.dart';
import 'package:chat_app_server/src/models/receipt.dart';
import 'package:chat_app_server/src/models/user.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';
import 'dart:async';

class ReceiptService implements IReceiptService {
  final Connection _connection;
  final RethinkDb r;

  final StreamController<Receipt> _controller =
      StreamController<Receipt>.broadcast();

  StreamSubscription? _changefeed;

  ReceiptService(this.r, this._connection);

  @override
  dispose() {
    _changefeed!.cancel();
    // _connection.close();
    _controller.close();
  }

  @override
  Stream<Receipt> receipts(User user) {
    _startReceivingReceipts(user);
    return _controller.stream;
  }

  @override
  Future<bool> send(Receipt receipt) async {
    Map record =
        await r.table('messages').insert(receipt.toJson()).run(_connection);

    return record['inserted'] == 1;
  }

  _startReceivingReceipts(User user) {
    _changefeed = r
        .table('receipts')
        .filter({
          'receipient': user.id,
        })
        .changes({
          'include_initial': true,
        })
        .run(_connection)
        .asStream()
        .cast<Feed>()
        .listen((event) {
          event
              .forEach((feedData) {
                if (feedData['new_val'] == null) return;

                final Receipt receipt = _receiptFromFeed(feedData);
                _controller.sink.add(receipt);
              })
              .catchError((err) => print(err))
              .onError((error, stackTrace) => print(error));
        });
  }

  Receipt _receiptFromFeed(feedData) {
    return Receipt.fromJson(feedData['new_val']);
  }
}
