-- Database Table Partitioning Implementation
-- Objective: Optimize queries on large Booking table by partitioning based on start_date

-- ============================================
-- 1. CREATE PARTITIONED BOOKING TABLE
-- ============================================

-- Drop existing table if it exists
DROP TABLE IF EXISTS Booking CASCADE;

-- Create the main partitioned table
CREATE TABLE Booking (
    booking_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    service_id INTEGER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    booking_status VARCHAR(20) DEFAULT 'confirmed',
    total_amount DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) PARTITION BY RANGE (start_date);

-- ============================================
-- 2. CREATE INDIVIDUAL PARTITIONS
-- ============================================

-- Create partition for 2022 bookings
CREATE TABLE Booking_2022 PARTITION OF Booking
    FOR VALUES FROM ('2022-01-01') TO ('2023-01-01');

-- Create partition for 2023 bookings
CREATE TABLE Booking_2023 PARTITION OF Booking
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

-- Create partition for 2024 bookings
CREATE TABLE Booking_2024 PARTITION OF Booking
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

-- Create partition for 2025 bookings
CREATE TABLE Booking_2025 PARTITION OF Booking
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

-- Create partition for 2026 bookings
CREATE TABLE Booking_2026 PARTITION OF Booking
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

-- Create default partition for dates outside the defined ranges
CREATE TABLE Booking_default PARTITION OF Booking DEFAULT;

-- ============================================
-- 3. CREATE INDEXES ON PARTITIONED TABLE
-- ============================================

-- Create indexes on the main partitioned table
CREATE INDEX idx_booking_start_date ON Booking (start_date);
CREATE INDEX idx_booking_user_id ON Booking (user_id);
CREATE INDEX idx_booking_status ON Booking (booking_status);
CREATE INDEX idx_booking_service_id ON Booking (service_id);
CREATE INDEX idx_booking_amount ON Booking (total_amount);

-- Create specific indexes on individual partitions for better performance
CREATE INDEX idx_booking_2022_start_date ON Booking_2022 (start_date);
CREATE INDEX idx_booking_2022_user_status ON Booking_2022 (user_id, booking_status);

CREATE INDEX idx_booking_2023_start_date ON Booking_2023 (start_date);
CREATE INDEX idx_booking_2023_user_status ON Booking_2023 (user_id, booking_status);

CREATE INDEX idx_booking_2024_start_date ON Booking_2024 (start_date);
CREATE INDEX idx_booking_2024_user_status ON Booking_2024 (user_id, booking_status);

CREATE INDEX idx_booking_2025_start_date ON Booking_2025 (start_date);
CREATE INDEX idx_booking_2025_user_status ON Booking_2025 (user_id, booking_status);

CREATE INDEX idx_booking_2026_start_date ON Booking_2026 (start_date);
CREATE INDEX idx_booking_2026_user_status ON Booking_2026 (user_id, booking_status);

-- ============================================
-- 4. INSERT SAMPLE DATA FOR TESTING
-- ============================================

-- Insert sample data across different partitions
INSERT INTO Booking (user_id, service_id, start_date, end_date, booking_status, total_amount) VALUES
-- 2022 data
(1, 101, '2022-01-15', '2022-01-20', 'confirmed', 250.00),
(2, 102, '2022-06-10', '2022-06-15', 'confirmed', 300.00),
(3, 103, '2022-12-20', '2022-12-25', 'cancelled', 180.00),

-- 2023 data
(4, 104, '2023-03-12', '2023-03-18', 'confirmed', 420.00),
(5, 105, '2023-07-05', '2023-07-10', 'pending', 350.00),
(6, 106, '2023-11-22', '2023-11-28', 'confirmed', 280.00),

-- 2024 data
(7, 107, '2024-02-14', '2024-02-18', 'confirmed', 195.00),
(8, 108, '2024-08-01', '2024-08-05', 'confirmed', 480.00),
(9, 109, '2024-12-10', '2024-12-15', 'pending', 320.00),

-- 2025 data
(10, 110, '2025-04-20', '2025-04-25', 'confirmed', 275.00),
(11, 111, '2025-09-15', '2025-09-20', 'confirmed', 390.00);

-- ============================================
-- 5. PERFORMANCE TEST QUERIES
-- ============================================

-- Query 1: Fetch bookings for a specific year (tests partition pruning)
SELECT * FROM Booking 
WHERE start_date >= '2024-01-01' AND start_date < '2025-01-01';

-- Query 2: Fetch bookings for a specific date range within a partition
SELECT * FROM Booking 
WHERE start_date BETWEEN '2024-06-01' AND '2024-12-31'
ORDER BY start_date;

-- Query 3: Fetch bookings across multiple partitions
SELECT * FROM Booking 
WHERE start_date BETWEEN '2023-06-01' AND '2024-06-30'
ORDER BY start_date;

-- Query 4: Aggregate query on partitioned table
SELECT 
    EXTRACT(YEAR FROM start_date) as booking_year,
    COUNT(*) as total_bookings,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as average_booking_value
FROM Booking 
WHERE start_date >= '2022-01-01' 
GROUP BY EXTRACT(YEAR FROM start_date)
ORDER BY booking_year;

-- Query 5: Status-based query across partitions
SELECT 
    booking_status,
    COUNT(*) as status_count,
    SUM(total_amount) as total_amount
FROM Booking 
WHERE start_date >= '2023-01-01'
GROUP BY booking_status
ORDER BY status_count DESC;

-- ============================================
-- 6. EXPLAIN ANALYZE QUERIES FOR PERFORMANCE TESTING
-- ============================================

-- Test partition pruning with EXPLAIN ANALYZE
EXPLAIN ANALYZE SELECT * FROM Booking 
WHERE start_date >= '2024-01-01' AND start_date < '2025-01-01';

-- Test cross-partition query performance
EXPLAIN ANALYZE SELECT * FROM Booking 
WHERE start_date BETWEEN '2023-06-01' AND '2024-06-30';

-- Test aggregate performance across partitions
EXPLAIN ANALYZE SELECT 
    EXTRACT(YEAR FROM start_date) as booking_year,
    COUNT(*) as total_bookings
FROM Booking 
WHERE start_date >= '2022-01-01' 
GROUP BY EXTRACT(YEAR FROM start_date);

-- ============================================
-- 7. MAINTENANCE PROCEDURES
-- ============================================

-- Add new partition for 2027
CREATE TABLE Booking_2027 PARTITION OF Booking
    FOR VALUES FROM ('2027-01-01') TO ('2028-01-01');

-- Create indexes on new partition
CREATE INDEX idx_booking_2027_start_date ON Booking_2027 (start_date);
CREATE INDEX idx_booking_2027_user_status ON Booking_2027 (user_id, booking_status);

-- Drop old partition (example for archiving old data)
-- DROP TABLE Booking_2022;  -- Uncomment when ready to archive

-- ============================================
-- 8. MONITORING AND STATISTICS QUERIES
-- ============================================

-- Check partition information
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size,
    pg_total_relation_size(schemaname||'.'||tablename) as size_bytes
FROM pg_tables 
WHERE tablename LIKE 'booking_%'
ORDER BY size_bytes DESC;

-- Check row counts per partition
SELECT 
    'Booking_2022' as partition_name, 
    (SELECT COUNT(*) FROM Booking_2022) as row_count
UNION ALL
SELECT 
    'Booking_2023', 
    (SELECT COUNT(*) FROM Booking_2023)
UNION ALL
SELECT 
    'Booking_2024', 
    (SELECT COUNT(*) FROM Booking_2024)
UNION ALL
SELECT 
    'Booking_2025', 
    (SELECT COUNT(*) FROM Booking_2025)
UNION ALL
SELECT 
    'Booking_2026', 
    (SELECT COUNT(*) FROM Booking_2026)
ORDER BY partition_name;

-- Check partition constraints
SELECT 
    schemaname,
    tablename,
    pg_get_expr(pg_class.relpartbound, pg_class.oid) as partition_bounds
FROM pg_tables 
JOIN pg_class ON pg_class.relname = tablename
WHERE tablename LIKE 'booking_%' AND tablename != 'booking'
ORDER BY tablename;

-- ============================================
-- 9. PERFORMANCE COMPARISON SETUP
-- ============================================

-- Create non-partitioned table for comparison
CREATE TABLE Booking_NonPartitioned (
    booking_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    service_id INTEGER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    booking_status VARCHAR(20) DEFAULT 'confirmed',
    total_amount DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create standard index on non-partitioned table
CREATE INDEX idx_booking_nonpart_start_date ON Booking_NonPartitioned (start_date);
CREATE INDEX idx_booking_nonpart_user_id ON Booking_NonPartitioned (user_id);

-- Insert same data into non-partitioned table
INSERT INTO Booking_NonPartitioned (user_id, service_id, start_date, end_date, booking_status, total_amount)
SELECT user_id, service_id, start_date, end_date, booking_status, total_amount 
FROM Booking;

-- ============================================
-- 10. PERFORMANCE COMPARISON QUERIES
-- ============================================

-- Compare query performance between partitioned and non-partitioned tables
-- Run these with EXPLAIN ANALYZE to see the difference

-- Test 1: Date range query on partitioned table
EXPLAIN ANALYZE SELECT * FROM Booking 
WHERE start_date >= '2024-01-01' AND start_date < '2025-01-01';

-- Test 2: Same query on non-partitioned table
EXPLAIN ANALYZE SELECT * FROM Booking_NonPartitioned 
WHERE start_date >= '2024-01-01' AND start_date < '2025-01-01';

-- Test 3: Cross-partition aggregate on partitioned table
EXPLAIN ANALYZE SELECT 
    EXTRACT(YEAR FROM start_date) as year,
    COUNT(*) as bookings
FROM Booking 
WHERE start_date >= '2022-01-01' 
GROUP BY EXTRACT(YEAR FROM start_date);

-- Test 4: Same aggregate on non-partitioned table
EXPLAIN ANALYZE SELECT 
    EXTRACT(YEAR FROM start_date) as year,
    COUNT(*) as bookings
FROM Booking_NonPartitioned 
WHERE start_date >= '2022-01-01' 
GROUP BY EXTRACT(YEAR FROM start_date);

-- ============================================
-- END OF PARTITIONING IMPLEMENTATION
-- ============================================