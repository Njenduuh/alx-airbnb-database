# Database Normalization Analysis - Achieving Third Normal Form (3NF)

## Overview
This document analyzes the Airbnb-like database design and applies normalization principles to ensure the database meets Third Normal Form (3NF) requirements, eliminating redundancy and ensuring data integrity.

## Normalization Forms Review

### First Normal Form (1NF)
**Requirements:**
- Each column contains atomic (indivisible) values
- Each row is unique
- No repeating groups

### Second Normal Form (2NF)
**Requirements:**
- Must be in 1NF
- All non-key attributes must be fully functionally dependent on the primary key
- No partial dependencies

### Third Normal Form (3NF)
**Requirements:**
- Must be in 2NF
- No transitive dependencies (non-key attributes should not depend on other non-key attributes)

## Initial Schema Analysis

### Current Schema Issues Identified

#### 1. **Property Table - Location Redundancy**
**Issue:** The `location` field stores complete address as a single string, potentially causing redundancy.

**Current Design:**
```sql
Property {
    property_id (PK)
    location (VARCHAR(255)) -- "123 Main St, New York, NY, 10001, USA"
    latitude (DECIMAL)
    longitude (DECIMAL)
    ...
}
```

**Problem:** Multiple properties in the same city/state/country will have redundant location data.

#### 2. **User Table - Potential Phone Format Issues**
**Issue:** Phone numbers stored without country code standardization.

#### 3. **Property Table - Amenities JSON Field**
**Issue:** JSON field for amenities violates 1NF (not atomic).

## Normalization Steps Applied

### Step 1: Decompose Location Data (Addressing 2NF/3NF)

**Create Location Hierarchy Tables:**

```sql
-- Countries Table
CREATE TABLE Country (
    country_id INT AUTO_INCREMENT PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL UNIQUE,
    country_code CHAR(2) NOT NULL UNIQUE
);

-- States/Provinces Table  
CREATE TABLE State (
    state_id INT AUTO_INCREMENT PRIMARY KEY,
    country_id INT NOT NULL,
    state_name VARCHAR(100) NOT NULL,
    state_code VARCHAR(10),
    FOREIGN KEY (country_id) REFERENCES Country(country_id),
    UNIQUE KEY unique_state_country (state_name, country_id)
);

-- Cities Table
CREATE TABLE City (
    city_id INT AUTO_INCREMENT PRIMARY KEY,
    state_id INT NOT NULL,
    city_name VARCHAR(100) NOT NULL,
    FOREIGN KEY (state_id) REFERENCES State(state_id),
    UNIQUE KEY unique_city_state (city_name, state_id)
);

-- Addresses Table
CREATE TABLE Address (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    street_address VARCHAR(255) NOT NULL,
    city_id INT NOT NULL,
    postal_code VARCHAR(20),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    FOREIGN KEY (city_id) REFERENCES City(city_id)
);
```

**Updated Property Table:**
```sql
CREATE TABLE Property (
    property_id INT AUTO_INCREMENT PRIMARY KEY,
    host_id INT NOT NULL,
    address_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price_per_night DECIMAL(10,2) NOT NULL,
    property_type ENUM('apartment', 'house', 'condo', 'villa', 'cabin', 'other'),
    max_guests INT NOT NULL,
    bedrooms INT,
    bathrooms DECIMAL(3,1),
    house_rules TEXT,
    availability_status ENUM('available', 'unavailable', 'maintenance') DEFAULT 'available',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (host_id) REFERENCES User(user_id),
    FOREIGN KEY (address_id) REFERENCES Address(address_id)
);
```

### Step 2: Normalize Amenities (Achieving 1NF)

**Create Amenities Tables:**

```sql
-- Amenities Master Table
CREATE TABLE Amenity (
    amenity_id INT AUTO_INCREMENT PRIMARY KEY,
    amenity_name VARCHAR(100) NOT NULL UNIQUE,
    amenity_category ENUM('basic', 'safety', 'luxury', 'accessibility') DEFAULT 'basic',
    description TEXT,
    icon_url VARCHAR(255)
);

-- Property-Amenity Junction Table (Many-to-Many)
CREATE TABLE Property_Amenity (
    property_id INT NOT NULL,
    amenity_id INT NOT NULL,
    PRIMARY KEY (property_id, amenity_id),
    FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE CASCADE,
    FOREIGN KEY (amenity_id) REFERENCES Amenity(amenity_id) ON DELETE CASCADE
);
```

### Step 3: Normalize User Contact Information

**Create Contact Tables:**

```sql
-- Phone Numbers Table (Supporting multiple phone numbers per user)
CREATE TABLE User_Phone (
    phone_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    country_code VARCHAR(5) NOT NULL,
    phone_type ENUM('mobile', 'home', 'work') DEFAULT 'mobile',
    is_primary BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_phone (user_id, phone_number)
);

-- Updated User Table (Removed phone_number field)
CREATE TABLE User (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    date_of_birth DATE,
    profile_picture_url VARCHAR(255),
    is_host BOOLEAN DEFAULT FALSE,
    is_guest BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Step 4: Normalize Payment Methods

**Create Payment Method Tables:**

```sql
-- Payment Methods Table
CREATE TABLE Payment_Method (
    method_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    method_type ENUM('credit_card', 'debit_card', 'paypal', 'bank_transfer') NOT NULL,
    provider VARCHAR(50), -- Visa, MasterCard, PayPal, etc.
    last_four_digits CHAR(4), -- For cards
    expiry_month INT, -- For cards
    expiry_year INT, -- For cards
    is_default BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE
);

-- Updated Payment Table
CREATE TABLE Payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    method_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
    payment_date TIMESTAMP,
    transaction_id VARCHAR(100) UNIQUE,
    processor_fee DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id),
    FOREIGN KEY (method_id) REFERENCES Payment_Method(method_id)
);
```

### Step 5: Create Booking Status History (Audit Trail)

**Create Status Tracking:**

```sql
-- Booking Status History Table
CREATE TABLE Booking_Status_History (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    old_status ENUM('pending', 'confirmed', 'cancelled', 'completed'),
    new_status ENUM('pending', 'confirmed', 'cancelled', 'completed') NOT NULL,
    changed_by INT NOT NULL, -- user_id who made the change
    change_reason TEXT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id),
    FOREIGN KEY (changed_by) REFERENCES User(user_id)
);
```

## Final Normalized Schema

### Complete 3NF Schema Structure

```sql
-- Core Tables
User (user_id, first_name, last_name, email, password_hash, date_of_birth, profile_picture_url, is_host, is_guest, created_at, updated_at)

User_Phone (phone_id, user_id, phone_number, country_code, phone_type, is_primary, is_verified)

Country (country_id, country_name, country_code)
State (state_id, country_id, state_name, state_code)
City (city_id, state_id, city_name)
Address (address_id, street_address, city_id, postal_code, latitude, longitude)

Property (property_id, host_id, address_id, name, description, price_per_night, property_type, max_guests, bedrooms, bathrooms, house_rules, availability_status, created_at, updated_at)

Amenity (amenity_id, amenity_name, amenity_category, description, icon_url)
Property_Amenity (property_id, amenity_id)

Property_Image (image_id, property_id, image_url, image_description, is_primary, upload_order, created_at)

Booking (booking_id, guest_id, property_id, check_in_date, check_out_date, total_price, number_of_guests, booking_status, special_requests, created_at, updated_at)

Booking_Status_History (history_id, booking_id, old_status, new_status, changed_by, change_reason, changed_at)

Payment_Method (method_id, user_id, method_type, provider, last_four_digits, expiry_month, expiry_year, is_default, is_active, created_at)

Payment (payment_id, booking_id, method_id, amount, payment_status, payment_date, transaction_id, processor_fee, created_at)

Review (review_id, booking_id, reviewer_id, property_id, rating, comment, review_type, created_at)

Message (message_id, sender_id, recipient_id, booking_id, message_content, is_read, sent_at)
```

## Normalization Verification

### 1NF Compliance ✅
- **Atomic Values**: All fields contain single, indivisible values
- **Unique Rows**: Each table has a primary key ensuring uniqueness
- **No Repeating Groups**: Amenities moved to separate junction table

### 2NF Compliance ✅
- **Fully Functionally Dependent**: All non-key attributes depend entirely on the primary key
- **No Partial Dependencies**: All composite keys properly structured

### 3NF Compliance ✅
- **No Transitive Dependencies**: 
  - Location data normalized (city doesn't depend on property_id through state)
  - Payment method details separated from payment transactions
  - Contact information separated from user core data

## Benefits of Normalization

### 1. **Reduced Data Redundancy**
- Location data shared across properties
- Amenities reused across multiple properties
- Payment methods reused for multiple transactions

### 2. **Improved Data Integrity**
- Consistent location data
- Standardized amenity names
- Proper foreign key constraints

### 3. **Enhanced Maintainability**
- Easy to update city/state information
- Simple amenity management
- Centralized contact information

### 4. **Better Query Performance**
- Proper indexing opportunities
- Efficient joins with normalized tables
- Reduced storage requirements

### 5. **Scalability**
- Easy to add new countries/states
- Simple amenity additions
- Flexible payment method support

## Potential Denormalization Considerations

For **high-frequency queries**, consider these strategic denormalizations:

### 1. **Property Search Cache**
```sql
-- Materialized view for property searches
CREATE TABLE Property_Search_Cache (
    property_id INT PRIMARY KEY,
    full_address TEXT, -- Denormalized for faster searches
    amenity_list TEXT, -- Comma-separated for quick filtering
    avg_rating DECIMAL(3,2), -- Calculated field
    review_count INT, -- Calculated field
    last_updated TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES Property(property_id)
);
```

### 2. **User Activity Summary**
```sql
-- User statistics for quick dashboard loading
CREATE TABLE User_Statistics (
    user_id INT PRIMARY KEY,
    total_bookings INT DEFAULT 0,
    total_properties INT DEFAULT 0,
    avg_guest_rating DECIMAL(3,2),
    avg_host_rating DECIMAL(3,2),
    last_activity TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES User(user_id)
);
```

## Implementation Notes

### Migration Strategy
1. **Phase 1**: Create new normalized tables
2. **Phase 2**: Migrate existing data
3. **Phase 3**: Update application code
4. **Phase 4**: Drop old columns/tables

### Index Recommendations
```sql
-- Location-based searches
CREATE INDEX idx_address_city ON Address(city_id);
CREATE INDEX idx_city_state ON City(state_id);
CREATE INDEX idx_state_country ON State(country_id);

-- Property searches
CREATE INDEX idx_property_location ON Property(address_id);
CREATE INDEX idx_property_amenity ON Property_Amenity(amenity_id);

-- User lookups
CREATE INDEX idx_user_phone ON User_Phone(user_id);
CREATE INDEX idx_payment_method_user ON Payment_Method(user_id);
```

## Conclusion

The database schema has been successfully normalized to 3NF, achieving:
- ✅ **Data Integrity**: Proper referential constraints
- ✅ **Reduced Redundancy**: Eliminated duplicate data
- ✅ **Improved Maintainability**: Logical data organization
- ✅ **Enhanced Performance**: Optimized for queries
- ✅ **Scalability**: Ready for future growth

The normalized design maintains all original functionality while providing a robust foundation for the Airbnb-like application.