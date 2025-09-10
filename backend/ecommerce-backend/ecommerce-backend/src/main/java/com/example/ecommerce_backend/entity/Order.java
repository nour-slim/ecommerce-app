package com.example.ecommerce_backend.entity;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "orders")
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private LocalDateTime date;
    private int total; // Consider using int if you have decimal prices
    private String customerEmail; 

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    @JsonManagedReference
    private List<OrderItem> items = new ArrayList<>();

    public Order() {}

    public Order(LocalDateTime date, int total, String customerEmail, List<OrderItem> items) {
        this.date = date;
        this.total = total;
        this.customerEmail = customerEmail;
        this.items = items;
        this.items.forEach(item -> item.setOrder(this)); // Set the bidirectional relationship
    }

    public Long getId() { return id; }
    public LocalDateTime getDate() { return date; }
    public void setDate(LocalDateTime date) { this.date = date; }
    public int getTotal() { return total; }
    public void setTotal(int total) { this.total = total; }
    public String getCustomerEmail() { return customerEmail; }
    public void setCustomerEmail(String customerEmail) { this.customerEmail = customerEmail; }
    public List<OrderItem> getItems() { return items; }
    public void setItems(List<OrderItem> items) { 
        this.items = items;
        this.items.forEach(item -> item.setOrder(this));
    }

    public void addOrderItem(OrderItem item) {
        items.add(item);
        item.setOrder(this);
    }
}