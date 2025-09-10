package com.example.ecommerce_backend.controller;

import com.example.ecommerce_backend.entity.Product;
import com.example.ecommerce_backend.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/products")
@CrossOrigin(origins = "http://localhost:54952")
public class ProductController {

    @Autowired
    private ProductRepository productRepository;

    // GET /products → 200
    @GetMapping
    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getProductById(@PathVariable Long id) {
        Optional<Product> product = productRepository.findById(id);
        if (product.isPresent()) {
            return ResponseEntity.ok(product.get()); 
        } else {
            return ResponseEntity.status(404).body("Product not found"); 
        }
    }


    @PostMapping()
    public ResponseEntity<Product> addProduct(@RequestBody Product product) {
        Product saved = productRepository.save(product);
        return ResponseEntity.status(201).body(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateProduct(@PathVariable Long id, @RequestBody Product updatedProduct) {
        Optional<Product> productOptional = productRepository.findById(id);
        if (productOptional.isPresent()) {
            Product product = productOptional.get();
            product.setName(updatedProduct.getName());
            product.setDescription(updatedProduct.getDescription());
            product.setPrice(updatedProduct.getPrice());
            product.setStock(updatedProduct.getStock());
            
            productRepository.save(product);
            return ResponseEntity.ok(product);
        }
        return ResponseEntity.status(404).body("Product not found");
    }

    
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteProduct(@PathVariable Long id) {
        if (productRepository.existsById(id)) {
            productRepository.deleteById(id);
            return ResponseEntity.ok().body("Product deleted");
        }
        return ResponseEntity.status(404).body("Product not found");
    }

    @GetMapping("/admin/low-stock")
    public ResponseEntity<List<Product>> getLowStockProducts() {
        List<Product> lowStockProducts = productRepository.findByStockLessThan(5);
        return ResponseEntity.ok(lowStockProducts);
    }
}
