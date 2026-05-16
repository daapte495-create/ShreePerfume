// models/order_model.dart
class OrderItem {
  const OrderItem({
    required this.productId,
    required this.title,
    required this.image,
    required this.quantity,
    required this.unitPrice,
  });

  final String productId;
  final String title;
  final String image;
  final int quantity;
  final double unitPrice;

  double get totalPrice => unitPrice * quantity;

  String get formattedTotalPrice => '₹${totalPrice.toStringAsFixed(0)}';
}

class OrderRecord {
  const OrderRecord({
    required this.id,
    required this.customerId,
    required this.customerEmail,
    required this.placedAt,
    required this.status,
    required this.items,
    required this.totalAmount,
    required this.shippingName,
    required this.shippingAddress,
    required this.city,
    required this.paymentLabel,
  });

  final String id;
  final String customerId;
  final String customerEmail;
  final DateTime placedAt;
  final String status;
  final List<OrderItem> items;
  final double totalAmount;
  final String shippingName;
  final String shippingAddress;
  final String city;
  final String paymentLabel;

  int get itemCount =>
      items.fold<int>(0, (total, item) => total + item.quantity);

  String get formattedTotalAmount => '₹${totalAmount.toStringAsFixed(0)}';

  bool matchesUser(String userId, String userEmail) {
    final normalizedEmail = userEmail.trim().toLowerCase();
    return (userId.isNotEmpty && customerId == userId) ||
        (customerId.isEmpty && customerEmail == normalizedEmail);
  }
}
