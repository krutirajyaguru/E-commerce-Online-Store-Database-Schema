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

