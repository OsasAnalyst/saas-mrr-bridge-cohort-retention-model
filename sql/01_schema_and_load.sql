-- DATABASE SETUP
CREATE DATABASE mrr_bridge;
USE mrr_bridge;

-- CREATE TABLES
CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    signup_month DATE,
    initial_plan VARCHAR(20)
);

CREATE TABLE subscription_monthly (
    customer_id VARCHAR(20),
    month DATE,
    plan VARCHAR(20),
    mrr INT,
    status ENUM('active', 'canceled'),
    PRIMARY KEY (customer_id, month),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);


SHOW VARIABLES LIKE 'secure_file_priv';


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(customer_id, @signup_month, initial_plan)
SET signup_month = STR_TO_DATE(CONCAT(@signup_month, '-01'), '%Y-%m-%d');


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/subscription_monthly.csv'
INTO TABLE subscription_monthly
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(customer_id, @month, plan, mrr, status)
SET month = STR_TO_DATE(CONCAT(@month, '-01'), '%Y-%m-%d');


SELECT COUNT(*) AS customers_count FROM customers; 

SELECT COUNT(*) AS subscription_rows_count FROM subscription_monthly;