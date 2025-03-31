-- Create ENUM types first
DROP TYPE IF EXISTS order_status CASCADE;
CREATE TYPE order_status AS ENUM ('open', 'in_progress', 'shipped', 'completed', 'canceled');

DROP TYPE IF EXISTS payment_method CASCADE;
CREATE TYPE payment_method AS ENUM ('credit_card', 'paypal', 'prepayment');

-- Table: brand
DROP TABLE IF EXISTS brand CASCADE;
CREATE TABLE brand (
    brand_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- Table: category
DROP TABLE IF EXISTS category CASCADE;
CREATE TABLE category (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- Table: subcategory
DROP TABLE IF EXISTS subcategory CASCADE;
CREATE TABLE subcategory (
    subcategory_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES category(category_id)
);

-- Table: country
DROP TABLE IF EXISTS country CASCADE;
CREATE TABLE country (
    country_code CHAR(2) PRIMARY KEY,
    country_name VARCHAR(255) NOT NULL
);

-- Table: manufacturer
DROP TABLE IF EXISTS manufacturer CASCADE;
CREATE TABLE manufacturer (
manufacturer_id SERIAL PRIMARY KEY,
name VARCHAR(255) NOT NULL,
address TEXT,
country_code CHAR(2),
phone_number VARCHAR(20),
email VARCHAR(255),
CONSTRAINT fk_manufacturer_country FOREIGN KEY (country_code) REFERENCES country(country_code)
);

-- Table: product
DROP TABLE IF EXISTS product CASCADE;
CREATE TABLE product (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    base_price DECIMAL(10, 2) NOT NULL,
    total_stock_level INT NOT NULL,
    manufacturer_id INT,
    subcategory_id INT,
    brand_id INT,
    FOREIGN KEY (manufacturer_id) REFERENCES manufacturer(manufacturer_id),
    FOREIGN KEY (subcategory_id) REFERENCES subcategory(subcategory_id),
    FOREIGN KEY (brand_id) REFERENCES brand(brand_id)
);

-- Table: product_description
DROP TABLE IF EXISTS product_description CASCADE;
CREATE TABLE product_description (
    product_id INT,
    language_code VARCHAR(10),
    description TEXT,
    PRIMARY KEY (product_id, language_code),
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);

-- Table: graduated_price
DROP TABLE IF EXISTS graduated_price CASCADE;
CREATE TABLE graduated_price (
    product_id INT,
    min_quantity INT,
    price DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (product_id, min_quantity),
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);

-- Table: store
DROP TABLE IF EXISTS store CASCADE;
CREATE TABLE store (
    store_id SERIAL PRIMARY KEY,
    store_name VARCHAR(255) NOT NULL,
    store_address VARCHAR(255),
    city VARCHAR(100),
    country_code CHAR(2),
    CONSTRAINT fk_store_country FOREIGN KEY (country_code) REFERENCES country(country_code)
);

-- Table: inventory
DROP TABLE IF EXISTS inventory CASCADE;
CREATE TABLE inventory (
    inventory_id SERIAL PRIMARY KEY,
    product_id INT,
    store_id INT,
    store_stock_level INT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES product(product_id),
    FOREIGN KEY (store_id) REFERENCES store(store_id)
);

-- Table: customer
DROP TABLE IF EXISTS customer CASCADE;
CREATE TABLE customer (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255)
);

-- Table: order
DROP TABLE IF EXISTS customer_order CASCADE;
CREATE TABLE customer_order (
	order_id SERIAL PRIMARY KEY,
    customer_id INT,
    country_code CHAR(2),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    order_status order_status NOT NULL,  -- Use ENUM type here
    payment_method payment_method NOT NULL,  -- Use ENUM type here
    delivery_address TEXT,
	delivery_city VARCHAR(100),
    shipping_cost DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (country_code) REFERENCES country(country_code)
);

-- Table: order_item
DROP TABLE IF EXISTS order_item CASCADE;
CREATE TABLE order_item (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    discount DECIMAL(5, 2) DEFAULT 0,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES customer_order(order_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);

-- Table: review_rating
DROP TABLE IF EXISTS review_rating CASCADE;
CREATE TABLE review_rating (
    review_id SERIAL PRIMARY KEY,
    product_id INT,
    customer_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (customer_id, product_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

-- Table: shopping_cart
DROP TABLE IF EXISTS shopping_cart CASCADE;
CREATE TABLE shopping_cart (
    cart_id SERIAL PRIMARY KEY,
    customer_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

-- Table: cart_item
DROP TABLE IF EXISTS cart_item CASCADE;
CREATE TABLE cart_item (
    cart_id INT,
    product_id INT,
    quantity INT NOT NULL,
    PRIMARY KEY (cart_id, product_id),
    FOREIGN KEY (cart_id) REFERENCES shopping_cart(cart_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);
