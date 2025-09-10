import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerceapp/models/product.dart';
import 'package:ecommerceapp/providers/cart_provider.dart';

void main() {
  late CartProvider cartProvider;
  late Product product1;
  late Product product2;

  setUp(() {
    cartProvider = CartProvider();

    product1 = Product(
      id: 1,
      name: 'Product 1',
      description: 'Description 1',
      price: 10.0,
      stock: 5,
    );

    product2 = Product(
      id: 2,
      name: 'Product 2',
      description: 'Description 2',
      price: 20.0,
      stock: 5,
    );
  });

  test('Add item to cart', () {
    cartProvider.addItem(product1, 2);

    expect(cartProvider.items.length, 1);
    expect(cartProvider.items.first.quantity, 2);
    expect(cartProvider.items.first.product.id, 1);
  });

  test('Add multiple products', () {
    cartProvider.addItem(product1, 1);
    cartProvider.addItem(product2, 2);

    expect(cartProvider.items.length, 2);
    expect(cartProvider.items[0].quantity, 1);
    expect(cartProvider.items[1].quantity, 2);
  });

  test('Increment quantity if product already exists', () {
    cartProvider.addItem(product1, 1);
    cartProvider.addItem(product1, 3);

    expect(cartProvider.items.first.quantity, 4);
  });

  test('Update quantity', () {
    cartProvider.addItem(product1, 2);
    cartProvider.updateQuantity(product1, 4);

    expect(cartProvider.items.first.quantity, 4);
  });

  test('Update quantity removes item if zero', () {
    cartProvider.addItem(product1, 2);
    cartProvider.updateQuantity(product1, 0);

    expect(cartProvider.items.isEmpty, true);
  });

  test('Remove item', () {
    cartProvider.addItem(product1, 1);
    cartProvider.addItem(product2, 1);

    cartProvider.removeItem(product1);

    expect(cartProvider.items.length, 1);
    expect(cartProvider.items.first.product.id, 2);
  });

  test('Clear cart', () {
    cartProvider.addItem(product1, 1);
    cartProvider.addItem(product2, 1);

    cartProvider.clearCart();

    expect(cartProvider.items.isEmpty, true);
  });

  test('Total amount calculation', () {
    cartProvider.addItem(product1, 2);
    cartProvider.addItem(product2, 1);

    expect(cartProvider.total, 40.0);
  });

  test('Item count calculation', () {
    cartProvider.addItem(product1, 2);
    cartProvider.addItem(product2, 3);

    expect(cartProvider.itemCount, 5);
  });

  test('Get item by product', () {
    cartProvider.addItem(product1, 2);

    final item = cartProvider.getItem(product1);

    expect(item, isNotNull);
    expect(item!.quantity, 2);
  });

  test('Get item returns null if not in cart', () {
    final item = cartProvider.getItem(product2);
    expect(item, null);
  });
}
