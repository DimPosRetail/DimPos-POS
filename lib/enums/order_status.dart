enum OrderStatus {
  PendingPayment,
  Confirmed,
  ReadyForPickup,
  Completed,
  Cancelled
}

extension OrderStatusLabel on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.PendingPayment:
        return 'Chờ xác nhận';
      case OrderStatus.Confirmed:
        return 'Đã xác nhận';
      case OrderStatus.ReadyForPickup:
        return 'Sẵn sàng';
      case OrderStatus.Completed:
        return 'Hoàn tất';
      case OrderStatus.Cancelled:
        return 'Đã huỷ';
    }
  }
}
