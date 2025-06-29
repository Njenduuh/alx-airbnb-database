# Airbnb-like Database: Entity-Relationship Diagram

## Entities and Attributes

### 1. User
**Primary Key**: user_id
- user_id (INT, AUTO_INCREMENT, PRIMARY KEY)
- first_name (VARCHAR(50), NOT NULL)
- last_name (VARCHAR(50), NOT NULL)
- email (VARCHAR(100), UNIQUE, NOT NULL)
- password_hash (VARCHAR(255), NOT NULL)
- phone_number (VARCHAR(20))
- date_of_birth (DATE)
- profile_picture_url (VARCHAR(255))
- is_host (BOOLEAN, DEFAULT FALSE)
- is_guest (BOOLEAN, DEFAULT TRUE)
- created_at (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)
- updated_at (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP)

### 2. Property
**Primary Key**: property_id
- property_id (INT, AUTO_INCREMENT, PRIMARY KEY)
- host_id (INT, FOREIGN KEY → User.user_id)
- name (VARCHAR(255), NOT NULL)
- description (TEXT)
- location (VARCHAR(255), NOT NULL)
- latitude (DECIMAL(10,8))
- longitude (DECIMAL(11,8))
- price_per_night (DECIMAL(10,2), NOT NULL)
- property_type (ENUM('apartment', 'house', 'condo', 'villa', 'cabin', 'other'))
- max_guests (INT, NOT NULL)
- bedrooms (INT)
- bathrooms (DECIMAL(3,1))
- amenities (JSON)
- house_rules (TEXT)
- availability_status (ENUM('available', 'unavailable', 'maintenance'), DEFAULT 'available')
- created_at (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)
- updated_at (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP)

### 3. Booking
**Primary Key**: booking_id
- booking_id (INT, AUTO_INCREMENT, PRIMARY KEY)
- guest_id (INT, FOREIGN KEY → User.user_id)
- property_id (INT, FOREIGN KEY → Property.property_id)
- check_in_date (DATE, NOT NULL)
- check_out_date (DATE, NOT NULL)
- total_price (DECIMAL(10,2), NOT NULL)
- number_of_guests (INT, NOT NULL)
- booking_status (ENUM('pending', 'confirmed', 'cancelled', 'completed'), DEFAULT 'pending')
- special_requests (TEXT)
- created_at (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)
- updated_at (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP)

### 4. Payment
**Primary Key**: payment_id
- payment_id (INT, AUTO_INCREMENT, PRIMARY KEY)
- booking_id (INT, FOREIGN KEY → Booking.booking_id)
- amount (DECIMAL(10,2), NOT NULL)
- payment_method (ENUM('credit_card', 'debit_card', 'paypal', 'bank_transfer', 'cash'))
- payment_status (ENUM('pending', 'completed', 'failed', 'refunded'), DEFAULT 'pending')
- payment_date (TIMESTAMP)
- transaction_id (VARCHAR(100), UNIQUE)
- created_at (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)

### 5. Review
**Primary Key**: review_id
- review_id (INT, AUTO_INCREMENT, PRIMARY KEY)
- booking_id (INT, FOREIGN KEY → Booking.booking_id)
- reviewer_id (INT, FOREIGN KEY → User.user_id)
- property_id (INT, FOREIGN KEY → Property.property_id)
- rating (INT, CHECK(rating >= 1 AND rating <= 5))
- comment (TEXT)
- review_type (ENUM('guest_to_host', 'host_to_guest', 'property_review'))
- created_at (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)

### 6. Message
**Primary Key**: message_id
- message_id (INT, AUTO_INCREMENT, PRIMARY KEY)
- sender_id (INT, FOREIGN KEY → User.user_id)
- recipient_id (INT, FOREIGN KEY → User.user_id)
- booking_id (INT, FOREIGN KEY → Booking.booking_id, NULLABLE)
- message_content (TEXT, NOT NULL)
- is_read (BOOLEAN, DEFAULT FALSE)
- sent_at (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)

### 7. Property_Image
**Primary Key**: image_id
- image_id (INT, AUTO_INCREMENT, PRIMARY KEY)
- property_id (INT, FOREIGN KEY → Property.property_id)
- image_url (VARCHAR(255), NOT NULL)
- image_description (VARCHAR(255))
- is_primary (BOOLEAN, DEFAULT FALSE)
- upload_order (INT, DEFAULT 1)
- created_at (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)

## Relationships

### 1. User ↔ Property (One-to-Many)
- **Relationship**: A User (as host) can own multiple Properties
- **Foreign Key**: Property.host_id → User.user_id
- **Cardinality**: 1:N (One User can have many Properties)

### 2. User ↔ Booking (One-to-Many)
- **Relationship**: A User (as guest) can make multiple Bookings
- **Foreign Key**: Booking.guest_id → User.user_id
- **Cardinality**: 1:N (One User can have many Bookings)

### 3. Property ↔ Booking (One-to-Many)
- **Relationship**: A Property can have multiple Bookings
- **Foreign Key**: Booking.property_id → Property.property_id
- **Cardinality**: 1:N (One Property can have many Bookings)

### 4. Booking ↔ Payment (One-to-Many)
- **Relationship**: A Booking can have multiple Payments (installments, deposits, etc.)
- **Foreign Key**: Payment.booking_id → Booking.booking_id
- **Cardinality**: 1:N (One Booking can have many Payments)

### 5. Booking ↔ Review (One-to-Many)
- **Relationship**: A Booking can have multiple Reviews (guest reviews property, host reviews guest)
- **Foreign Key**: Review.booking_id → Booking.booking_id
- **Cardinality**: 1:N (One Booking can have many Reviews)

### 6. User ↔ Review (One-to-Many)
- **Relationship**: A User can write multiple Reviews
- **Foreign Key**: Review.reviewer_id → User.user_id
- **Cardinality**: 1:N (One User can write many Reviews)

### 7. Property ↔ Review (One-to-Many)
- **Relationship**: A Property can receive multiple Reviews
- **Foreign Key**: Review.property_id → Property.property_id
- **Cardinality**: 1:N (One Property can have many Reviews)

### 8. User ↔ Message (Many-to-Many through self-referencing)
- **Relationship**: Users can send messages to other Users
- **Foreign Keys**: 
  - Message.sender_id → User.user_id
  - Message.recipient_id → User.user_id
- **Cardinality**: M:N (Users can send/receive multiple messages)

### 9. Booking ↔ Message (One-to-Many)
- **Relationship**: Messages can be related to specific Bookings
- **Foreign Key**: Message.booking_id → Booking.booking_id
- **Cardinality**: 1:N (One Booking can have many Messages)

### 10. Property ↔ Property_Image (One-to-Many)
- **Relationship**: A Property can have multiple Images
- **Foreign Key**: Property_Image.property_id → Property.property_id
- **Cardinality**: 1:N (One Property can have many Images)

## Business Rules and Constraints

1. **User Roles**: Users can be both hosts and guests simultaneously
2. **Booking Dates**: check_out_date must be after check_in_date
3. **Payment Integrity**: Total payments for a booking should not exceed the booking total_price
4. **Review Restrictions**: Users can only review properties they have booked
5. **Property Availability**: Properties marked as 'unavailable' cannot accept new bookings
6. **Image Constraints**: Each property should have at least one primary image
7. **Rating Validation**: Reviews must have ratings between 1 and 5
8. **Unique Constraints**: User emails must be unique, transaction IDs must be unique

## Indexes for Performance

1. **User**: email (unique index)
2. **Property**: host_id, location, price_per_night
3. **Booking**: guest_id, property_id, check_in_date, check_out_date, booking_status
4. **Payment**: booking_id, payment_status, payment_date
5. **Review**: property_id, reviewer_id, rating
6. **Message**: sender_id, recipient_id, booking_id, sent_at
7. **Property_Image**: property_id, is_primary

## ER Diagram Visual Description

```
USER (1) ──────── (M) PROPERTY
 │                     │
 │                     │
 │ (1)               (M) │
 │                     │
 └── BOOKING ──────────┘
     │ (1)
     │
     │ (M)
     ├── PAYMENT
     │
     │ (M)
     ├── REVIEW ──── (M) USER
     │           │
     │           └── (M) PROPERTY
     │
     │ (M)
     └── MESSAGE ──── (M) USER
                 │
                 └── (M) USER

PROPERTY (1) ──── (M) PROPERTY_IMAGE
```

This ERD represents a comprehensive Airbnb-like system with proper normalization, referential integrity, and scalability considerations.