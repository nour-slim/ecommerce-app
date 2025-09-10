package com.example.ecommerce_backend.controller;

import com.example.ecommerce_backend.dto.OrderRequest;
import com.example.ecommerce_backend.entity.Order;
import com.example.ecommerce_backend.entity.OrderItem;
import com.example.ecommerce_backend.entity.Product;
import com.example.ecommerce_backend.repository.OrderRepository;
import com.example.ecommerce_backend.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/orders")
@CrossOrigin(origins = {"http://localhost:54952"}) 
public class OrderController {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private ProductRepository productRepository;

    // Get all orders (for admin)
    @GetMapping("/all")
    public List<Order> getAllOrders() {
        return orderRepository.findAll();
    }

    @GetMapping("/me")
    public ResponseEntity<?> getMyOrders(@RequestParam String email) {
        try {
            List<Order> orders = orderRepository.findByCustomerEmail(email);
            return ResponseEntity.ok(orders);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error fetching orders: " + e.getMessage());
        }
    }

    @GetMapping("/customer/{email}")
    public ResponseEntity<?> getOrdersByEmail(@PathVariable String email) {
        try {
            List<Order> orders = orderRepository.findByCustomerEmail(email);
            return ResponseEntity.ok(orders);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error fetching orders: " + e.getMessage());
        }
    }

    // Place new order
    @PostMapping
    @Transactional
    public ResponseEntity<?> placeOrder(@RequestBody OrderRequest request) {
        try {
            if (request.getItems() == null || request.getItems().isEmpty()) {
                return ResponseEntity.badRequest().body("Order must contain items");
            }

            if (request.getCustomerEmail() == null || request.getCustomerEmail().trim().isEmpty()) {
                return ResponseEntity.badRequest().body("Customer email is required");
            }

            List<OrderItem> orderItems = new ArrayList<>();
            int calculatedTotal = 0;

            for (OrderRequest.OrderItemRequest itemReq : request.getItems()) {
                Optional<Product> productOpt = productRepository.findById(itemReq.getProductId());
                
                if (productOpt.isEmpty()) {
                    return ResponseEntity.badRequest().body("Product not found with ID: " + itemReq.getProductId());
                }

                Product product = productOpt.get();

                if (product.getStock() < itemReq.getQuantity()) {
                    return ResponseEntity.badRequest().body("Not enough stock for " + product.getName() + 
                                                           ". Available: " + product.getStock() + 
                                                           ", Requested: " + itemReq.getQuantity());
                }

                product.setStock(product.getStock() - itemReq.getQuantity());
                productRepository.save(product);

                OrderItem orderItem = new OrderItem(
                    product.getId(),
                    product.getName(),
                    itemReq.getQuantity(),
                    product.getPrice() 
                );
                
                orderItems.add(orderItem);
                calculatedTotal += (orderItem.getPrice() * orderItem.getQuantity());
            }

            if (Math.abs(request.getTotal() - calculatedTotal) > 0.01) {
                    return ResponseEntity.badRequest().body("Total mismatch...");
                }


            // Create and save order
            Order order = new Order(
                LocalDateTime.now(),
                calculatedTotal,
                request.getCustomerEmail(),
                orderItems
            );

            Order savedOrder = orderRepository.save(order);
            return ResponseEntity.status(201).body(savedOrder);

        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error placing order: " + e.getMessage());
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getOrderById(@PathVariable Long id) {
        Optional<Order> order = orderRepository.findById(id);
        if (order.isPresent()) {
            return ResponseEntity.ok(order.get());
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}