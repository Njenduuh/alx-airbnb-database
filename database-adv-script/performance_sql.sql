-- Performance Optimization: Complex Query Analysis
-- File: performance.sql
-- Purpose: Optimize complex queries that retrieve bookings with user, property, and payment details

-- ========================================
-- INITIAL QUERY (Before Optimization)
-- ========================================

-- Complex query retrieving all bookings with user details, property details, and payment details
-- This query demonstrates common performance issues before optimization

SELECT 
    -- Booking information
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status as booking_status,
    b.created_at as booking_created,
    
    -- User information
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.role,
    u.created_at as user_created,
    
    -- Property information  
    p.property_id,
    p.name as property_name,
    p.description,
    p.location,
    p.pricepernight,
    p.created_at as property_created,
    
    -- Host information
    h.user_id as host_id,
    h.first_name as host_first_name,
    h.last_name as host_last_name,
    h.email as host_email,
    h.phone_number as host_phone,
    
    -- Payment information
    pay.payment_id,
    pay.amount,
    pay.payment_date,
    pay.payment_method

FROM Booking b
-- Join with User table for guest details
LEFT JOIN User u ON b.user_id = u.user_id
-- Join with Property table for property details
LEFT JOIN Property p ON b.property_id = p.property_id
-- Join with User table again for host details
LEFT JOIN User h ON p.host_id = h.user_id
-- Join with Payment table for payment details
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id

-- Optional WHERE clause for filtering (commented out for initial analysis)
-- WHERE b.status = 'confirmed'
-- AND b.start_date >= '2024-01-01'
-- AND p.location = 'New York'

ORDER BY b.created_at DESC;

-- ========================================
-- PERFORMANCE ANALYSIS COMMAND
-- ========================================

-- Use EXPLAIN ANALYZE to analyze the initial query performance
EXPLAIN ANALYZE 
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status as booking_status,
    b.created_at as booking_created,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.role,
    u.created_at as user_created,
    p.property_id,
    p.name as property_name,
    p.description,
    p.location,
    p.pricepernight,
    p.created_at as property_created,
    h.user_id as host_id,
    h.first_name as host_first_name,
    h.last_name as host_last_name,
    h.email as host_email,
    h.phone_number as host_phone,
    pay.payment_id,
    pay.amount,
    pay.payment_date,
    pay.payment_method
FROM Booking b
LEFT JOIN User u ON b.user_id = u.user_id
LEFT JOIN Property p ON b.property_id = p.property_id
LEFT JOIN User h ON p.host_id = h.user_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC;

-- ========================================
-- OPTIMIZED QUERY VERSION 1 (Reduced Columns)
-- ========================================

-- Optimization 1: Select only necessary columns to reduce data transfer
SELECT 
    -- Essential booking information only
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status as booking_status,
    
    -- Essential user information only
    u.first_name,
    u.last_name,
    u.email,
    
    -- Essential property information only
    p.name as property_name,
    p.location,
    p.pricepernight,
    
    -- Essential host information only
    h.first_name as host_first_name,
    h.last_name as host_last_name,
    
    -- Essential payment information only
    pay.amount,
    pay.payment_date,
    pay.payment_method

FROM Booking b
INNER JOIN User u ON b.user_id = u.user_id
INNER JOIN Property p ON b.property_id = p.property_id
INNER JOIN User h ON p.host_id = h.user_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id

WHERE b.status IN ('confirmed', 'completed')
AND b.start_date >= CURRENT_DATE - INTERVAL '1 year'

ORDER BY b.created_at DESC
LIMIT 1000;

-- ========================================
-- OPTIMIZED QUERY VERSION 2 (With Indexes and Filtering)
-- ========================================

-- Optimization 2: Add strategic filtering and use indexes effectively
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status as booking_status,
    
    u.first_name,
    u.last_name,
    u.email,
    
    p.name as property_name,
    p.location,
    p.pricepernight,
    
    h.first_name as host_first_name,
    h.last_name as host_last_name,
    
    pay.amount,
    pay.payment_method

FROM Booking b
-- Use INNER JOINs where relationships are required
INNER JOIN User u ON b.user_id = u.user_id
INNER JOIN Property p ON b.property_id = p.property_id
INNER JOIN User h ON p.host_id = h.user_id
-- Keep LEFT JOIN for payments as they might not exist for all bookings
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id

-- Add WHERE clause early to reduce dataset
WHERE b.status = 'confirmed'
AND b.created_at >= CURRENT_DATE - INTERVAL '6 months'
AND p.location IS NOT NULL

-- Use index-friendly ORDER BY
ORDER BY b.created_at DESC
LIMIT 100;

-- ========================================
-- OPTIMIZED QUERY VERSION 3 (Subquery Approach)
-- ========================================

-- Optimization 3: Use subqueries to pre-filter data
WITH recent_bookings AS (
    SELECT booking_id, user_id, property_id, start_date, end_date, 
           total_price, status, created_at
    FROM Booking 
    WHERE status = 'confirmed'
    AND created_at >= CURRENT_DATE - INTERVAL '3 months'
    ORDER BY created_at DESC
    LIMIT 500
),
booking_details AS (
    SELECT 
        rb.booking_id,
        rb.start_date,
        rb.end_date,
        rb.total_price,
        rb.status as booking_status,
        
        u.first_name,
        u.last_name,
        u.email,
        
        p.name as property_name,
        p.location,
        p.pricepernight,
        
        h.first_name as host_first_name,
        h.last_name as host_last_name
        
    FROM recent_bookings rb
    INNER JOIN User u ON rb.user_id = u.user_id
    INNER JOIN Property p ON rb.property_id = p.property_id
    INNER JOIN User h ON p.host_id = h.user_id
)
SELECT 
    bd.*,
    pay.amount,
    pay.payment_method,
    pay.payment_date
FROM booking_details bd
LEFT JOIN Payment pay ON bd.booking_id = pay.booking_id
ORDER BY bd.booking_id DESC;

-- ========================================
-- OPTIMIZED QUERY VERSION 4 (Pagination Approach)
-- ========================================

-- Optimization 4: Implement efficient pagination for large datasets
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    
    u.first_name || ' ' || u.last_name as guest_name,
    u.email as guest_email,
    
    p.name as property_name,
    p.location,
    
    h.first_name || ' ' || h.last_name as host_name,
    
    pay.amount as payment_amount,
    pay.payment_method

FROM Booking b
INNER JOIN User u ON b.user_id = u.user_id
INNER JOIN Property p ON b.property_id = p.property_id  
INNER JOIN User h ON p.host_id = h.user_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id

WHERE b.booking_id > 0  -- Use for cursor-based pagination
AND b.status IN ('confirmed', 'completed')

ORDER BY b.booking_id ASC  -- Use ASC for better index usage
LIMIT 50;

-- ========================================
-- PERFORMANCE COMPARISON QUERIES
-- ========================================

-- Query to measure execution time for initial query
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT COUNT(*) FROM (
    SELECT b.booking_id
    FROM Booking b
    LEFT JOIN User u ON b.user_id = u.user_id
    LEFT JOIN Property p ON b.property_id = p.property_id
    LEFT JOIN User h ON p.host_id = h.user_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
) as initial_query;

-- Query to measure execution time for optimized query
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT COUNT(*) FROM (
    SELECT b.booking_id
    FROM Booking b
    INNER JOIN User u ON b.user_id = u.user_id
    INNER JOIN Property p ON b.property_id = p.property_id
    INNER JOIN User h ON p.host_id = h.user_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
    WHERE b.status = 'confirmed'
    AND b.created_at >= CURRENT_DATE - INTERVAL '6 months'
    LIMIT 100
) as optimized_query;

-- ========================================
-- INDEX RECOMMENDATIONS FOR OPTIMAL PERFORMANCE
-- ========================================

-- These indexes should be created for optimal performance of the above queries
-- (These are references to indexes that should exist from database_index.sql)

/*
Required indexes for optimal performance:
- idx_booking_user_id ON Booking(user_id)
- idx_booking_property_id ON Booking(property_id)  
- idx_booking_status ON Booking(status)
- idx_booking_created_at ON Booking(created_at)
- idx_property_host_id ON Property(host_id)
- idx_payment_booking_id ON Payment(booking_id)
- idx_booking_status_created ON Booking(status, created_at)
*/

-- Additional index for payment optimization
CREATE INDEX IF NOT EXISTS idx_payment_booking_id ON Payment(booking_id);

-- Composite index for booking filtering
CREATE INDEX IF NOT EXISTS idx_booking_status_created ON Booking(status, created_at);