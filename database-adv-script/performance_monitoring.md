# Database Performance Monitoring and Optimization Guide

## Overview
This guide provides a systematic approach to monitoring and refining database performance through query analysis, bottleneck identification, and optimization strategies.

## Step 1: Performance Monitoring Commands

### MySQL Performance Monitoring

#### Using SHOW PROFILE
```sql
-- Enable profiling
SET profiling = 1;

-- Execute your query
SELECT u.username, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.created_at >= '2024-01-01'
GROUP BY u.id, u.username
ORDER BY order_count DESC;

-- Show profile for the last query
SHOW PROFILE;

-- Show detailed profile with CPU and block IO
SHOW PROFILE CPU, BLOCK IO FOR QUERY 1;
```

#### Using EXPLAIN ANALYZE
```sql
-- Analyze query execution plan
EXPLAIN ANALYZE
SELECT u.username, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.created_at >= '2024-01-01'
GROUP BY u.id, u.username
ORDER BY order_count DESC;
```

#### Using EXPLAIN FORMAT=JSON
```sql
-- Get detailed execution plan in JSON format
EXPLAIN FORMAT=JSON
SELECT p.product_name, SUM(oi.quantity) as total_sold
FROM products p
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.id
WHERE o.order_date BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY p.id, p.product_name
HAVING total_sold > 100
ORDER BY total_sold DESC;
```

### PostgreSQL Performance Monitoring

#### Using EXPLAIN ANALYZE
```sql
-- Basic execution plan analysis
EXPLAIN ANALYZE
SELECT c.customer_name, SUM(o.total_amount) as total_spent
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE o.order_date >= '2024-01-01'
GROUP BY c.id, c.customer_name
ORDER BY total_spent DESC
LIMIT 10;
```

#### Using EXPLAIN with Additional Options
```sql
-- Detailed analysis with buffers and timing
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT p.product_name, AVG(r.rating) as avg_rating
FROM products p
JOIN reviews r ON p.id = r.product_id
WHERE r.created_at >= '2024-01-01'
GROUP BY p.id, p.product_name
HAVING COUNT(r.id) >= 5
ORDER BY avg_rating DESC;
```

## Step 2: Identifying Common Bottlenecks

### Key Metrics to Monitor

#### 1. Query Execution Time
```sql
-- MySQL: Monitor slow queries
SHOW VARIABLES LIKE 'slow_query_log%';
SHOW VARIABLES LIKE 'long_query_time';

-- Enable slow query log
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 1; -- Log queries taking more than 1 second
```

#### 2. Index Usage Analysis
```sql
-- Check index usage (MySQL)
SHOW INDEX FROM orders;

-- Find unused indexes
SELECT 
    t.table_name,
    t.index_name,
    t.column_name
FROM information_schema.statistics t
WHERE t.table_schema = 'your_database'
AND t.index_name NOT IN (
    SELECT DISTINCT index_name 
    FROM information_schema.key_column_usage
    WHERE table_schema = 'your_database'
);
```

#### 3. Table Scan Detection
Look for these indicators in EXPLAIN output:
- **Type: ALL** - Full table scan
- **Type: index** - Full index scan
- **Rows examined >> Rows returned** - Inefficient filtering

### Common Bottleneck Patterns

#### Sequential Scans on Large Tables
```sql
-- Problem query
SELECT * FROM orders WHERE order_date = '2024-06-15';

-- Solution: Add index
CREATE INDEX idx_orders_date ON orders(order_date);
```

#### Inefficient JOINs
```sql
-- Problem: JOIN without proper indexes
SELECT u.username, o.total_amount
FROM users u
JOIN orders o ON u.email = o.customer_email; -- No index on email

-- Solution: Add indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_orders_customer_email ON orders(customer_email);
```

## Step 3: Optimization Strategies

### Index Optimization

#### 1. Single Column Indexes
```sql
-- For WHERE clauses
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_orders_status ON orders(status);

-- For ORDER BY clauses
CREATE INDEX idx_users_created_at ON users(created_at);
```

#### 2. Composite Indexes
```sql
-- For multi-column WHERE conditions
CREATE INDEX idx_orders_status_date ON orders(status, order_date);

-- For GROUP BY with WHERE
CREATE INDEX idx_sales_date_product ON sales(sale_date, product_id);
```

#### 3. Covering Indexes
```sql
-- Include all columns needed in the query
CREATE INDEX idx_orders_covering 
ON orders(customer_id, order_date) 
INCLUDE (total_amount, status);
```

### Query Optimization

#### 1. Rewrite Subqueries as JOINs
```sql
-- Before (slower)
SELECT * FROM products 
WHERE id IN (SELECT product_id FROM order_items WHERE quantity > 10);

-- After (faster)
SELECT DISTINCT p.* 
FROM products p
JOIN order_items oi ON p.id = oi.product_id
WHERE oi.quantity > 10;
```

#### 2. Use LIMIT for Large Result Sets
```sql
-- Add pagination
SELECT * FROM products 
ORDER BY created_at DESC 
LIMIT 20 OFFSET 0;
```

#### 3. Optimize WHERE Conditions
```sql
-- Use selective conditions first
SELECT * FROM orders 
WHERE status = 'pending' 
  AND order_date >= '2024-01-01'
  AND total_amount > 100;
```

### Schema Optimization

#### 1. Normalize Related Data
```sql
-- Separate frequently accessed columns
CREATE TABLE user_profiles (
    user_id INT PRIMARY KEY,
    bio TEXT,
    preferences JSON,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

#### 2. Denormalize for Read Performance
```sql
-- Add calculated columns for frequent aggregations
ALTER TABLE products ADD COLUMN total_sales INT DEFAULT 0;
ALTER TABLE products ADD COLUMN avg_rating DECIMAL(3,2) DEFAULT 0;

-- Update with triggers or scheduled jobs
```

## Step 4: Implementation and Testing

### Performance Testing Script

#### Before Optimization
```sql
-- Record baseline performance
SET @start_time = NOW(6);

-- Your query here
SELECT u.username, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.created_at >= '2024-01-01'
GROUP BY u.id, u.username
ORDER BY order_count DESC;

SET @end_time = NOW(6);
SELECT TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) as execution_time_microseconds;
```

#### After Optimization
```sql
-- Add optimized indexes
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_orders_user_id ON orders(user_id);

-- Test the same query
SET @start_time = NOW(6);

SELECT u.username, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.created_at >= '2024-01-01'
GROUP BY u.id, u.username
ORDER BY order_count DESC;

SET @end_time = NOW(6);
SELECT TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) as execution_time_microseconds;
```

### Monitoring Queries

#### System Performance Monitoring
```sql
-- MySQL: Check current processes
SHOW PROCESSLIST;

-- Check index usage statistics
SELECT 
    table_name,
    index_name,
    cardinality,
    sub_part,
    packed,
    null_field,
    index_type
FROM information_schema.statistics
WHERE table_schema = 'your_database'
ORDER BY table_name, seq_in_index;
```

#### Query Performance Tracking
```sql
-- Create a performance log table
CREATE TABLE query_performance_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    query_hash VARCHAR(64),
    query_text TEXT,
    execution_time_ms INT,
    rows_examined INT,
    rows_returned INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Step 5: Reporting Improvements

### Performance Metrics Template

#### Before vs After Comparison
```sql
-- Generate performance report
SELECT 
    'Before Optimization' as phase,
    1250 as avg_execution_time_ms,
    50000 as rows_examined,
    100 as rows_returned,
    500 as efficiency_ratio
UNION ALL
SELECT 
    'After Optimization' as phase,
    85 as avg_execution_time_ms,
    150 as rows_examined,
    100 as rows_returned,
    1.5 as efficiency_ratio;
```

### Key Performance Indicators

1. **Query Execution Time**: Target 90% reduction
2. **Rows Examined**: Minimize scanning unnecessary rows
3. **Index Hit Ratio**: Aim for >95% index usage
4. **CPU Usage**: Monitor database server load
5. **Memory Usage**: Check buffer pool efficiency

## Best Practices

### Regular Maintenance
```sql
-- MySQL: Optimize tables regularly
OPTIMIZE TABLE orders, products, users;

-- PostgreSQL: Vacuum and analyze
VACUUM ANALYZE orders;
VACUUM ANALYZE products;
```

### Index Maintenance
```sql
-- Check for duplicate indexes
SELECT 
    table_name,
    GROUP_CONCAT(index_name) as duplicate_indexes,
    column_name
FROM information_schema.statistics
WHERE table_schema = 'your_database'
GROUP BY table_name, column_name
HAVING COUNT(*) > 1;
```

### Monitoring Automation
```sql
-- Create automated monitoring views
CREATE VIEW slow_queries AS
SELECT 
    query_text,
    AVG(execution_time_ms) as avg_time,
    COUNT(*) as frequency,
    MAX(created_at) as last_run
FROM query_performance_log
WHERE execution_time_ms > 1000
GROUP BY query_text
ORDER BY avg_time DESC;
```

## Conclusion

Regular database performance monitoring and optimization is crucial for maintaining application responsiveness. Use the monitoring commands to identify bottlenecks, implement appropriate indexes and schema changes, and measure the improvements to ensure your database continues to perform efficiently as your data grows.