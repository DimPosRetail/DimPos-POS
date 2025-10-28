enum PaymentMethodEnum {
  cash,
  qrVietqr,
  qrEdc,
  cardEdc,
  qrPayOs,
}

extension PaymentMethodEnumExtension on PaymentMethodEnum {
  String get name {
    switch (this) {
      case PaymentMethodEnum.cash:
        return 'Tiền mặt';
      case PaymentMethodEnum.qrVietqr:
        return 'QR VietQR';
      case PaymentMethodEnum.qrEdc:
        return 'QR EDC';
      case PaymentMethodEnum.cardEdc:
        return 'Thẻ EDC';
      case PaymentMethodEnum.qrPayOs:
        return 'QR PayOS';
    }
  }
}
