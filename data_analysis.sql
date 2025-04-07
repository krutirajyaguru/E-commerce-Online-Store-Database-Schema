/* ====================================================================
    -- Exercise: 1

    Write a SELECT command that displays all products that:
    additionally:
    o Sort the results by price
    o output the average customer rating for each product.
    o in the category "Electronics" or "Household"
    o from a manufacturer based in Germany
    o and a price below 50€
    o and a stock of at least 10 items in at least one store in Berlin
    Make sure to create just one SELECT command
-- ====================================================================*/

SELECT 
    p.product_id,
    p.name AS product_name,   -- Product name
    p.base_price,             -- Base price of the product
    COALESCE(AVG(rr.rating), 0) AS avg_rating,   -- Average rating; default to 0 if no reviews
    s.city AS store_city,     -- Store location (must be Berlin)
    co.country_name AS manufacturer_country -- Manufacturer's country (Germany)
FROM 
    product p
JOIN 
    subcategory sc ON p.subcategory_id = sc.subcategory_id
JOIN 
    category c ON sc.category_id = c.category_id AND c.name IN ('Electronics', 'Household')
JOIN 
    manufacturer m ON p.manufacturer_id = m.manufacturer_id
JOIN 
    country co ON m.country_code = co.country_code AND co.country_name = 'Germany'
JOIN 
    inventory i ON p.product_id = i.product_id
JOIN 
    store s ON i.store_id = s.store_id AND s.city = 'Berlin'
LEFT JOIN 
    review_rating rr ON p.product_id = rr.product_id
WHERE 
    p.base_price < 50  -- Price filter: products below 50€
GROUP BY 
    p.product_id, p.name, p.base_price, s.city, co.country_name
HAVING 
    MAX(i.store_stock_level) >= 10  -- Ensure at least 10 units in stock at a Berlin store
ORDER BY 
    p.base_price;   -- Sort products by price in ascending order


/* ===========================================================================
    -- Exercise:2
    Calculate the total turnover for all orders with the status "completed" 
    in the last month per payment method
-- ===========================================================================*/

-- =============================
-- Simple Query (Basic Approach)
-- =============================

SELECT 
    co.payment_method,  -- The payment method used for each order
    -- Calculate the total turnover per payment method by multiplying quantity with adjusted price
    -- Adjusted price considers the discount applied to the unit price
    SUM(oi.quantity * (oi.unit_price - (oi.unit_price * oi.discount / 100))) AS total_turnover 
FROM 
    customer_order co
JOIN 
    order_item oi ON co.order_id = oi.order_id  -- Join to link order items to the orders
WHERE 
    co.order_status = 'completed'  -- Filter orders that are marked as 'completed'
    AND co.order_date >= '2025-03-01'  -- Restrict to orders placed in March 2025
    AND co.order_date < '2025-04-01'  -- Ensure the order date is within the range of March 2025
GROUP BY 
    co.payment_method  -- Group the results by payment method to get turnover per payment method
ORDER BY 
    total_turnover DESC;  -- Sort the results in descending order of total turnover

-- =============================
-- Optimized Query (Using CTE)
-- =============================

-- Define a Common Table Expression (CTE) to pre-calculate adjusted prices for each order item
WITH DiscountedPrices AS (
    SELECT 
        oi.order_id,  -- The unique order ID
        oi.product_id,  -- The unique product ID within the order
        oi.quantity,  -- The quantity of the product ordered
        oi.unit_price,  -- The unit price of the product
        oi.discount,  -- The discount applied to the unit price
        -- Calculate the adjusted price considering the discount
        oi.quantity * (oi.unit_price - (oi.unit_price * oi.discount / 100)) AS adjusted_price  
    FROM 
        order_item oi  -- Work with the order_item table
)
-- Query the orders and aggregate turnover per payment method
SELECT 
    co.payment_method,  -- The payment method used for each order
    -- Calculate the total turnover by summing the adjusted prices from the CTE
    SUM(dp.adjusted_price) AS total_turnover
FROM 
    customer_order co
JOIN 
    DiscountedPrices dp ON co.order_id = dp.order_id  -- Join the CTE to the orders table to get adjusted prices
WHERE 
    co.order_status = 'completed'  -- Only consider completed orders
    AND co.order_date >= '2025-03-01'  -- Restrict to orders placed in March 2025
    AND co.order_date < '2025-04-01'  -- Ensure the order date is within the range of March 2025
GROUP BY 
    co.payment_method  -- Group by payment method to get turnover per payment method
ORDER BY 
    total_turnover DESC;  -- Sort the results by total turnover in descending order


/*  ===========================================================================
    -- Exercise 3: 
    Find all customers who have placed more than 3 orders in the last 
    6 months and live in Berlin.
-- ===========================================================================*/

-- =============================
-- Simple Query (Basic Approach)
-- =============================

SELECT 
    c.customer_id,        -- Unique identifier for the customer
    c.first_name,         -- First name of the customer
    c.last_name,          -- Last name of the customer
    c.email,              -- Email address of the customer
    COUNT(o.order_id) AS order_count  -- Count the number of orders placed by the customer
FROM 
    customer c
JOIN 
    customer_order o ON c.customer_id = o.customer_id  -- Join customer table with orders based on customer_id
WHERE 
    o.delivery_city = 'Berlin'  -- Filter orders that were delivered to Berlin
    AND o.order_date >= CURRENT_DATE - INTERVAL '6 months'  -- Restrict orders to the last 6 months from the current date
GROUP BY 
    c.customer_id, c.first_name, c.last_name, c.email  -- Group the result by customer details
HAVING 
    COUNT(o.order_id) > 3  -- Only include customers who placed more than 3 orders
ORDER BY 
    order_count DESC;  -- Sort the results in descending order of order count (most orders first)

-- =============================
-- Optimized Query (Using CTE)
-- =============================

-- Using a Common Table Expression (CTE) to isolate customers who have placed more than 3 orders
WITH recent_orders AS (
    SELECT 
        customer_id,  
        COUNT(order_id) AS total_orders  -- Count the number of orders per customer
    FROM 
        customer_order
    WHERE 
        order_date >= DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '6 months'  -- Filter orders from the last 6 months
        AND delivery_city = 'Berlin'  -- Ensure orders are delivered in Berlin
    GROUP BY 
        customer_id  
    HAVING 
        COUNT(order_id) > 3  -- Only include customers who have placed more than 3 orders
)

-- Main query to fetch customer details along with their order count
SELECT 
    c.customer_id,       -- Unique identifier for the customer
    c.first_name,        -- First name of the customer
    c.last_name,         -- Last name of the customer
    c.email,             -- Email address of the customer
    ro.total_orders      -- The number of orders placed by the customer (from the CTE)
FROM 
    recent_orders ro
JOIN 
    customer c ON c.customer_id = ro.customer_id  -- Join with the customer table to fetch details

ORDER BY 
    ro.total_orders DESC;  -- Sort by order count in descending order




/* ====================================================================================
    -- Exercise: 4

    Triggers are useful for automatically performing actions on specific table events, 
    such as insertions, updates, or deletions.
    
    Trigger to Update Product Stock When an Order is Placed
    This trigger will ensure that when an order item is added, 
    the stock level in the inventory is reduced accordingly.

    This trigger ensures that stock levels in the inventory table are updated when 
    an order item is placed.

    If the stock goes negative, an exception is raised, ensuring inventory integrity.

-- ====================================================================================*/

-- Create Trigger Function to Update Inventory After Order Item Insertion
CREATE OR REPLACE FUNCTION update_inventory_after_order() 
RETURNS TRIGGER AS $$
BEGIN
    -- Reduce stock in the inventory based on order quantity
    UPDATE inventory
    SET store_stock_level = store_stock_level - NEW.quantity
    WHERE product_id = NEW.product_id
    AND store_id = (SELECT store_id FROM customer_order WHERE order_id = NEW.order_id);
    
    -- Prevent stock from going negative
    IF (SELECT store_stock_level FROM inventory WHERE product_id = NEW.product_id AND store_id = NEW.store_id) < 0 THEN
        RAISE EXCEPTION 'Insufficient stock for product ID %', NEW.product_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger on order_item Insert to Fire the Function
CREATE TRIGGER update_inventory_trigger
AFTER INSERT ON order_item
FOR EACH ROW
EXECUTE FUNCTION update_inventory_after_order();

/* ====================================================================================
    -- Exercise: 5
    Trigger to Set Order Status to Shipped Once All Items Are Shipped

    -- Create Trigger to Update Order Status to 'Shipped' After All Items Are Shippe
    This trigger automatically updates the order_status in customer_order to 'shipped' once 
    all items in an order are marked as shipped.


-- ====================================================================================*/

CREATE OR REPLACE FUNCTION update_order_status_to_shipped() 
RETURNS TRIGGER AS $$
BEGIN
    -- Check if all order items have been shipped
    IF (SELECT COUNT(*) FROM order_item oi WHERE oi.order_id = NEW.order_id AND oi.status <> 'shipped') = 0 THEN
        UPDATE customer_order
        SET order_status = 'shipped'
        WHERE order_id = NEW.order_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger on order_item Update to Fire the Function
CREATE TRIGGER update_order_status_trigger
AFTER UPDATE ON order_item
FOR EACH ROW
WHEN (NEW.status = 'shipped')
EXECUTE FUNCTION update_order_status_to_shipped();

/* ====================================================================================
    -- Exercise: 6
    Trigger to Set Order Status to ‘Completed’ After Payment is Received
    This trigger will automatically update the order status to "completed" once payment has been successfully made.
    This trigger ensures that when payment is received (i.e., order_status becomes 'in_progress'), it automatically 
    updates the order status to 'completed'.

-- ====================================================================================*/

-- Create Trigger Function to Update Order Status After Payment
CREATE OR REPLACE FUNCTION update_order_status_to_completed()
RETURNS TRIGGER AS $$
BEGIN
    -- Update the order status to 'completed' when payment is made
    UPDATE customer_order
    SET order_status = 'completed'
    WHERE order_id = NEW.order_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger on customer_order Update to Fire the Function
CREATE TRIGGER payment_received_trigger
AFTER UPDATE ON customer_order
FOR EACH ROW
WHEN (NEW.payment_method IS NOT NULL AND NEW.order_status = 'in_progress')
EXECUTE FUNCTION update_order_status_to_completed();

/* ====================================================================================
    -- Exercise: 7
    Recursive queries are useful for hierarchical data structures like categories and subcategories.

    Query to Retrieve All Subcategories for a Given Category (Recursive CTE)
    This recursive query generates a hierarchy of categories and subcategories starting from a specific category (in this case, category with category_id = 1).

    It uses a WITH RECURSIVE CTE to perform the recursive join and retrieve subcategories at various levels.

-- ====================================================================================*/

WITH RECURSIVE category_hierarchy AS (
    SELECT category_id, name, 1 AS level
    FROM category
    WHERE category_id = 1  -- Start from category with ID 1
    UNION ALL
    SELECT c.category_id, c.name, ch.level + 1
    FROM category c
    JOIN subcategory s ON c.category_id = s.category_id
    JOIN category_hierarchy ch ON s.category_id = ch.category_id
)
SELECT * FROM category_hierarchy;


/* ====================================================================================
    -- Exercise: 8
    Stored procedures help encapsulate complex logic that can be executed with a single call.

    Procedure to Calculate Total Order Price

    This stored procedure calculates the total price for an order, factoring in discounts and shipping costs.

    The total_price is returned after the calculation.
-- ====================================================================================*/

-- Create Procedure to Calculate the Total Price of an Order Including Shipping
CREATE OR REPLACE PROCEDURE calculate_total_order_price(
    IN p_order_id INT,
    OUT total_price DECIMAL
) AS $$
BEGIN
    -- Calculate the sum of all item prices in the order, including discounts
    SELECT SUM((oi.unit_price - (oi.unit_price * oi.discount / 100)) * oi.quantity) + o.shipping_cost
    INTO total_price
    FROM order_item oi
    JOIN customer_order o ON oi.order_id = o.order_id
    WHERE oi.order_id = p_order_id;
    
    -- Return the calculated total price
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- Example usage of the stored procedure
-- CALL calculate_total_order_price(1, total_order_price);

/* ====================================================================================
    -- Exercise: 9
    Stored Procedures for Reporting
    Procedure to Retrieve Total Sales Per Store
    This stored procedure calculates the total sales for a specific store by summing the sales across all order_item entries.

    The store_id is passed as a parameter, and the total sales value is returned.

-- ====================================================================================*/

-- Create Procedure to Get Total Sales for a Specific Store
CREATE OR REPLACE PROCEDURE total_sales_per_store(
    IN p_store_id INT,
    OUT total_sales DECIMAL
) AS $$
BEGIN
    -- Calculate total sales for the given store
    SELECT SUM(oi.quantity * oi.unit_price) INTO total_sales
    FROM order_item oi
    JOIN customer_order co ON oi.order_id = co.order_id
    JOIN inventory i ON oi.product_id = i.product_id
    WHERE i.store_id = p_store_id;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- Example usage
-- CALL total_sales_per_store(1, total_sales);


/* ====================================================================================
    -- Exercise: 10
    Views are useful to simplify complex queries, providing a virtual table that can be queried like a regular table.

    View to Get Product Information with Brand, Manufacturer, and Category


    This view combines multiple tables (product, brand, manufacturer, subcategory, and category) to provide detailed product information.

    It simplifies queries that need to retrieve product information along with related details.
-- ====================================================================================*/

-- Create View to Get Detailed Product Information
CREATE OR REPLACE VIEW product_details AS
SELECT 
    p.product_id,
    p.name AS product_name,
    p.base_price,
    p.total_stock_level,
    b.name AS brand_name,
    m.name AS manufacturer_name,
    c.name AS category_name,
    sc.name AS subcategory_name
FROM product p
JOIN brand b ON p.brand_id = b.brand_id
JOIN manufacturer m ON p.manufacturer_id = m.manufacturer_id
JOIN subcategory sc ON p.subcategory_id = sc.subcategory_id
JOIN category c ON sc.category_id = c.category_id;

/* ====================================================================================
    -- Exercise: 11
    View to Show Customer Orders and Item Details

    -- Create View to Get Detailed Customer Orders with Product Informatio
    This view combines order data with product information and calculates the total price for each order item, factoring in any discounts.

    By using this view, you can easily retrieve detailed information about each order, including the customer, product, and pricing.

-- ====================================================================================*/

CREATE OR REPLACE VIEW detailed_customer_orders AS
SELECT 
    co.order_id,
    co.customer_id,
    co.order_date,
    co.order_status,
    co.payment_method,
    oi.product_id,
    p.name AS product_name,
    oi.quantity,
    oi.unit_price,
    oi.discount,
    (oi.unit_price * oi.quantity - (oi.unit_price * oi.quantity * oi.discount / 100)) AS total_price
FROM customer_order co
JOIN order_item oi ON co.order_id = oi.order_id
JOIN product p ON oi.product_id = p.product_id;

/* ====================================================================================
    -- Exercise: 12
    Materialized Views for Performance Optimization
    If your system requires frequent querying of certain reports, you can use materialized views for performance optimization, as they store the results of a query physically.

    Create Materialized View for Popular Products
    This materialized view stores the total quantity sold for each product, and it can be refreshed periodically to keep the data up to date.

    Using this materialized view allows for faster access to popular product data, improving performance for large datasets.

-- ====================================================================================*/

-- Create Materialized View for Popular Products Based on Sales Volume
CREATE MATERIALIZED VIEW popular_products AS
SELECT 
    p.product_id,
    p.name AS product_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM order_item oi
JOIN product p ON oi.product_id = p.product_id
GROUP BY p.product_id
ORDER BY total_quantity_sold DESC;

-- Refresh Materialized View (can be scheduled periodically)
REFRESH MATERIALIZED VIEW popular_products;

/* ====================================================================================
    -- Exercise: 13
    Window functions are powerful for running calculations across sets of rows related to the current row, without needing to group the data.

    Window Function to Calculate Rank of Products by Total Sales

    This query uses the RANK() window function to rank products based on their total sales, which is calculated by multiplying the quantity ordered by the unit price for each product.

    The ORDER BY clause within the OVER defines how the rank is determined.
-- ====================================================================================*/

-- Create Window Function to Rank Products by Total Sales
SELECT 
    p.product_id,
    p.name AS product_name,
    SUM(oi.quantity * oi.unit_price) AS total_sales,
    RANK() OVER (ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS sales_rank
FROM order_item oi
JOIN product p ON oi.product_id = p.product_id
GROUP BY p.product_id
ORDER BY sales_rank;


/* ====================================================================================
    -- Exercise: 14
    Find All Customers Who Have Ordered More Than 5 Products

    -- Query to Find Customers Who Ordered More Than 5 Products
    This query retrieves customers who have ordered more than 5 different products by counting the products in the order_item table.

    The HAVING clause filters the customers based on the total number of products ordered.
-- ====================================================================================*/

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(oi.product_id) AS total_products_ordered
FROM customer_order co
JOIN order_item oi ON co.order_id = oi.order_id
JOIN customer c ON co.customer_id = c.customer_id
GROUP BY c.customer_id
HAVING COUNT(oi.product_id) > 5;

/* ====================================================================================
    -- Exercise: 15
    Products with Price Changes Based on Quantity Ordered

    -- Query to Get Product Prices Based on Quantity Ordered
    This query calculates the graduated price for products based on the total quantity ordered.

    It retrieves products from graduated_price where the minimum quantity is met by the orders in order_item.
-- ====================================================================================*/


SELECT 
    p.product_id,
    p.name AS product_name,
    gp.min_quantity,
    gp.price AS graduated_price
FROM product p
JOIN graduated_price gp ON p.product_id = gp.product_id
WHERE gp.min_quantity <= (SELECT SUM(quantity) FROM order_item oi WHERE oi.product_id = p.product_id);

/* ====================================================================================
    -- Exercise: 16
    Window Function to Calculate Running Total of Product Sales Across Orders
    This query uses the SUM() window function with OVER (ORDER BY) to calculate a running total of product sales across orders.

    As orders are processed, the running total accumulates and provides insight into how total sales evolve over time.

-- ====================================================================================*/

SELECT 
    oi.product_id,
    p.name AS product_name,
    SUM(oi.quantity * oi.unit_price) AS total_sales,
    SUM(SUM(oi.quantity * oi.unit_price)) OVER (ORDER BY oi.order_id) AS running_total
FROM order_item oi
JOIN product p ON oi.product_id = p.product_id
GROUP BY oi.product_id, p.name, oi.order_id
ORDER BY oi.order_id;

/* ====================================================================================
    -- Exercise: 17
    Query to Rank Products Based on Average Customer Ratings
    This query uses the RANK() window function to rank products by their average customer rating.

    Products with higher ratings will be ranked higher, making it easier to identify top-rated products.

-- ====================================================================================*/

SELECT 
    p.product_id,
    p.name AS product_name,
    AVG(rr.rating) AS average_rating,
    RANK() OVER (ORDER BY AVG(rr.rating) DESC) AS rating_rank
FROM review_rating rr
JOIN product p ON rr.product_id = p.product_id
GROUP BY p.product_id
ORDER BY rating_rank;


/* ====================================================================================
    -- Exercise: 18
    Advanced Query with Aggregation and HAVING Clause
    Query to Retrieve Products with Sales Exceeding a Threshold
    This query calculates the total sales for each product and filters the results using 
    the HAVING clause to show only products that have sold for more than 1000 in total.

-- ====================================================================================*/

SELECT 
    p.product_id,
    p.name AS product_name,
    SUM(oi.quantity * oi.unit_price) AS total_sales
FROM order_item oi
JOIN product p ON oi.product_id = p.product_id
GROUP BY p.product_id
HAVING SUM(oi.quantity * oi.unit_price) > 1000;  -- Only products with total sales > 1000

/* ====================================================================================
    -- Exercise: 19
    ROW_NUMBER(): This window function assigns a unique row number to each row in the result set.

    Query: Assign Row Number to Products Ordered by Total Sales
    The query assigns a unique row number to each product, ordered by the total sales (in descending order). 
    This helps in ranking products based on their sales.

-- ====================================================================================*/

SELECT 
    p.product_id,
    p.name AS product_name,
    SUM(oi.quantity * oi.unit_price) AS total_sales,
    ROW_NUMBER() OVER (ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS row_num
FROM order_item oi
JOIN product p ON oi.product_id = p.product_id
GROUP BY p.product_id
ORDER BY row_num;

/* ====================================================================================
    -- Exercise: 20
    RANK(): This window function assigns ranks to rows, with gaps between ranks when there are ties.

    Query: Rank Products by Total Sales
    The query ranks products by their total sales, and when two products have the same total sales, 
    they receive the same rank with a gap after them (e.g., rank 1, rank 1, rank 3).

-- ====================================================================================*/

SELECT 
    p.product_id,
    p.name AS product_name,
    SUM(oi.quantity * oi.unit_price) AS total_sales,
    RANK() OVER (ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS sales_rank
FROM order_item oi
JOIN product p ON oi.product_id = p.product_id
GROUP BY p.product_id
ORDER BY sales_rank;

/* ====================================================================================
    -- Exercise: 21
    DENSE_RANK(): This window function is similar to RANK(), but it doesn't leave gaps in the rank when there are ties.

    Query: Dense Rank Products by Total Sales
    DENSE_RANK() works similarly to RANK() but does not create gaps in the ranking. If two products have the same sales, 
    they both receive the same rank, and the next rank continues without gaps.

-- ==================================================================================== */

SELECT 
    p.product_id,
    p.name AS product_name,
    SUM(oi.quantity * oi.unit_price) AS total_sales,
    DENSE_RANK() OVER (ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS dense_rank
FROM order_item oi
JOIN product p ON oi.product_id = p.product_id
GROUP BY p.product_id
ORDER BY dense_rank;


/* ====================================================================================
    -- Exercise: 22
    NTILE(): This window function divides the result set into a specified number of groups.

    Query: Divide Products into 4 Quantiles Based on Total Sales
    The query divides products into 4 quartiles based on total sales. 
    Products with the highest sales will be in quartile 1, and the lowest sales will be in quartile 4.

-- ==================================================================================== */

SELECT 
    p.product_id,
    p.name AS product_name,
    SUM(oi.quantity * oi.unit_price) AS total_sales,
    NTILE(4) OVER (ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS sales_quartile
FROM order_item oi
JOIN product p ON oi.product_id = p.product_id
GROUP BY p.product_id
ORDER BY sales_quartile;


/* ====================================================================================
    -- Exercise: 23
    LEAD(): This window function provides access to the next row's value.

    Query: Get Product Sales and Compare with Next Product's Sales
    This query compares the total sales of each product with the next product’s sales. 
    It helps to understand how much the sales of each product differ from the next best seller.

-- ==================================================================================== */

SELECT 
    p.product_id,
    p.name AS product_name,
    SUM(oi.quantity * oi.unit_price) AS total_sales,
    LEAD(SUM(oi.quantity * oi.unit_price)) OVER (ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS next_product_sales
FROM order_item oi
JOIN product p ON oi.product_id = p.product_id
GROUP BY p.product_id
ORDER BY total_sales DESC;
Explanation:


/* ====================================================================================
    -- Exercise: 24
    LAG(): This window function provides access to the previous row's value.

    Query: Compare Each Product's Sales with Previous Product's Sales
    This query compares each product’s total sales with the previous product’s sales. 
    This can highlight which products have gained or lost sales relative to others.

-- ==================================================================================== */

SELECT 
    p.product_id,
    p.name AS product_name,
    SUM(oi.quantity * oi.unit_price) AS total_sales,
    LAG(SUM(oi.quantity * oi.unit_price)) OVER (ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS previous_product_sales
FROM order_item oi
JOIN product p ON oi.product_id = p.product_id
GROUP BY p.product_id
ORDER BY total_sales DESC;


/* ====================================================================================
    -- Exercise: 25
    FIRST_VALUE(): This window function returns the first value in the window frame.

    Query: Get the First Product’s Sales in Each Category
    This query finds the top-selling product in each category by using FIRST_VALUE() to return the 
    first product in each category when ordered by sales.

-- ==================================================================================== */

SELECT 
    p.product_id,
    p.name AS product_name,
    SUM(oi.quantity * oi.unit_price) AS total_sales,
    FIRST_VALUE(p.name) OVER (PARTITION BY sc.category_id ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS top_selling_product_in_category
FROM order_item oi
JOIN product p ON oi.product_id = p.product_id
JOIN subcategory sc ON p.subcategory_id = sc.subcategory_id
GROUP BY p.product_id, sc.category_id
ORDER BY sc.category_id, total_sales DESC;


/* ====================================================================================
    -- Exercise: 26
    LAST_VALUE(): This window function returns the last value in the window frame.

    Query: Get the Last Product’s Sales in Each Category
    This query finds the bottom-selling product in each category by using LAST_VALUE() 
    to return the last product in each category when ordered by sales.

-- ==================================================================================== */

SELECT 
    p.product_id,
    p.name AS product_name,
    SUM(oi.quantity * oi.unit_price) AS total_sales,
    LAST_VALUE(p.name) OVER (PARTITION BY sc.category_id ORDER BY SUM(oi.quantity * oi.unit_price) DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS bottom_selling_product_in_category
FROM order_item oi
JOIN product p ON oi.product_id = p.product_id
JOIN subcategory sc ON p.subcategory_id = sc.subcategory_id
GROUP BY p.product_id, sc.category_id
ORDER BY sc.category_id, total_sales DESC;


/* ====================================================================================
    -- Exercise: 27
    NTH_VALUE(): This window function returns the nth value in the window.

    Query: Get the Third Top-Selling Product in Each Category
    This query uses NTH_VALUE() to find the third highest-selling product in each category based on total sales.

-- ==================================================================================== */

SELECT 
    p.product_id,
    p.name AS product_name,
    SUM(oi.quantity * oi.unit_price) AS total_sales,
    NTH_VALUE(p.name, 3) OVER (PARTITION BY sc.category_id ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS third_top_selling_product_in_category
FROM order_item oi
JOIN product p ON oi.product_id = p.product_id
JOIN subcategory sc ON p.subcategory_id = sc.subcategory_id
GROUP BY p.product_id, sc.category_id
ORDER BY sc.category_id, total_sales DESC;


/* ====================================================================================
    -- Exercise: 28
    Aggregate Window Functions
    Query: Get Total Sales and Average Sales Per Product
    This query calculates both the total sales for each product and the average sales per product using the AVG() window function.

-- ==================================================================================== */

SELECT 
    p.product_id,
    p.name AS product_name,
    SUM(oi.quantity * oi.unit_price) AS total_sales,
    AVG(oi.quantity * oi.unit_price) OVER (PARTITION BY p.product_id) AS avg_sales_per_product
FROM order_item oi
JOIN product p ON oi.product_id = p.product_id
GROUP BY p.product_id
ORDER BY total_sales DESC;


/* ====================================================================================
    -- Exercise: 29
    CUME_DIST(): (Cumulative Distribution) This window function is similar to RANK(), but it doesn't leave gaps in the rank when there are ties.
    Purpose: Calculates the relative rank of a row within a group of rows, as a percentage of the total number of rows.

    Use case: To calculate how far a particular row is from the bottom of a set of rows.

    Example: Calculate the cumulative distribution of product sales.
    CUME_DIST() returns the cumulative distribution (from 0 to 1) of each product's total sales, which helps you see the relative rank of each product compared to others. A higher CUME_DIST() value indicates a higher relative rank.

-- ==================================================================================== */

SELECT 
    p.product_id,
    p.name AS product_name,
    SUM(oi.quantity * oi.unit_price) AS total_sales,
    CUME_DIST() OVER (ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS sales_cume_dist
FROM order_item oi
JOIN product p ON oi.product_id = p.product_id
GROUP BY p.product_id
ORDER BY sales_cume_dist;


/* ====================================================================================
    -- Exercise: 30
    PERCENT_RANK(): (Percent Rank) 
    Purpose: This window function is similar to CUME_DIST(), but it calculates the relative rank as a percentage, excluding the rank of the lowest value.

    Use case: To calculate how each row compares in terms of percentage to others.

    Example: Calculate the percent rank of each product by its total sales.
    PERCENT_RANK() returns the relative percentage rank of each product’s total sales. It helps to understand how each product ranks compared to others in a normalized way.

-- ==================================================================================== */

SELECT 
    p.product_id,
    p.name AS product_name,
    SUM(oi.quantity * oi.unit_price) AS total_sales,
    PERCENT_RANK() OVER (ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS sales_percent_rank
FROM order_item oi
JOIN product p ON oi.product_id = p.product_id
GROUP BY p.product_id
ORDER BY sales_percent_rank;


/* ====================================================================================
    -- Exercise: 31
    MEDIAN(): (Note: Available in some databases like PostgreSQL 15+ or through custom implementations)
    Purpose: This window function Returns the median value of the windowed set. This is not a standard SQL function but is available in some database systems.

    Use case: To find the middle value in a set of ordered data.

    Example: Calculate the median sales price of products.
    MEDIAN() calculates the middle value of the product's unit price for each product. This is particularly useful for identifying outliers in product pricing.

-- ==================================================================================== */

SELECT 
    p.product_id,
    p.name AS product_name,
    MEDIAN(oi.unit_price) OVER (PARTITION BY p.product_id) AS median_unit_price
FROM order_item oi
JOIN product p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.name;


/* ====================================================================================
    -- Exercise: 32
    ARRAY_AGG(): (Array Aggregation) 
    Purpose: This window function aggregates the rows into an array of values.

    Use case: To aggregate data from multiple rows into an array format for further analysis.

    Example: Get an array of all customer emails who have purchased each product.
    ARRAY_AGG() aggregates all customer emails into an array for each product. This allows you to see which customers have bought each product.

-- ==================================================================================== */

SELECT 
    p.product_id,
    p.name AS product_name,
    ARRAY_AGG(c.email) OVER (PARTITION BY p.product_id) AS customer_emails
FROM order_item oi
JOIN product p ON oi.product_id = p.product_id
JOIN customer c ON oi.customer_id = c.customer_id
ORDER BY p.product_id;


/* ====================================================================================
    -- Exercise: 33
    FILTER(): (in aggregate functions)
    Purpose:  This window function allows applying a filter to an aggregate function, helping you get specific results for certain conditions.

    Use case: To calculate aggregates on a subset of data based on conditions.

    Example: Get the sum of sales only for products that have a discount.
    The FILTER() function allows the SUM() aggregate to only sum the sales where the discount is greater than 0. This is useful to isolate certain subsets of data while still using an aggregate function.

-- ==================================================================================== */

SELECT 
    p.product_id,
    p.name AS product_name,
    SUM(oi.quantity * oi.unit_price) FILTER (WHERE oi.discount > 0) AS sales_with_discount
FROM order_item oi
JOIN product p ON oi.product_id = p.product_id
GROUP BY p.product_id
ORDER BY sales_with_discount DESC;


/* ====================================================================================
    -- Exercise: 34
    RANK() with PARTITION BY and ORDER BY:
     Purpose: This window function is similar to the RANK() function but allows partitioning data before applying the ranking function.

    Use case: Ranking data within subsets of data, e.g., ranking products within different categories.

    Example: Rank products within each subcategory by their total sales.
    This query ranks products within each subcategory based on their total sales, so products are ranked independently within each subcategory.

-- ==================================================================================== */

SELECT 
    p.product_id,
    p.name AS product_name,
    SUM(oi.quantity * oi.unit_price) AS total_sales,
    RANK() OVER (PARTITION BY sc.subcategory_id ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS sales_rank_within_subcategory
FROM order_item oi
JOIN product p ON oi.product_id = p.product_id
JOIN subcategory sc ON p.subcategory_id = sc.subcategory_id
GROUP BY p.product_id, sc.subcategory_id
ORDER BY sc.subcategory_id, sales_rank_within_subcategory;


/* ====================================================================================
    -- Exercise: 35
    PERCENTILE_CONT(): (Percentile Contiguous)
    Purpose: This window function Computes a percentile value for a set of values, returning a value corresponding to the percentile within the range of the dataset.

    Use case: To calculate a specific percentile (e.g., 90th percentile) of a distribution.

    Example: Calculate the 90th percentile of sales prices.
    PERCENTILE_CONT(0.9) calculates the 90th percentile of the sales prices. This helps in determining what the top 10% of sales prices are.


-- ==================================================================================== */

SELECT 
    p.product_id,
    p.name AS product_name,
    PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY oi.unit_price) OVER () AS percentile_90_price
FROM order_item oi
JOIN product p ON oi.product_id = p.product_id
ORDER BY percentile_90_price DESC;


/* ====================================================================================
    -- Exercise: 36
    PERCENTILE_DISC(): (Percentile Discrete) 
    Purpose: This window function is PERCENTILE_CONT(), but this function returns the closest discrete value corresponding to the given percentile.

    Use case: To find the discrete value closest to a specific percentile in your data set.

    Example: Calculate the 50th percentile of product prices (median price).
    PERCENTILE_DISC(0.5) calculates the median price for the product prices. Unlike PERCENTILE_CONT(), which returns a value from the dataset, PERCENTILE_DISC() will return the nearest actual value in the data set.

-- ==================================================================================== */

SELECT 
    p.product_id,
    p.name AS product_name,
    PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY oi.unit_price) OVER () AS median_price
FROM order_item oi
JOIN product p ON oi.product_id = p.product_id
ORDER BY median_price DESC;


