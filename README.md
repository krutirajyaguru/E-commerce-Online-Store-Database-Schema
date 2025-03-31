# E-commerce-Online-Store-Germany-Database-Schema 

## Entities and Attributes:

1. **product**
    - product_id (PK)
    - manufacturer_id (FK)
    - subcategory_id (FK)
    - brand_id (FK)
    - name
    - base_price
    - total_stock_level
    
2. **product_description**
   - product_id (PK, FK)
   - language_code (PK)
   - description

3. **brand**
    - brand_id (PK)
    - name

4. **category**
    - category_id (PK)
    - name

5. **subcategory**
   - subcategory_id (PK)
   - category_id (FK)
   - name

6. **graduated_price**
   - product_id (PK, FK)
   - min_quantity (PK)
   - price

7. **manufacturer**
   - manufacturer_id (PK)
   - country_code (FK) 
   - name
   - address
   - phone_number
   - email

8. **inventory**
   - inventory_id (PK)
   - product_id (FK)
   - store_id (FK)
   - store_stock_level

9. **store**
   - store_id (PK)
   - country_code (FK)
   - store_name
   - store_address
   - store_city 

10. **customer**
   - customer_id (PK)
   - first_name
   - last_name
   - email (Unique)
   - password (nullable for guests)

11. **customer_order**
   - order_id (PK)
   - customer_id (FK, nullable for guest orders)
   - country_code (FK)
   - order_date
   - order_status (ENUM: open, in_progress, shipped, completed, canceled)
   - payment_method (ENUM: credit_card, paypal, prepayment)
   - delivery_address
   - delivery_city 
   - shipping_cost
 
12. **order_item**
   - order_id (PK, FK)
   - product_id (PK, FK)
   - quantity
   - unit_price
   - discount

13. **country**
   - country_code (PK)
   - country_name

14. **review_rating**
    - review_id (PK)
    - product_id (FK)
    - customer_id (FK, nullable for anonymous)
    - review_date
    - rating (1-5)
    - comment
    - UNIQUE (customer_id, product_id) # (Added Unique Constraint to prevent multiple reviews per product per customer)

15. **shopping_cart**
   - cart_id (PK)
   - customer_id (FK, nullable for guests)
   - created_at

16. **cart_item**
   - cart_id (PK, FK)
   - product_id (PK, FK)
   - quantity

## Relationships and Cardinalities:

1. **product (M) ↔ (1) manufacturer**: Many-to-One
   - Explanation: Each product is assigned to one manufacturer, but a manufacturer can produce many products.

   - In the product table, manufacturer_id is a foreign key that links back to the manufacturer table.

 
2. **product (M) ↔ (1) brand**: Many-to-One
   - Explanation: Each product belongs to a single brand, but a brand can have many products.

   - In the product table, brand_id is a foreign key that links back to the brand table.

3. **product (M) ↔ (1) subcategory**: Many-to-One
   - Explanation: Each product is assigned to one subcategory, but a subcategory can have many products.

   - In the product table, subcategory_id is a foreign key that links back to the subcategory table. 

4. **subcategory (M) ↔ (1) category**: Many-to-One
   - Explanation: Each subcategory belongs to one category, and a category can have many subcategories.

   - In the subcategory table, category_id is a foreign key that links back to the category table.

5. **product (1) ↔ (M) inventory**: One-to-Many 
   - Explanation: Each product has separate stock entries per store. A product can have multiple inventory entries across various stores,         but each inventory entry belongs to one product.

   - In the inventory table, product_id is a foreign key that links back to the product table.

6. **inventory (M) ↔ (1) store**: Many-to-One
   - Explanation: A store can have inventory for many products, but each inventory record refers to one store.

   - In the inventory table, store_id is a foreign key that links back to the store table.

7. **product (1) ↔ (M) graduated_price**: One-to-Many
   - Explanation: A product can have multiple graduated prices based on different quantity ranges, but each graduated price refers to one         product. 

   - In the graduated_price table, product_id is a foreign key that links back to the product table.

8. **customer (1) ↔ (M) customer_order**: One-to-Many
   - Explanation: One customer can place multiple orders, but each order belongs to one customer.

   - In the customer_order table, customer_id is a foreign key that links back to the customer table.

9. **customer_order (1) ↔ (M) order_item**: One-to-Many
   - Explanation: One order can have many order items, but each order item is part of only one order.

   - In the order_item table, order_id is a foreign key that links back to the customer_order table.

10. **product (M) ↔ (M) order_item**: Many-to-Many 
   - Explanation: A product can be part of many orders, and an order can have many products.

   - In the order_item table, product_id is a foreign key that links back to the product table, and order_id links back to the Order table.

11. **manufacturer (M) ↔ (1) country**: Many-to-One
   - Explanation: A country can have multiple manufacturers, but each manufacturer is linked to one country.

   - In the manufacturer table, country_code is a foreign key that links back to the country table.

12. **store (M) ↔ (1) country**: Many-to-One
   - Explanation: A country can have multiple stores, but each store is located in one country.

   - In the store table, country_code is a foreign key that links back to the country table.

13. **customer_order (M) ↔ (1) country**: Many-to-One
   - Explanation: A country can have multiple orders, but each order is linked to one country.

   - In the customer_order table, country_code is a foreign key that links back to the country table.


14. **product (1) ↔ (M) product_description**: One-to-Many
   - Explanation: One product can have many descriptions in different languages, but each description is linked to one product.

   - In the product_description table, product_id is a foreign key that links back to the product table.

15. **product (1) ↔ (M) review_rating**: One-to-Many
   - Explanation: One product can have many reviews, but each review belongs to one product.

   - In the review_rating table, product_id is a foreign key that links back to the product table.
   
16. **customer(1) ↔ (M) review_rating**: One-to-Many (Unique: customer_id, product_id)
   - Explanation: A customer can leave multiple reviews (one for each product), but the combination of customer_id and product_id                 should be unique, meaning a customer can only review a product once.

   - In the review_rating table, customer_id is a foreign key that links back to the customer table, and product_id is a foreign key             that links back to the product table.

17. **customer (1) ↔ (1) shopping_cart**: One-to-One (nullable for guests)
   - Explanation: Each customer can have one shopping cart, and each shopping cart is associated with one customer. If a guest, the             customer_id is nullable.

   - In the shopping_cart table, customer_id is a foreign key that links back to the customer table.

18. **shopping_cart (1) ↔ (M) cart_item**: One-to-Many
   - Explanation: One shopping cart can have many items, but each cart item belongs to one shopping cart.

   - In the cart_item table, cart_id is a foreign key that links back to the shopping_cart table.

19. **product (M) ↔ (M) cart_item**: Many-to-Many
   - Explanation: A product can be in many shopping carts, and a shopping cart can have many products.

   - In the cart_item table, product_id is a foreign key that links back to the product table, and cart_id links back to the shopping_cart        table.


### Summary of Relationships:

=> One-to-Many (1:M) Relationships:
   1. product ↔ manufacturer
   2. product ↔ brand
   3. product ↔ subcategory
   4. subcategory ↔ category
   5. product ↔ inventory
   6. inventory ↔ store
   7. product ↔ graduated_price
   8. customer ↔ order
   9. order ↔ order_item
   10. product ↔ product_description
   11. product ↔ review_rating
   12. customer ↔ review_rating
   13. customer ↔ shopping_cart
   14. shopping_cart ↔ cart_item

=> Many-to-Many (M:M) Relationships:
   1. product ↔ order_item
   2. product ↔ cart_item

=> Many-to-One (M:1) Relationships:
   1. manufacturer ↔ country (M:1)
   2. store ↔ country
   3. customer_order ↔ country

=> One-to-One (1:1) Relationships:
   1. customer ↔ shopping_cart (nullable for guests)


## Notes:

* Guest Orders Supported
   - Customers can place orders without an account (customer_id is nullable).
   - Only the password is nullable:
      - Registered customers have passwords, while guests do not.
      -Guests still need to provide essential information (e.g., name, email, delivery address) to complete an order.

* Review System
   - Customers can leave reviews anonymously (customer_id is nullable in review_rating).

* Shopping Cart & Order Process
   - Both registered users and guests can add multiple products to their cart before ordering.
   - order includes order_date for better tracking.
   - Junction Tables:
      - cart_item links product and shopping_cart (many-to-many).
      - order_item links product and order (many-to-many).

* Database Performance and Integrity
   - Avoids duplicate items: order_item uses a composite key (order_id, product_id).
   - Unique constraint: Customer emails must be unique to prevent duplicate accounts.
   - Fixed values: order_status and payment_method are stored as ENUMs for consistency and space efficiency.

* Country Table
   - International Shipping (Future-Proofing)
      - If the store expands beyond Germany, country_code in order allows easy tracking of international orders.
      - Standardization of address formats.

* Data Structure Optimization
   - category and subcategory are normalized for a cleaner database structure.
   - country entity replaces redundant delivery_country fields.
   - shipping_cost is stored at the order level for clarity.

* Multi-language Product Description Optimization
   - product_description is stored separately to prevent duplication.
 
![ER Diagram](Images/ER_diagram.png)
