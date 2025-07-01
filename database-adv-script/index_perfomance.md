# Index Optimization - Airbnb Clone

This document outlines the process of identifying and creating indexes on high-usage columns to improve query performance in the **User**, **Booking**, and **Property** tables.

---

## 🔍 Step 1: Identify High-Usage Columns

Based on typical query patterns (JOINs, WHERE, ORDER BY), the following columns were identified for indexing:

### 📋 `User` Table
- `email` — used in lookups and authentication
- `account_status` — used in filters
- `created_at` — used in reports/ordering

### 📋 `Booking` Table
- `guest_id` — JOIN with User
- `property_id` — JOIN with Property
- `check_in_date`, `check_out_date` — used in date filters
- `booking_status` — used in filters
- `created_at` — ordering and reports

### 📋 `Property` Table
- `host_id` — JOIN with User
- `address_id` — JOIN with Address
- `property_type`, `price_per_night`, `listing_status`, `availability_status` — used in filtering and sorting

---

## 🛠️ Step 2: Create Indexes

Below are SQL commands to create the indexes. These are saved in `database_index.sql`.

---

## 📊 Step 3: Performance Testing (Before vs After)

Use the `EXPLAIN` keyword to measure query performance before and after applying indexes.

### 🧪 Example Query:

```sql
EXPLAIN
SELECT * FROM Booking
WHERE guest_id = 2
AND booking_status = 'confirmed'
ORDER BY created_at DESC;
