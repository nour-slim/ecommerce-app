import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ecommerceapp/providers/cart_provider.dart';
import 'package:ecommerceapp/models/product.dart';
import 'package:ecommerceapp/screens/customer/cart_screen.dart';

void main() {
  testWidgets('CartScreen shows items and updates total', (
    WidgetTester tester,
  ) async {
    final cartProvider = CartProvider();
    final product = Product(
      id: 1,
      name: 'Test Product',
      price: 10.0,
      stock: 5,
      description: 'Test description',
    );

    cartProvider.addItem(product, 2);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: cartProvider,
        child: MaterialApp(home: CartScreen()),
      ),
    );
    expect(find.text('Test Product'), findsOneWidget);

    expect(find.text('Subtotal: \$20.00'), findsOneWidget);

    final addButton = find.byKey(ValueKey('add-${product.id}'));
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    final quantityFinder = find.byKey(ValueKey('quantity-${product.id}'));
    expect(quantityFinder, findsOneWidget);
    expect(
      find.descendant(of: quantityFinder, matching: find.text('3')),
      findsOneWidget,
    );

    expect(find.text('\$30.00'), findsOneWidget);
  });
}
