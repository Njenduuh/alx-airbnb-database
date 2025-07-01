-- Database Indexes for Performance Optimization
-- File: database_index.sql
-- Purpose: Create indexes on high-usage columns for User, Booking, and Property tables

-- ========================================
-- USER TABLE INDEXES
-- ========================================

-- Index on email for user authentication and lookups
CREATE INDEX idx_user_email ON User(email);

-- Index on created_at for date-based queries and sorting
CREATE INDEX idx_user_created_at ON User(created_at);

-- Index on first_name and last_name for name-based searches
CREATE INDEX idx_user_name ON User(first_name, last_name);

-- Index on phone_number for contact lookups
CREATE INDEX idx_user_phone ON User(phone_number);

-- ========================================
-- PROPERTY TABLE INDEXES
-- ========================================

-- Index on host_id for JOIN operations with User table
CREATE INDEX idx_property_host_id ON Property(host_id);

-- Index on location for location-based searches
CREATE INDEX idx_property_location ON Property(location);

-- Index on pricepernight for price range queries
CREATE INDEX idx_property_price ON Property(pricepernight);

-- Index on created_at for sorting by listing date
CREATE INDEX idx_property_created_at ON Property(created_at);

-- Composite index for location and price (common search combination)
CREATE INDEX idx_property_location_price ON Property(location, pricepernight);

-- Index on property name for text searches
CREATE INDEX idx_property_name ON Property(name);

-- ========================================
-- BOOKING TABLE INDEXES
-- ========================================

-- Index on user_id for JOIN operations with User table
CREATE INDEX idx_booking_user_id ON Booking(user_id);

-- Index on property_id for JOIN operations with Property table
CREATE INDEX idx_booking_property_id ON Booking(property_id);

-- Index on start_date for date range queries
CREATE INDEX idx_booking_start_date ON Booking(start_date);

-- Index on end_date for date range queries
CREATE INDEX idx_booking_end_date ON Booking(end_date);

-- Index on status for filtering bookings by status
CREATE INDEX idx_booking_status ON Booking(status);

-- Index on created_at for sorting by booking date
CREATE INDEX idx_booking_created_at ON Booking(created_at);

-- Composite index for date range queries (start_date, end_date)
CREATE INDEX idx_booking_date_range ON Booking(start_date, end_date);

-- Composite index for user bookings with status
CREATE INDEX idx_booking_user_status ON Booking(user_id, status);

-- Composite index for property availability checks
CREATE INDEX idx_booking_property_dates ON Booking(property_id, start_date, end_date);

-- ========================================
-- ADDITIONAL COMPOSITE INDEXES
-- ========================================

-- Index for common booking queries (property + date range + status)
CREATE INDEX idx_booking_property_date_status ON Booking(property_id, start_date, end_date, status);

-- Index for host property management
CREATE INDEX idx_property_host_created ON Property(host_id, created_at);

-- Index for user activity tracking
CREATE INDEX idx_booking_user_created ON Booking(user_id, created_at);

-- ========================================
-- PERFORMANCE ANALYSIS QUERIES
-- ========================================

-- Query 1: User Authentication Performance Test
-- Before Index:
-- EXPLAIN ANALYZE SELECT * FROM User WHERE email = 'user@example.com';

-- After Index:
-- EXPLAIN ANALYZE SELECT * FROM User WHERE email = 'user@example.com';

-- Query 2: Property Search Performance Test
-- Before Index:
-- EXPLAIN ANALYZE SELECT * FROM Property 
-- WHERE location = 'New York' AND pricepernight BETWEEN 100 AND 300
-- ORDER BY pricepernight;

-- After Index:
-- EXPLAIN ANALYZE SELECT * FROM Property 
-- WHERE location = 'New York' AND pricepernight BETWEEN 100 AND 300
-- ORDER BY pricepernight;

-- Query 3: Booking Date Range Performance Test
-- Before Index:
-- EXPLAIN ANALYZE SELECT COUNT(*) FROM Booking 
-- WHERE property_id = 123 
-- AND start_date <= '2024-12-31' 
-- AND end_date >= '2024-12-01'
-- AND status = 'confirmed';

-- After Index:
-- EXPLAIN ANALYZE SELECT COUNT(*) FROM Booking 
-- WHERE property_id = 123 
-- AND start_date <= '2024-12-31' 
-- AND end_date >= '2024-12-01'
-- AND status = 'confirmed';

-- Query 4: Complex JOIN Performance Test
-- Before Index:
-- EXPLAIN ANALYZE SELECT u.first_name, u.last_name, p.name as property_name, 
-- b.start_date, b.end_date, b.status
-- FROM User u
-- JOIN Booking b ON u.user_id = b.user_id
-- JOIN Property p ON b.property_id = p.property_id
-- WHERE u.email = 'user@example.com'
-- ORDER BY b.created_at DESC;

-- After Index:
-- EXPLAIN ANALYZE SELECT u.first_name, u.last_name, p.name as property_name, 
-- b.start_date, b.end_date, b.status
-- FROM User u
-- JOIN Booking b ON u.user_id = b.user_id
-- JOIN Property p ON b.property_id = p.property_id
-- WHERE u.email = 'user@example.com'
-- ORDER BY b.created_at DESC;