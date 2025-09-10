class Order {
  final int id;
  final DateTime date;
  final double total;
  final String? customerEmail;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.date,
    required this.total,
    required this.customerEmail,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      date: DateTime.parse(json['date']),
      total: (json['total'] as num).toDouble(),
      customerEmail: json['customerEmail'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }
}

class OrderItem {
  final String name;
  final double price;
  final int quantity;

  OrderItem({required this.name, required this.price, required this.quantity});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['productName'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
    );
  }
}
