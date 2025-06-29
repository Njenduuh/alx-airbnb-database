-- ============================================================================
-- Airbnb Database Schema - Data Definition Language (DDL) Scripts
-- ============================================================================
-- Project: ALX Airbnb Database
-- Repository: alx-airbnb-database
-- Directory: database-script-0x01
-- Version: 1.0
-- Created: 2025
-- ============================================================================

-- Drop database if exists and create new one
DROP DATABASE IF EXISTS airbnb_db;
CREATE DATABASE airbnb_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE airbnb_db;

-- ============================================================================
-- LOCATION HIERARCHY TABLES
-- ============================================================================

-- Countries Table
CREATE TABLE Country (
    country_id INT AUTO_INCREMENT PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL,
    country_code CHAR(2) NOT NULL,
    phone_code VARCHAR(10),
    currency_code CHAR(3),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    UNIQUE KEY uk_country_name (country_name),
    UNIQUE KEY uk_country_code (country_code),
    
    -- Indexes
    INDEX idx_country_code (country_code),
    INDEX idx_country_name (country_name)
);

-- States/Provinces Table
CREATE TABLE State (
    state_id INT AUTO_INCREMENT PRIMARY KEY,
    country_id INT NOT NULL,
    state_name VARCHAR(100) NOT NULL,
    state_code VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY fk_state_country (country_id) REFERENCES Country(country_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    
    -- Constraints
    UNIQUE KEY uk_state_country (state_name, country_id),
    
    -- Indexes
    INDEX idx_state_country (country_id),
    INDEX idx_state_name (state_name),
    INDEX idx_state_code (state_code)
);

-- Cities Table
CREATE TABLE City (
    city_id INT AUTO_INCREMENT PRIMARY KEY,
    state_id INT NOT NULL,
    city_name VARCHAR(100) NOT NULL,
    timezone VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY fk_city_state (state_id) REFERENCES State(state_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    
    -- Constraints
    UNIQUE KEY uk_city_state (city_name, state_id),
    
    -- Indexes
    INDEX idx_city_state (state_id),
    INDEX idx_city_name (city_name)
);

-- Addresses Table
CREATE TABLE Address (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    street_address VARCHAR(255) NOT NULL,
    city_id INT NOT NULL,
    postal_code VARCHAR(20),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY fk_address_city (city_id) REFERENCES City(city_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    
    -- Constraints
    CHECK (latitude >= -90 AND latitude <= 90),
    CHECK (longitude >= -180 AND longitude <= 180),
    
    -- Indexes
    INDEX idx_address_city (city_id),
    INDEX idx_address_postal (postal_code),
    INDEX idx_address_coordinates (latitude, longitude)
);

-- ============================================================================
-- USER MANAGEMENT TABLES
-- ============================================================================

-- Users Table
CREATE TABLE User (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    date_of_birth DATE,
    profile_picture_url VARCHAR(500),
    is_host BOOLEAN DEFAULT FALSE,
    is_guest BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    account_status ENUM('active', 'suspended', 'deactivated') DEFAULT 'active',
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    UNIQUE KEY uk_user_email (email),
    CHECK (date_of_birth IS NULL OR date_of_birth <= CURDATE()),
    
    -- Indexes
    INDEX idx_user_email (email),
    INDEX idx_user_name (first_name, last_name),
    INDEX idx_user_status (account_status),
    INDEX idx_user_host (is_host),
    INDEX idx_user_created (created_at)
);

-- User Phone Numbers Table
CREATE TABLE User_Phone (
    phone_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    country_code VARCHAR(5) NOT NULL DEFAULT '+1',
    phone_type ENUM('mobile', 'home', 'work') DEFAULT 'mobile',
    is_primary BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    verification_code VARCHAR(10),
    verification_expires TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY fk_phone_user (user_id) REFERENCES User(user_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    
    -- Constraints
    UNIQUE KEY uk_user_phone (user_id, phone_number),
    
    -- Indexes
    INDEX idx_phone_user (user_id),
    INDEX idx_phone_number (phone_number),
    INDEX idx_phone_primary (user_id, is_primary)
);

-- ============================================================================
-- AMENITIES TABLES
-- ============================================================================

-- Amenities Master Table
CREATE TABLE Amenity (
    amenity_id INT AUTO_INCREMENT PRIMARY KEY,
    amenity_name VARCHAR(100) NOT NULL,
    amenity_category ENUM('basic', 'safety', 'luxury', 'accessibility', 'kitchen', 'bathroom', 'entertainment') DEFAULT 'basic',
    description TEXT,
    icon_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Constraints
    UNIQUE KEY uk_amenity_name (amenity_name),
    
    -- Indexes
    INDEX idx_amenity_category (amenity_category),
    INDEX idx_amenity_active (is_active),
    INDEX idx_amenity_name (amenity_name)
);

-- ============================================================================
-- PROPERTY TABLES
-- ============================================================================

-- Properties Table
CREATE TABLE Property (
    property_id INT AUTO_INCREMENT PRIMARY KEY,
    host_id INT NOT NULL,
    address_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price_per_night DECIMAL(10,2) NOT NULL,
    cleaning_fee DECIMAL(10,2) DEFAULT 0.00,
    security_deposit DECIMAL(10,2) DEFAULT 0.00,
    property_type ENUM('apartment', 'house', 'condo', 'villa', 'cabin', 'studio', 'loft', 'townhouse', 'other') NOT NULL,
    max_guests INT NOT NULL,
    bedrooms INT DEFAULT 0,
    beds INT DEFAULT 0,
    bathrooms DECIMAL(3,1) DEFAULT 0.0,
    square_feet INT,
    house_rules TEXT,
    check_in_time TIME DEFAULT '15:00:00',
    check_out_time TIME DEFAULT '11:00:00',
    minimum_stay INT DEFAULT 1,
    maximum_stay INT DEFAULT 365,
    availability_status ENUM('available', 'unavailable', 'maintenance', 'draft') DEFAULT 'draft',
    instant_book BOOLEAN DEFAULT FALSE,
    listing_status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY fk_property_host (host_id) REFERENCES User(user_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY fk_property_address (address_id) REFERENCES Address(address_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    
    -- Constraints
    CHECK (price_per_night > 0),
    CHECK (cleaning_fee >= 0),
    CHECK (security_deposit >= 0),
    CHECK (max_guests > 0),
    CHECK (bedrooms >= 0),
    CHECK (beds >= 0),
    CHECK (bathrooms >= 0),
    CHECK (minimum_stay >= 1),
    CHECK (maximum_stay >= minimum_stay),
    
    -- Indexes
    INDEX idx_property_host (host_id),
    INDEX idx_property_address (address_id),
    INDEX idx_property_type (property_type),
    INDEX idx_property_price (price_per_night),
    INDEX idx_property_guests (max_guests),
    INDEX idx_property_status (availability_status, listing_status),
    INDEX idx_property_location_price (address_id, price_per_night),
    INDEX idx_property_created (created_at)
);

-- Property-Amenity Junction Table
CREATE TABLE Property_Amenity (
    property_id INT NOT NULL,
    amenity_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Primary Key
    PRIMARY KEY pk_property_amenity (property_id, amenity_id),
    
    -- Foreign Keys
    FOREIGN KEY fk_pa_property (property_id) REFERENCES Property(property_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY fk_pa_amenity (amenity_id) REFERENCES Amenity(amenity_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    
    -- Indexes
    INDEX idx_pa_property (property_id),
    INDEX idx_pa_amenity (amenity_id)
);

-- Property Images Table
CREATE TABLE Property_Image (
    image_id INT AUTO_INCREMENT PRIMARY KEY,
    property_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    image_description VARCHAR(255),
    is_primary BOOLEAN DEFAULT FALSE,
    upload_order INT DEFAULT 1,
    image_type ENUM('interior', 'exterior', 'amenity', 'view', 'other') DEFAULT 'interior',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY fk_image_property (property_id) REFERENCES Property(property_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    
    -- Constraints
    CHECK (upload_order > 0),
    
    -- Indexes
    INDEX idx_image_property (property_id),
    INDEX idx_image_primary (property_id, is_primary),
    INDEX idx_image_order (property_id, upload_order)
);

-- ============================================================================
-- BOOKING TABLES
-- ============================================================================

-- Bookings Table
CREATE TABLE Booking (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    guest_id INT NOT NULL,
    property_id INT NOT NULL,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    base_price DECIMAL(10,2) NOT NULL,
    cleaning_fee DECIMAL(10,2) DEFAULT 0.00,
    service_fee DECIMAL(10,2) DEFAULT 0.00,
    tax_amount DECIMAL(10,2) DEFAULT 0.00,
    number_of_guests INT NOT NULL,
    number_of_nights INT NOT NULL,
    booking_status ENUM('pending', 'confirmed', 'cancelled', 'completed', 'no_show') DEFAULT 'pending',
    special_requests TEXT,
    cancellation_reason TEXT,
    cancelled_at TIMESTAMP NULL,
    confirmed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY fk_booking_guest (guest_id) REFERENCES User(user_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY fk_booking_property (property_id) REFERENCES Property(property_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    
    -- Constraints
    CHECK (check_out_date > check_in_date),
    CHECK (total_price > 0),
    CHECK (base_price > 0),
    CHECK (number_of_guests > 0),
    CHECK (number_of_nights > 0),
    
    -- Indexes
    INDEX idx_booking_guest (guest_id),
    INDEX idx_booking_property (property_id),
    INDEX idx_booking_dates (check_in_date, check_out_date),
    INDEX idx_booking_status (booking_status),
    INDEX idx_booking_property_dates (property_id, check_in_date, check_out_date),
    INDEX idx_booking_guest_status (guest_id, booking_status),
    INDEX idx_booking_created (created_at)
);

-- Booking Status History Table
CREATE TABLE Booking_Status_History (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    old_status ENUM('pending', 'confirmed', 'cancelled', 'completed', 'no_show'),
    new_status ENUM('pending', 'confirmed', 'cancelled', 'completed', 'no_show') NOT NULL,
    changed_by INT NOT NULL,
    change_reason TEXT,
    notes TEXT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY fk_history_booking (booking_id) REFERENCES Booking(booking_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY fk_history_user (changed_by) REFERENCES User(user_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    
    -- Indexes
    INDEX idx_history_booking (booking_id),
    INDEX idx_history_user (changed_by),
    INDEX idx_history_date (changed_at)
);

-- ============================================================================
-- PAYMENT TABLES
-- ============================================================================

-- Payment Methods Table
CREATE TABLE Payment_Method (
    method_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    method_type ENUM('credit_card', 'debit_card', 'paypal', 'stripe', 'bank_transfer', 'apple_pay', 'google_pay') NOT NULL,
    provider VARCHAR(50),
    last_four_digits CHAR(4),
    expiry_month INT,
    expiry_year INT,
    cardholder_name VARCHAR(100),
    billing_address_id INT,
    is_default BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY fk_payment_user (user_id) REFERENCES User(user_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY fk_payment_address (billing_address_id) REFERENCES Address(address_id) 
        ON DELETE SET NULL ON UPDATE CASCADE,
    
    -- Constraints
    CHECK (expiry_month IS NULL OR (expiry_month >= 1 AND expiry_month <= 12)),
    CHECK (expiry_year IS NULL OR expiry_year >= YEAR(CURDATE())),
    
    -- Indexes
    INDEX idx_payment_user (user_id),
    INDEX idx_payment_default (user_id, is_default),
    INDEX idx_payment_active (is_active)
);

-- Payments Table
CREATE TABLE Payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    method_id INT,
    amount DECIMAL(10,2) NOT NULL,
    payment_type ENUM('booking', 'security_deposit', 'cleaning_fee', 'service_fee', 'refund') DEFAULT 'booking',
    payment_status ENUM('pending', 'processing', 'completed', 'failed', 'cancelled', 'refunded') DEFAULT 'pending',
    payment_date TIMESTAMP NULL,
    transaction_id VARCHAR(100),
    external_transaction_id VARCHAR(100),
    processor_fee DECIMAL(10,2) DEFAULT 0.00,
    currency_code CHAR(3) DEFAULT 'USD',
    exchange_rate DECIMAL(10,4) DEFAULT 1.0000,
    failure_reason TEXT,
    refund_reason TEXT,
    refunded_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY fk_payment_booking (booking_id) REFERENCES Booking(booking_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY fk_payment_method (method_id) REFERENCES Payment_Method(method_id) 
        ON DELETE SET NULL ON UPDATE CASCADE,
    
    -- Constraints
    CHECK (amount > 0),
    CHECK (processor_fee >= 0),
    CHECK (exchange_rate > 0),
    UNIQUE KEY uk_transaction_id (transaction_id),
    
    -- Indexes
    INDEX idx_payment_booking (booking_id),
    INDEX idx_payment_method (method_id),
    INDEX idx_payment_status (payment_status),
    INDEX idx_payment_date (payment_date),
    INDEX idx_payment_transaction (transaction_id),
    INDEX idx_payment_external (external_transaction_id)
);

-- ============================================================================
-- REVIEW TABLES
-- ============================================================================

-- Reviews Table
CREATE TABLE Review (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    reviewer_id INT NOT NULL,
    property_id INT NOT NULL,
    rating INT NOT NULL,
    accuracy_rating INT,
    communication_rating INT,
    cleanliness_rating INT,
    location_rating INT,
    checkin_rating INT,
    value_rating INT,
    comment TEXT,
    review_type ENUM('guest_to_host', 'host_to_guest', 'property_review') NOT NULL,
    is_public BOOLEAN DEFAULT TRUE,
    response_comment TEXT,
    responded_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY fk_review_booking (booking_id) REFERENCES Booking(booking_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY fk_review_reviewer (reviewer_id) REFERENCES User(user_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY fk_review_property (property_id) REFERENCES Property(property_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    
    -- Constraints
    CHECK (rating >= 1 AND rating <= 5),
    CHECK (accuracy_rating IS NULL OR (accuracy_rating >= 1 AND accuracy_rating <= 5)),
    CHECK (communication_rating IS NULL OR (communication_rating >= 1 AND communication_rating <= 5)),
    CHECK (cleanliness_rating IS NULL OR (cleanliness_rating >= 1 AND cleanliness_rating <= 5)),
    CHECK (location_rating IS NULL OR (location_rating >= 1 AND location_rating <= 5)),
    CHECK (checkin_rating IS NULL OR (checkin_rating >= 1 AND checkin_rating <= 5)),
    CHECK (value_rating IS NULL OR (value_rating >= 1 AND value_rating <= 5)),
    
    -- Indexes
    INDEX idx_review_booking (booking_id),
    INDEX idx_review_reviewer (reviewer_id),
    INDEX idx_review_property (property_id),
    INDEX idx_review_rating (rating),
    INDEX idx_review_type (review_type),
    INDEX idx_review_public (is_public),
    INDEX idx_review_property_rating (property_id, rating),
    INDEX idx_review_created (created_at)
);

-- ============================================================================
-- MESSAGING TABLES
-- ============================================================================

-- Messages Table
CREATE TABLE Message (
    message_id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    recipient_id INT NOT NULL,
    booking_id INT,
    message_content TEXT NOT NULL,
    message_type ENUM('booking_inquiry', 'booking_request', 'general', 'support') DEFAULT 'general',
    is_read BOOLEAN DEFAULT FALSE,
    is_archived BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY fk_message_sender (sender_id) REFERENCES User(user_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY fk_message_recipient (recipient_id) REFERENCES User(user_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY fk_message_booking (booking_id) REFERENCES Booking(booking_id) 
        ON DELETE SET NULL ON UPDATE CASCADE,
    
    -- Constraints
    CHECK (sender_id != recipient_id),
    
    -- Indexes
    INDEX idx_message_sender (sender_id),
    INDEX idx_message_recipient (recipient_id),
    INDEX idx_message_booking (booking_id),
    INDEX idx_message_read (recipient_id, is_read),
    INDEX idx_message_conversation (sender_id, recipient_id, sent_at),
    INDEX idx_message_sent (sent_at)
);

-- ============================================================================
-- PERFORMANCE OPTIMIZATION TABLES
-- ============================================================================

-- Property Search Cache (Denormalized for performance)
CREATE TABLE Property_Search_Cache (
    property_id INT PRIMARY KEY,
    full_address TEXT,
    city_name VARCHAR(100),
    state_name VARCHAR(100),
    country_name VARCHAR(100),
    amenity_list TEXT,
    avg_rating DECIMAL(3,2) DEFAULT 0.00,
    review_count INT DEFAULT 0,
    total_bookings INT DEFAULT 0,
    availability_calendar JSON,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY fk_cache_property (property_id) REFERENCES Property(property_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    
    -- Indexes
    INDEX idx_cache_city (city_name),
    INDEX idx_cache_state (state_name),
    INDEX idx_cache_country (country_name),
    INDEX idx_cache_rating (avg_rating),
    INDEX idx_cache_updated (last_updated),
    FULLTEXT INDEX ft_cache_address (full_address),
    FULLTEXT INDEX ft_cache_amenities (amenity_list)
);

-- User Statistics Table (Denormalized for performance)
CREATE TABLE User_Statistics (
    user_id INT PRIMARY KEY,
    total_bookings INT DEFAULT 0,
    total_properties INT DEFAULT 0,
    total_reviews_received INT DEFAULT 0,
    total_reviews_given INT DEFAULT 0,
    avg_guest_rating DECIMAL(3,2) DEFAULT 0.00,
    avg_host_rating DECIMAL(3,2) DEFAULT 0.00,
    total_earnings DECIMAL(12,2) DEFAULT 0.00,
    total_spent DECIMAL(12,2) DEFAULT 0.00,
    last_booking_date DATE,
    last_activity TIMESTAMP,
    account_created DATE,
    response_rate DECIMAL(5,2) DEFAULT 0.00,
    response_time_hours INT DEFAULT 24,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY fk_stats_user (user_id) REFERENCES User(user_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    
    -- Indexes
    INDEX idx_stats_bookings (total_bookings),
    INDEX idx_stats_properties (total_properties),
    INDEX idx_stats_guest_rating (avg_guest_rating),
    INDEX idx_stats_host_rating (avg_host_rating),
    INDEX idx_stats_earnings (total_earnings),
    INDEX idx_stats_activity (last_activity)
);

-- ============================================================================
-- TRIGGERS FOR MAINTAINING STATISTICS
-- ============================================================================

-- Trigger to update property search cache when property is updated
DELIMITER //
CREATE TRIGGER tr_property_cache_update
    AFTER UPDATE ON Property
    FOR EACH ROW
BEGIN
    IF OLD.name != NEW.name OR OLD.description != NEW.description OR OLD.price_per_night != NEW.price_per_night THEN
        UPDATE Property_Search_Cache 
        SET last_updated = CURRENT_TIMESTAMP 
        WHERE property_id = NEW.property_id;
    END IF;
END//
DELIMITER ;

-- Trigger to update user statistics when booking is created
DELIMITER //
CREATE TRIGGER tr_booking_stats_insert
    AFTER INSERT ON Booking
    FOR EACH ROW
BEGIN
    INSERT INTO User_Statistics (user_id, total_bookings, last_booking_date, last_updated)
    VALUES (NEW.guest_id, 1, NEW.check_in_date, CURRENT_TIMESTAMP)
    ON DUPLICATE KEY UPDATE
        total_bookings = total_bookings + 1,
        last_booking_date = GREATEST(last_booking_date, NEW.check_in_date),
        last_updated = CURRENT_TIMESTAMP;
END//
DELIMITER ;

-- ============================================================================
-- INITIAL DATA SETUP
-- ============================================================================

-- Insert default amenities
INSERT INTO Amenity (amenity_name, amenity_category, description) VALUES
('WiFi', 'basic', 'Wireless internet access'),
('Kitchen', 'basic', 'Full kitchen with appliances'),
('Air Conditioning', 'basic', 'Climate control system'),
('Heating', 'basic', 'Heating system'),
('TV', 'entertainment', 'Television with cable/streaming'),
('Washer', 'basic', 'Washing machine'),
('Dryer', 'basic', 'Clothes dryer'),
('Parking', 'basic', 'Free parking space'),
('Pool', 'luxury', 'Swimming pool access'),
('Hot Tub', 'luxury', 'Hot tub or jacuzzi'),
('Gym', 'luxury', 'Fitness center access'),
('Smoke Detector', 'safety', 'Smoke detection system'),
('Fire Extinguisher', 'safety', 'Fire safety equipment'),
('First Aid Kit', 'safety', 'Medical emergency supplies'),
('Wheelchair Accessible', 'accessibility', 'Accessible for mobility devices'),
('Elevator', 'accessibility', 'Elevator access'),
('Step-Free Access', 'accessibility', 'No steps to entrance');

-- Insert sample countries
INSERT INTO Country (country_name, country_code, phone_code, currency_code) VALUES
('United States', 'US', '+1', 'USD'),
('Canada', 'CA', '+1', 'CAD'),
('United Kingdom', 'GB', '+44', 'GBP'),
('France', 'FR', '+33', 'EUR'),
('Germany', 'DE', '+49', 'EUR'),
('Spain', 'ES', '+34', 'EUR'),
('Italy', 'IT', '+39', 'EUR'),
('Australia', 'AU', '+61', 'AUD'),
('Japan', 'JP', '+81', 'JPY'),
('Brazil', 'BR', '+55', 'BRL');

-- ============================================================================
-- VIEWS FOR COMMON QUERIES
-- ============================================================================

-- Property details view with location information
CREATE VIEW vw_property_details AS
SELECT 
    p.property_id,
    p.name,
    p.description,
    p.price_per_night,
    p.property_type,
    p.max_guests,
    p.bedrooms,
    p.bathrooms,
    CONCAT(a.street_address, ', ', c.city_name, ', ', s.state_name, ', ', co.country_name) as full_address,
    c.city_name,
    s.state_name,
    co.country_name,
    a.latitude,
    a.longitude,
    u.first_name as host_first_name,
    u.last_name as host_last_name,
    p.availability_status,
    p.listing_status,
    p.created_at
FROM Property p
JOIN Address a ON p.address_id = a.address_id
JOIN City c ON a.city_id = c.city_id
JOIN State s ON c.state_id = s.state_id
JOIN Country co ON s.country_id = co.country_id
JOIN User u ON p.host_id = u.user_id;

-- Booking details view
CREATE VIEW vw_booking_details AS
SELECT 
    b.booking_id,
    b.check_in_date,
    b.check_out_date,
    b.total_price,
    b.number_of_guests,
    b.booking_status,
    CONCAT(g.first_name, ' ', g.last_name) as guest_name,
    g.email as guest_email,
    p.name as property_name,
    CONCAT(h.first_name, ' ', h.last_name) as host_name,
    h.email as host_email
FROM Booking b
JOIN User g ON b.guest_id = g.user_id
JOIN Property p ON b.property_id = p.property_id
JOIN User h ON p.host_id = h.user_id;

-- ============================================================================
-- END OF DDL SCRIPT
-- ============================================================================