import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  double get subtotal => product.price * quantity;
  int get subtotalInCents => (product.price * 100 * quantity).round();

  Map<String, dynamic> toJson() {
    return {'productId': product.id, 'quantity': quantity};
  }
}
