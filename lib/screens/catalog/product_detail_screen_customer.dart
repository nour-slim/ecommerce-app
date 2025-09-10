import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product})
    : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final currentItem = cartProvider.getItem(widget.product);

    if (currentItem != null && _quantity == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _quantity = currentItem.quantity);
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.product.description, style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text(
              "Price: \$${widget.product.price.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              "Stock: ${widget.product.stock}",
              style: TextStyle(
                fontSize: 16,
                color: widget.product.stock > 0 ? Colors.green : Colors.red,
              ),
            ),
            SizedBox(height: 24),

            Row(
              children: [
                Text("Quantity:", style: TextStyle(fontSize: 16)),
                SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: _quantity > 1
                      ? () => setState(() => _quantity--)
                      : null,
                ),
                Text(_quantity.toString(), style: TextStyle(fontSize: 18)),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _quantity < widget.product.stock
                      ? () => setState(() => _quantity++)
                      : null,
                ),
              ],
            ),

            SizedBox(height: 24),

            // Add to cart button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.product.stock > 0
                    ? () {
                        cartProvider.addItem(widget.product, _quantity);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Added to cart")),
                        );
                      }
                    : null,
                child: Text(
                  widget.product.stock > 0 ? "Add to Cart" : "Out of Stock",
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            if (currentItem != null) ...[
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    cartProvider.updateQuantity(widget.product, _quantity);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Cart updated")));
                  },
                  child: Text("Update Quantity"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
