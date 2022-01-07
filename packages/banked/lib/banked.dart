import 'dart:async';

import 'package:flutter/services.dart';

class Banked {
  static const MethodChannel _channel = MethodChannel("banked");

  static Future<BankedResult> startPayment({
    required String apiKey,
    required String continueUrl,
    required String paymentId,
  }) async {
    try {
      await _channel.invokeMethod("startPayment", {
        'apiKey': apiKey,
        'continueUrl': continueUrl,
        'paymentId': paymentId,
      });

      return BankedResult(status: BankedStatus.done);
    } catch (exception) {
      return BankedResult(
        status: BankedStatus.error,
        error: exception,
      );
    }
  }
}

class BankedResult {
  final BankedStatus status;
  final dynamic error;

  BankedResult({
    required this.status,
    this.error,
  });

  @override
  String toString() => '{status: $status, error: $error}';
}

enum BankedStatus {
  cancelled,
  done,
  error,
}
