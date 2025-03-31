# E-commerce Online Store Germany - Database Schema

## **Entities and Attributes**

### **1. Product**
- `product_id` (PK)
- `manufacturer_id` (FK)
- `subcategory_id` (FK)
- `brand_id` (FK)
- `name`
- `base_price`
- `total_stock_level`

### **2. Product Description**
- `product_id` (PK, FK)
- `language_code` (PK)
- `description`

### **3. Brand**
- `brand_id` (PK)
- `name`

### **4. Category**
- `category_id` (PK)
- `name`

### **5. Subcategory**
- `subcategory_id` (PK)
- `category_id` (FK)
- `name`

### **6. Graduated Price**
- `product_id` (PK, FK)
- `min_quantity` (PK)
- `price`

### **7. Manufacturer**
- `manufacturer_id` (PK)
- `country_code` (FK)
- `name`
- `address`
- `phone_number`
- `email`

### **8. Inventory**
- `inventory_id` (PK)
- `product_id` (FK)
- `store_id` (FK)
- `store_stock_level`

### **9. Store**
- `store_id` (PK)
- `country_code` (FK)
- `store_name`
- `store_address`
- `store_city`

### **10. Customer**
- `customer_id` (PK)
- `first_name`
- `last_name`
- `email` (Unique)
- `password` (nullable for guests)

### **11. Customer Order**
- `order_id` (PK)
- `customer_id` (FK, nullable for guest orders)
- `country_code` (FK)
- `order_date`
- `order_status` (ENUM: open, in_progress, shipped, completed, canceled)
- `payment_method` (ENUM: credit_card, paypal, prepayment)
- `delivery_address`
- `delivery_city`
- `shipping_cost`

### **12. Order Item**
- `order_id` (PK, FK)
- `product_id` (PK, FK)
- `quantity`
- `unit_price`
- `discount`

### **13. Country**
- `country_code` (PK)
- `country_name`

### **14. Review Rating**
- `review_id` (PK)
- `product_id` (FK)
- `customer_id` (FK, nullable for anonymous)
- `review_date`
- `rating` (1-5)
- `comment`
- UNIQUE (`customer_id`, `product_id`) *(prevents multiple reviews per product per customer)*

### **15. Shopping Cart**
- `cart_id` (PK)
- `customer_id` (FK, nullable for guests)
- `created_at`

### **16. Cart Item**
- `cart_id` (PK, FK)
- `product_id` (PK, FK)
- `quantity`

## **Relationships and Cardinalities**

### **One-to-Many (1:M) Relationships**
- `Product` → `Manufacturer`
- `Product` → `Brand`
- `Product` → `Subcategory`
- `Subcategory` → `Category`
- `Product` → `Inventory`
- `Inventory` → `Store`
- `Product` → `Graduated Price`
- `Customer` → `Customer Order`
- `Customer Order` → `Order Item`
- `Product` → `Product Description`
- `Product` → `Review Rating`
- `Customer` → `Review Rating`
- `Customer` → `Shopping Cart`
- `Shopping Cart` → `Cart Item`

### **Many-to-Many (M:M) Relationships**
- `Product` ↔ `Order Item`
- `Product` ↔ `Cart Item`

### **Many-to-One (M:1) Relationships**
- `Manufacturer` → `Country`
- `Store` → `Country`
- `Customer Order` → `Country`

### **One-to-One (1:1) Relationships**
- `Customer` → `Shopping Cart` *(nullable for guests)*

## **Key Features & Notes**

### **Guest Orders Supported**
- Guest users can place orders without an account (nullable `customer_id`).
- Guests must provide essential details (e.g., email, delivery address).

### **Review System**
- Customers can leave reviews anonymously (nullable `customer_id`).
- Unique constraint prevents duplicate reviews per product per customer.

### **Shopping Cart & Order Process**
- Guests and registered users can add multiple products to a cart before purchasing.
- `order_date` tracks order history.
- `order_status` and `payment_method` use ENUMs for efficiency.

### **Database Optimization**
- **Avoids duplication**: Composite keys in `order_item` and `cart_item` tables.
- **Standardized data**: ENUM fields ensure consistency.
- **Normalized structure**: `category` and `subcategory` ensure proper hierarchy.
- **Multi-language support**: `product_description` allows multiple language entries.

## **ER Diagram**
![ER Diagram](Images/Er_diagram.png)


---

### **Future Enhancements**
- Support for international shipping.
- Advanced discount and promotion system.
- AI-based product recommendations.
- Integration with multiple payment gateways.

This structured schema ensures a **scalable, efficient, and flexible** database design for an **E-commerce Online Store in Germany**. 

