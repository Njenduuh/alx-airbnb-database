-- Database Table Partitioning Implementation
-- Objective: Optimize queries on large Booking table by partitioning based on start_date

-- ============================================
-- 1. CREATE ORIGINAL BOOKING TABLE (if not exists)
-- ============================================

CREATE TABLE IF NOT EXISTS Booking (
    booking_id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    service_id INTEGER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    booking_status VARCHAR(20) DEFAULT 'confirmed',
    total_amount DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 2. CREATE PARTITIONED TABLES BY YEAR
-- ============================================

-- Create partition for 2022 bookings
CREATE TABLE IF NOT EXISTS Booking_2022 (
    CHECK (start_date >= '2022-01-01' AND start_date < '2023-01-01')
) INHERITS (Booking);

-- Create partition for 2023 bookings
CREATE TABLE IF NOT EXISTS Booking_2023 (
    CHECK (start_date >= '2023-01-01' AND start_date < '2024-01-01')
) INHERITS (Booking);

-- Create partition for 2024 bookings
CREATE TABLE IF NOT EXISTS Booking_2024 (
    CHECK (start_date >= '2024-01-01' AND start_date < '2025-01-01')
) INHERITS (Booking);

-- Create partition for 2025 bookings
CREATE TABLE IF NOT EXISTS Booking_2025 (
    CHECK (start_date >= '2025-01-01' AND start_date < '2026-01-01')
) INHERITS (Booking);

-- ============================================
-- 3. CREATE INDEXES ON PARTITIONED TABLES
-- ============================================

-- Create indexes on partition tables for better performance
CREATE INDEX IF NOT EXISTS idx_booking_2022_start_date ON Booking_2022(start_date);
CREATE INDEX IF NOT EXISTS idx_booking_2022_user_id ON Booking_2022(user_id);
CREATE INDEX IF NOT EXISTS idx_booking_2022_status ON Booking_2022(booking_status);

CREATE INDEX IF NOT EXISTS idx_booking_2023_start_date ON Booking_2023(start_date);
CREATE INDEX IF NOT EXISTS idx_booking_2023_user_id ON Booking_2023(user_id);
CREATE INDEX IF NOT EXISTS idx_booking_2023_status ON Booking_2023(booking_status);

CREATE INDEX IF NOT EXISTS idx_booking_2024_start_date ON Booking_2024(start_date);
CREATE INDEX IF NOT EXISTS idx_booking_2024_user_id ON Booking_2024(user_id);
CREATE INDEX IF NOT EXISTS idx_booking_2024_status ON Booking_2024(booking_status);

CREATE INDEX IF NOT EXISTS idx_booking_2025_start_date ON Booking_2025(start_date);
CREATE INDEX IF NOT EXISTS idx_booking_2025_user_id ON Booking_2025(user_id);
CREATE INDEX IF NOT EXISTS idx_booking_2025_status ON Booking_2025(booking_status);

-- ============================================
-- 4. CREATE TRIGGER FUNCTION FOR AUTOMATIC PARTITIONING
-- ============================================

CREATE OR REPLACE FUNCTION booking_partition_trigger()
RETURNS TRIGGER AS $$
BEGIN
    -- Route inserts to appropriate partition based on start_date
    IF NEW.start_date >= '2022-01-01' AND NEW.start_date < '2023-01-01' THEN
        INSERT INTO Booking_2022 VALUES (NEW.*);
    ELSIF NEW.start_date >= '2023-01-01' AND NEW.start_date < '2024-01-01' THEN
        INSERT INTO Booking_2023 VALUES (NEW.*);
    ELSIF NEW.start_date >= '2024-01-01' AND NEW.start_date < '2025-01-01' THEN
        INSERT INTO Booking_2024 VALUES (NEW.*);
    ELSIF NEW.start_date >= '2025-01-01' AND NEW.start_date < '2026-01-01' THEN
        INSERT INTO Booking_2025 VALUES (NEW.*);
    ELSE
        RAISE EXCEPTION 'Date out of range. Please create appropriate partition for date: %', NEW.start_date;
    END IF;
    
    RETURN NULL; -- Prevent insertion into master table
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 5. CREATE TRIGGER FOR AUTOMATIC PARTITIONING
-- ============================================

DROP TRIGGER IF EXISTS booking_partition_trigger ON Booking;
CREATE TRIGGER booking_partition_trigger
    BEFORE INSERT ON Booking
    FOR EACH ROW
    EXECUTE FUNCTION booking_partition_trigger();

-- ============================================
-- 6. ENABLE CONSTRAINT EXCLUSION (PostgreSQL)
-- ============================================

-- Enable constraint exclusion for partition pruning
SET constraint_exclusion = partition;

-- ============================================
-- 7. SAMPLE DATA INSERTION (for testing)
-- ============================================

-- Insert sample data into different partitions
INSERT INTO Booking (user_id, service_id, start_date, end_date, booking_status, total_amount) VALUES
(1, 101, '2022-06-15', '2022-06-20', 'confirmed', 250.00),
(2, 102, '2022-08-10', '2022-08-15', 'confirmed', 300.00),
(3, 103, '2023-03-20', '2023-03-25', 'confirmed', 180.00),
(4, 104, '2023-07-12', '2023-07-18', 'pending', 420.00),
(5, 105, '2024-01-05', '2024-01-10', 'confirmed', 350.00),
(6, 106, '2024-09-22', '2024-09-28', 'confirmed', 280.00),
(7, 107, '2025-02-14', '2025-02-18', 'confirmed', 195.00);

-- ============================================
-- 8. PERFORMANCE TEST QUERIES
-- ============================================

-- Query 1: Fetch bookings for a specific year (should use partition pruning)
-- EXPLAIN ANALYZE 
SELECT * FROM Booking 
WHERE start_date >= '2024-01-01' AND start_date < '2025-01-01';

-- Query 2: Fetch bookings for a specific date range within a partition
-- EXPLAIN ANALYZE 
SELECT * FROM Booking 
WHERE start_date BETWEEN '2024-06-01' AND '2024-12-31';

-- Query 3: Fetch bookings across multiple partitions
-- EXPLAIN ANALYZE 
SELECT * FROM Booking 
WHERE start_date BETWEEN '2023-06-01' AND '2024-06-30';

-- Query 4: Aggregate query on partitioned table
-- EXPLAIN ANALYZE 
SELECT 
    EXTRACT(YEAR FROM start_date) as booking_year,
    COUNT(*) as total_bookings,
    SUM(total_amount) as total_revenue
FROM Booking 
WHERE start_date >= '2022-01-01' 
GROUP BY EXTRACT(YEAR FROM start_date)
ORDER BY booking_year;

-- ============================================
-- 9. MAINTENANCE QUERIES
-- ============================================

-- Add new partition for 2026 (example of extending partitions)
CREATE TABLE IF NOT EXISTS Booking_2026 (
    CHECK (start_date >= '2026-01-01' AND start_date < '2027-01-01')
) INHERITS (Booking);

CREATE INDEX IF NOT EXISTS idx_booking_2026_start_date ON Booking_2026(start_date);
CREATE INDEX IF NOT EXISTS idx_booking_2026_user_id ON Booking_2026(user_id);
CREATE INDEX IF NOT EXISTS idx_booking_2026_status ON Booking_2026(booking_status);

-- Update trigger function to include new partition
CREATE OR REPLACE FUNCTION booking_partition_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.start_date >= '2022-01-01' AND NEW.start_date < '2023-01-01' THEN
        INSERT INTO Booking_2022 VALUES (NEW.*);
    ELSIF NEW.start_date >= '2023-01-01' AND NEW.start_date < '2024-01-01' THEN
        INSERT INTO Booking_2023 VALUES (NEW.*);
    ELSIF NEW.start_date >= '2024-01-01' AND NEW.start_date < '2025-01-01' THEN
        INSERT INTO Booking_2024 VALUES (NEW.*);
    ELSIF NEW.start_date >= '2025-01-01' AND NEW.start_date < '2026-01-01' THEN
        INSERT INTO Booking_2025 VALUES (NEW.*);
    ELSIF NEW.start_date >= '2026-01-01' AND NEW.start_date < '2027-01-01' THEN
        INSERT INTO Booking_2026 VALUES (NEW.*);
    ELSE
        RAISE EXCEPTION 'Date out of range. Please create appropriate partition for date: %', NEW.start_date;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 10. UTILITY QUERIES FOR MONITORING
-- ============================================

-- Check partition sizes
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables 
WHERE tablename LIKE 'booking_%'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Check row counts per partition
SELECT 'Booking_2022' as partition_name, COUNT(*) as row_count FROM Booking_2022
UNION ALL
SELECT 'Booking_2023', COUNT(*) FROM Booking_2023
UNION ALL
SELECT 'Booking_2024', COUNT(*) FROM Booking_2024
UNION ALL
SELECT 'Booking_2025', COUNT(*) FROM Booking_2025
UNION ALL
SELECT 'Booking_2026', COUNT(*) FROM Booking_2026;